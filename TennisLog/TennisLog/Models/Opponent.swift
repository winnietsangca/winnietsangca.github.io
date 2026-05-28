import SwiftData
import Foundation

@Model
final class Opponent {
    var name: String
    var matches: [Match] = []

    var wins: Int   { matches.filter { $0.didWin == true }.count }
    var losses: Int { matches.filter { $0.didWin == false }.count }
    var winRate: Double? {
        let played = wins + losses
        guard played > 0 else { return nil }
        return Double(wins) / Double(played)
    }

    var recordDisplay: String { "\(wins)–\(losses)" }

    init(name: String) {
        self.name = name
    }
}
