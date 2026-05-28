import SwiftUI

/// Shown after "point me" or "point them" in voicePlusTap mode.
/// Auto-dismisses after 8 seconds (records as unclassified).
struct ShotTypeView: View {
    @EnvironmentObject private var match: MatchStateManager
    @State private var countdown = 8
    @State private var timer: Timer?

    private var iWon: Bool { match.pendingPointWinner == .me }

    var body: some View {
        VStack(spacing: 4) {
            // Header
            VStack(spacing: 1) {
                Text(iWon ? "YOUR POINT" : "THEIR POINT")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(iWon ? Color.tAccent : Color.tAlert)
                    .tracking(2)
                Text("How?")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                Text("\(countdown)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.tText3)
            }
            .padding(.top, 14)

            if iWon {
                winnerGrid
            } else {
                errorGrid
            }

            Text(iWon ? "↓ skip = wrist down" : "crown = their winner")
                .font(.system(size: 8))
                .foregroundStyle(Color.tText3)
                .padding(.bottom, 4)
        }
        .background(Color.tBg)
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
        .digitalCrownRotation($countdown, from: 0, through: 8, sensitivity: .low)
        .onChange(of: countdown) { _, v in if v == 0 { match.skipShotEntry() } }
    }

    // MARK: - Grids

    /// 2×2 for when you won: Ace / FH / BH / Vol-OH
    private var winnerGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
            ShotButton(label: "Ace",      color: .tAccent) { record(shot: .ace) }
            ShotButton(label: "FH",       color: .tAccent) { record(shot: .forehandWinner) }
            ShotButton(label: "BH",       color: .tAccent) { record(shot: .backhandWinner) }
            ShotButton(label: "Vol / OH", color: .tAccent) { record(shot: .volleyOverhead) }
        }
        .padding(.horizontal, 8)
    }

    /// 2×2 + 1 wide for when they won: FH Net / FH Out / BH Net / BH Out / Vol-OH
    private var errorGrid: some View {
        VStack(spacing: 5) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                ShotButton(label: "FH Net", color: .tAlert) { record(error: .forehandNet) }
                ShotButton(label: "FH Out", color: .tAlert) { record(error: .forehandOut) }
                ShotButton(label: "BH Net", color: .tAlert) { record(error: .backhandNet) }
                ShotButton(label: "BH Out", color: .tAlert) { record(error: .backhandOut) }
            }
            // Full-width Vol/OH
            Button { record(error: .volleyOverhead) } label: {
                Text("Vol / OH")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color.tAlert)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.tAlert.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.tAlert.opacity(0.35), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Actions

    private func record(shot: ShotType) {
        timer?.invalidate()
        match.completeShotEntry(shotType: shot)
    }

    private func record(error: ErrorType) {
        timer?.invalidate()
        // "Their winner" via crown is handled separately; tap always = my error
        match.completeShotEntry(errorType: error)
    }

    private func startCountdown() {
        countdown = 8
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if self.countdown > 0 { self.countdown -= 1 }
                else { self.match.skipShotEntry() }
            }
        }
    }
}

// MARK: - Shot button

private struct ShotButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(color.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(color.opacity(0.35), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
