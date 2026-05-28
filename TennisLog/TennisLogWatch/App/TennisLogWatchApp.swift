import SwiftUI

@main
struct TennisLogWatchApp: App {
    @StateObject private var matchState = MatchStateManager()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(matchState)
        }
    }
}

struct WatchRootView: View {
    @EnvironmentObject private var matchState: MatchStateManager

    var body: some View {
        switch matchState.phase {
        case .playing:
            MatchScoreView()
        case .awaitingShotType:
            ShotTypeView()
        case .faultCalled:
            FaultView()
        case .gameOver, .setOver:
            GameEndView()
        case .matchOver:
            MatchOverView()
        }
    }
}
