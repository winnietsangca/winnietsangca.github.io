import SwiftUI
import WatchKit

/// Shown briefly after a game or set is won, then returns to the score screen.
struct GameEndView: View {
    @EnvironmentObject private var match: MatchStateManager

    private var isSetEnd: Bool { match.phase == .setOver }
    private var winnerIsMe: Bool { match.lastGameWinner == .me }

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // Event label
            Text(isSetEnd ? "SET" : "GAME")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(2)

            // Winner line
            Text(winnerIsMe ? (isSetEnd ? "SET YOU ✓" : "GAME YOU ✓") : (isSetEnd ? "SET THEM" : "GAME THEM"))
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(winnerIsMe ? Color.tAccent : Color.tAlert)

            // Glowing ring
            ZStack {
                Circle()
                    .stroke(winnerIsMe ? Color.tAccent : Color.tAlert, lineWidth: 2)
                    .frame(width: 52, height: 52)
                    .shadow(color: (winnerIsMe ? Color.tAccent : Color.tAlert).opacity(0.4), radius: 8)
                Text(winnerIsMe ? "🏆" : "")
                    .font(.system(size: 22))
            }

            // Score display
            if isSetEnd, let s = match.lastSetScore {
                Text("\(s.mine) – \(s.theirs)")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(winnerIsMe ? Color.tAccent : .white)
                Text("Set \(match.sets.count - 1)")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.tText3)
            } else {
                HStack(spacing: 6) {
                    Text("\(match.sets[match.currentSetIndex].mine)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(Color.tAccent)
                    Text("–")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.tText3)
                    Text("\(match.sets[match.currentSetIndex].theirs)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(.white)
                }
                Text("Games — Set \(match.currentSetIndex + 1)")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.tText3)
            }

            Spacer()
        }
        .background(Color.tBg)
        .onTapGesture { match.phase = .playing }
        .onAppear {
            WKInterfaceDevice.current().play(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                match.phase = .playing
            }
        }
    }
}

// MARK: - Match over

struct MatchOverView: View {
    @EnvironmentObject private var match: MatchStateManager

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("MATCH OVER")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(2)
            Text("Great game!")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color.tAccent)
            Text(match.sets.map { "\($0.mine)–\($0.theirs)" }.joined(separator: "  "))
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.white)
            Text("Syncing to iPhone…")
                .font(.system(size: 10))
                .foregroundStyle(Color.tText2)
                .padding(.top, 8)
            Spacer()
        }
        .background(Color.tBg)
    }
}
