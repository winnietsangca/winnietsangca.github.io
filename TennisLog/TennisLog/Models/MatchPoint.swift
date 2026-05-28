import SwiftData
import Foundation

@Model
final class MatchPoint {
    var timestamp: Date
    var winner: PointWinner

    // Shot classification (nil = unclassified / skipped)
    var shotType: ShotType?    // set when winner == .me
    var errorType: ErrorType?  // set when winner == .them (my error)

    // Serve state
    var serveWasFault: Bool    // first serve was a fault → this was a second serve point
    var setIndex: Int
    var gameIndex: Int         // cumulative game number within match

    var match: Match?

    init(winner: PointWinner,
         shotType: ShotType? = nil,
         errorType: ErrorType? = nil,
         serveWasFault: Bool = false,
         setIndex: Int = 0,
         gameIndex: Int = 0) {
        self.timestamp = .now
        self.winner = winner
        self.shotType = shotType
        self.errorType = errorType
        self.serveWasFault = serveWasFault
        self.setIndex = setIndex
        self.gameIndex = gameIndex
    }
}
