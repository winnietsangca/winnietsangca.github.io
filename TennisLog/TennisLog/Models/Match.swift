import SwiftData
import Foundation

/// Stores one completed tennis match. Points are children; set scores are
/// derived from the points but also cached as a Codable array for fast display.
@Model
final class Match {
    var format: MatchFormat
    var setsData: Data = Data()        // JSON-encoded [MatchSetSnapshot]
    var didWin: Bool?                  // nil until match is complete

    var session: Session?

    @Relationship(deleteRule: .cascade, inverse: \MatchPoint.match)
    var points: [MatchPoint] = []

    @Relationship(deleteRule: .nullify, inverse: \Opponent.matches)
    var opponent: Opponent?

    // MARK: - Computed

    var sets: [MatchSetSnapshot] {
        get { (try? JSONDecoder().decode([MatchSetSnapshot].self, from: setsData)) ?? [] }
        set { setsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var scoreDisplay: String {
        sets.map { "\($0.myGames)–\($0.theirGames)" }.joined(separator: " ")
    }

    // Stats derived from points array
    var myWinners: [MatchPoint] {
        points.filter { $0.winner == .me && $0.shotType?.isMyWinner == true }
    }
    var myErrors: [MatchPoint] {
        points.filter { $0.winner == .them && $0.errorType != nil }
    }
    var aces: [MatchPoint] { points.filter { $0.shotType == .ace } }
    var doubleFaults: [MatchPoint] { points.filter { $0.shotType == .doubleFault } }

    var firstServePercentage: Double? {
        let served = points.filter { $0.winner == .me || $0.errorType != nil }
        guard !served.isEmpty else { return nil }
        let firstIn = served.filter { !$0.serveWasFault }.count
        return Double(firstIn) / Double(served.count)
    }

    init(format: MatchFormat = .singles) {
        self.format = format
    }
}

/// Snapshot of one set's game score (and optional tiebreak points).
struct MatchSetSnapshot: Codable, Identifiable {
    var id = UUID()
    var myGames: Int
    var theirGames: Int
    var isTiebreak: Bool = false
    var isSuperTiebreak: Bool = false
    var tiebreakMyPoints: Int?
    var tiebreakTheirPoints: Int?

    var display: String { "\(myGames)–\(theirGames)" }
}
