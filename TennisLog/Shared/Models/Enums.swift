import Foundation

// MARK: - Session

enum SessionType: String, Codable, CaseIterable {
    case practice = "Practice"
    case match    = "Match"
}

enum Surface: String, Codable, CaseIterable {
    case hard = "Hard"
    case clay = "Clay"
}

enum MatchFormat: String, Codable, CaseIterable {
    case singles = "Singles"
    case doubles = "Doubles"
}

// MARK: - Scoring

enum PointWinner: String, Codable {
    case me
    case them
}

/// Shot type when YOU win the point (tap-mode buckets on Watch)
enum ShotType: String, Codable, CaseIterable {
    case ace             = "Ace"
    case forehandWinner  = "FH Winner"
    case backhandWinner  = "BH Winner"
    case volleyOverhead  = "Vol / OH"
    case theirError      = "Their Error"   // opponent unforced error (no shot detail)
    case theirWinner     = "Their Winner"  // forced/passing shot (crown-scroll shortcut)
    case doubleFault     = "Double Fault"  // their point, your serve

    var isMyWinner: Bool {
        switch self {
        case .ace, .forehandWinner, .backhandWinner, .volleyOverhead: return true
        default: return false
        }
    }
}

/// Error type when THEY win the point — describes your error
enum ErrorType: String, Codable, CaseIterable {
    case forehandNet     = "FH Net"
    case forehandOut     = "FH Out"
    case backhandNet     = "BH Net"
    case backhandOut     = "BH Out"
    case volleyOverhead  = "Vol / OH"
    case doubleFault     = "Double Fault"

    var displayShort: String { rawValue }
}

// MARK: - Voice scoring mode

enum ScoringMode: String, Codable, CaseIterable {
    case voicePlusTap  = "Voice + Tap"    // say point, tap shot type
    case fullVoice     = "Full Voice"     // compound voice commands

    var description: String {
        switch self {
        case .voicePlusTap: return "Say "point me/them", then tap shot type on Watch"
        case .fullVoice:    return "Say full command, e.g. "point me, forehand winner""
        }
    }
}

// MARK: - Watch match phase

enum MatchPhase: String, Codable {
    case playing
    case awaitingShotType   // tap-mode: waiting for shot classification
    case faultCalled        // showing FAULT screen, next point is 2nd serve
    case gameOver
    case setOver
    case matchOver
}

// MARK: - WatchConnectivity message keys

enum WatchMessageKey {
    static let matchPayload  = "matchPayload"
    static let sessionStart  = "sessionStart"
    static let sessionEnd    = "sessionEnd"
    static let matchFormat   = "matchFormat"
    static let scoringMode   = "scoringMode"
}
