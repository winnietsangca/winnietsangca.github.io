import SwiftData
import Foundation

@Model
final class Session {
    // Core metadata
    var date: Date
    var type: SessionType
    var surface: Surface
    var durationSeconds: Double      // from HealthKit workout
    var heartRateAvg: Double?        // bpm
    var caloriesActive: Double?      // kcal
    var qualityRating: Int?          // 1–5, set post-session
    var notes: String = ""

    // Court / weather
    var locationName: String?
    var weatherTempC: Double?
    var weatherDescription: String?  // e.g. "Partly cloudy"

    // Gear used (by persistent model ID stored as string — avoids SwiftData circular ref)
    var racketID: PersistentIdentifier?
    var shoeID: PersistentIdentifier?

    // Relationships
    var season: Season?

    @Relationship(deleteRule: .cascade, inverse: \Match.session)
    var match: Match?

    // Computed
    var isMatch: Bool { type == .match }

    init(date: Date = .now,
         type: SessionType,
         surface: Surface,
         durationSeconds: Double = 0) {
        self.date = date
        self.type = type
        self.surface = surface
        self.durationSeconds = durationSeconds
    }
}
