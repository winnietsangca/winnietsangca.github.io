import SwiftUI

/// Shown after "fault" is called — tells the player they're on 2nd serve,
/// then returns to the score screen after a tap or 3 seconds.
struct FaultView: View {
    @EnvironmentObject private var match: MatchStateManager

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("SERVE")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(2)
            Text("FAULT")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(Color.tAlert)
            Text("→ 2nd serve")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.tText2)

            Divider()
                .background(Color.tCard2)
                .padding(.horizontal, 20)
                .padding(.vertical, 4)

            Text("POINT")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(2)
            HStack(spacing: 6) {
                Text(match.myPointDisplay)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.tAccent)
                Text("–")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.tText3)
                Text(match.theirPointDisplay)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .background(Color.tBg)
        .onTapGesture { match.confirmFaultDismissed() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                match.confirmFaultDismissed()
            }
        }
    }
}
