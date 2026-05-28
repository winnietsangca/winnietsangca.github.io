import Foundation
import Speech
import AVFoundation

/// Continuous speech recognition engine for the Watch.
/// Parses tennis score commands and forwards them to MatchStateManager.
@MainActor
final class VoiceScoringEngine: ObservableObject {

    @Published var isListening = false
    @Published var lastTranscript = ""
    @Published var authStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    weak var matchState: MatchStateManager?

    // MARK: - Auth

    func requestAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.authStatus = status
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Start / stop

    func startListening() {
        guard authStatus == .authorized,
              recognizer?.isAvailable == true,
              !audioEngine.isRunning else { return }

        do {
            try configureAudioSession()
            request = SFSpeechAudioBufferRecognitionRequest()
            guard let req = request else { return }
            req.shouldReportPartialResults = true
            req.requiresOnDeviceRecognition = false   // on-device if available

            task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
                guard let self else { return }
                if let text = result?.bestTranscription.formattedString {
                    Task { @MainActor in
                        self.lastTranscript = text
                        self.processTranscript(text)
                    }
                }
                if error != nil || result?.isFinal == true {
                    Task { @MainActor in self.restart() }
                }
            }

            let node   = audioEngine.inputNode
            let format = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buf, _ in
                self?.request?.append(buf)
            }
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
        } catch {
            isListening = false
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
    }

    // Auto-restarts so recognition runs continuously
    private func restart() {
        stopListening()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startListening()
        }
    }

    // MARK: - Command parsing

    private var lastCommandTime: Date = .distantPast
    private let commandDebounce: TimeInterval = 1.5   // ignore repeats within 1.5s

    private func processTranscript(_ text: String) {
        let lower = text.lowercased()
        guard let cmd = parseCommand(lower) else { return }

        // Debounce: same command fired twice from partial → final result
        let now = Date()
        guard now.timeIntervalSince(lastCommandTime) > commandDebounce else { return }
        lastCommandTime = now

        applyCommand(cmd)
        // Clear transcript so next partial doesn't re-trigger
        lastTranscript = ""
    }

    private func parseCommand(_ text: String) -> VoiceCommand? {

        // ── Fault ──────────────────────────────────────────────────
        if text.hasSuffix("double fault") || text.contains("double fault") {
            return .doubleFault
        }
        if text.hasSuffix("fault") || text.hasSuffix("first fault") {
            return .fault
        }

        // ── Undo ───────────────────────────────────────────────────
        if text.contains("undo") || text.contains("correction") || text.contains("cancel that") {
            return .undo
        }

        // ── Point me (I won) ───────────────────────────────────────
        let iWon = text.contains("point me") || text.contains("my point") ||
                   text.contains("point for me") || text.contains("i won")
        if iWon {
            if matchState?.scoringMode == .fullVoice {
                let shot = parseShotType(text)
                return .pointScored(winner: .me, shot: shot, error: nil)
            } else {
                return .pointScoredTapMode(winner: .me)
            }
        }

        // ── Point them (they won) ──────────────────────────────────
        let theyWon = text.contains("point them") || text.contains("their point") ||
                      text.contains("point for them") || text.contains("they won")
        if theyWon {
            if matchState?.scoringMode == .fullVoice {
                let error = parseErrorType(text)
                return .pointScored(winner: .them, shot: nil, error: error)
            } else {
                return .pointScoredTapMode(winner: .them)
            }
        }

        return nil
    }

    private func parseShotType(_ text: String) -> ShotType? {
        if text.contains("ace")                                  { return .ace }
        if text.contains("forehand winner") || text.contains("forehand")  { return .forehandWinner }
        if text.contains("backhand winner") || text.contains("backhand")  { return .backhandWinner }
        if text.contains("volley") || text.contains("overhead") { return .volleyOverhead }
        if text.contains("their error") || text.contains("unforced") { return .theirError }
        return nil
    }

    private func parseErrorType(_ text: String) -> ErrorType? {
        let isFH = text.contains("forehand") || text.contains("forward")
        let isBH = text.contains("backhand") || text.contains("backhand")
        let isNet = text.contains("net") || text.contains("into the net")
        let isOut = text.contains("out") || text.contains("long") || text.contains("wide")

        if text.contains("volley") || text.contains("overhead") { return .volleyOverhead }
        if isFH && isNet { return .forehandNet }
        if isFH && isOut { return .forehandOut }
        if isBH && isNet { return .backhandNet }
        if isBH && isOut { return .backhandOut }
        if isFH          { return .forehandNet }  // default FH error → net
        if isBH          { return .backhandNet }  // default BH error → net
        return nil
    }

    private func applyCommand(_ cmd: VoiceCommand) {
        guard let state = matchState else { return }
        switch cmd {
        case .fault:
            state.callFault()
        case .doubleFault:
            state.callDoubleFault()
        case .undo:
            state.undoLastPoint()
        case .pointScored(let winner, let shot, let error):
            state.scorePoint(winner: winner, shotType: shot, errorType: error)
        case .pointScoredTapMode(let winner):
            state.beginShotEntry(winner: winner)
        }
    }

    // MARK: - Audio session

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - Command enum

enum VoiceCommand {
    case fault
    case doubleFault
    case undo
    case pointScored(winner: PointWinner, shot: ShotType?, error: ErrorType?)
    case pointScoredTapMode(winner: PointWinner)
}
