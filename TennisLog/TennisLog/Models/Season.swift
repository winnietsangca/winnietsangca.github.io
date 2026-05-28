import SwiftData
import Foundation

@Model
final class Season {
    var name: String
    var startDate: Date
    var endDate: Date?
    var isIndoor: Bool

    @Relationship(deleteRule: .nullify, inverse: \Session.season)
    var sessions: [Session] = []

    var isActive: Bool { endDate == nil }

    var totalPlayHours: Double {
        sessions.reduce(0) { $0 + $1.durationSeconds } / 3600
    }

    var matchSessions: [Session] { sessions.filter { $0.type == .match } }
    var practiceSessions: [Session] { sessions.filter { $0.type == .practice } }

    init(name: String, startDate: Date = .now, isIndoor: Bool = false) {
        self.name = name
        self.startDate = startDate
        self.isIndoor = isIndoor
    }
}
