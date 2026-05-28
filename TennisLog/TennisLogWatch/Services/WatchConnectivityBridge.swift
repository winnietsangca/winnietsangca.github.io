import WatchConnectivity
import Foundation

/// Sends completed match data from Watch → iPhone.
final class WatchConnectivityBridge: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityBridge()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendMatchResult(points: [RecordedPoint],
                         sets: [(mine: Int, theirs: Int)],
                         winner: PointWinner) {
        guard WCSession.default.isReachable else { return }

        // Encode the match payload as a simple dictionary
        let setsEncoded = sets.map { ["mine": $0.mine, "theirs": $0.theirs] }
        let pointsEncoded = points.map { p -> [String: Any] in
            var d: [String: Any] = [
                "winner": p.winner.rawValue,
                "serveWasFault": p.serveWasFault,
                "setIndex": p.setIndex,
                "gameIndex": p.gameIndex
            ]
            if let s = p.shotType  { d["shotType"]  = s.rawValue }
            if let e = p.errorType { d["errorType"] = e.rawValue }
            return d
        }

        let payload: [String: Any] = [
            WatchMessageKey.matchPayload: [
                "sets":   setsEncoded,
                "points": pointsEncoded,
                "winner": winner.rawValue,
                "timestamp": Date().timeIntervalSince1970
            ]
        ]
        WCSession.default.sendMessage(payload, replyHandler: nil)
    }

    // MARK: - WCSessionDelegate (required stubs)

    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith state: WCSessionActivationState,
                             error: Error?) {}

    nonisolated func session(_ session: WCSession,
                             didReceiveMessage message: [String: Any]) {}
}
