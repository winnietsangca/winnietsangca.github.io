import SwiftUI

struct MatchScoreView: View {
    @EnvironmentObject private var match: MatchStateManager
    @StateObject private var voice = VoiceScoringEngine()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 2) {
                // Sets row
                ScoreRow(
                    label: "SETS",
                    myValue: "\(match.mySetScore)",
                    theirValue: "\(match.theirSetScore)",
                    size: .large)

                divider

                // Games row
                ScoreRow(
                    label: "GAMES",
                    myValue: "\(match.sets[match.currentSetIndex].mine)",
                    theirValue: "\(match.sets[match.currentSetIndex].theirs)",
                    size: .medium)

                divider

                // Points row
                ScoreRow(
                    label: "POINT",
                    myValue: match.myPointDisplay,
                    theirValue: match.theirPointDisplay,
                    size: .small)
            }
            .padding(.top, 24)

            // Listening indicator
            HStack(spacing: 5) {
                Circle()
                    .fill(voice.isListening ? Color.tAccent : Color.tText3)
                    .frame(width: 6, height: 6)
                    .animation(.easeInOut(duration: 0.8).repeatForever(), value: voice.isListening)
                Text(voice.isListening ? "Listening" : "Paused")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.tText3)
                    .tracking(1)
            }
            .padding(.bottom, 10)
        }
        .background(Color.tBg)
        .onAppear {
            voice.matchState = match
            Task { await voice.requestAuthorization(); voice.startListening() }
        }
        .onDisappear { voice.stopListening() }
        // Tap anywhere for undo (crown press is reserved for system)
        .onLongPressGesture(minimumDuration: 0.8) { match.undoLastPoint() }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.tCard2)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

// MARK: - Score row

private enum ScoreSize { case large, medium, small }

private struct ScoreRow: View {
    let label: String
    let myValue: String
    let theirValue: String
    let size: ScoreSize

    private var fontSize: CGFloat {
        switch size {
        case .large:  return 32
        case .medium: return 24
        case .small:  return 20
        }
    }

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(myValue)
                    .font(.system(size: fontSize, weight: .black))
                    .foregroundStyle(Color.tAccent)
                    .frame(minWidth: 36)

                Text("–")
                    .font(.system(size: fontSize * 0.7, weight: .black))
                    .foregroundStyle(Color.tText3)

                Text(theirValue)
                    .font(.system(size: fontSize, weight: .black))
                    .foregroundStyle(.white)
                    .frame(minWidth: 36)
            }
        }
        .padding(.vertical, 4)
    }
}
