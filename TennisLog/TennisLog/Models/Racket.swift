import SwiftData
import Foundation

@Model
final class Racket {
    var name: String
    var brand: String
    var stringName: String
    var tensionLbs: Int
    var lastRestrungDate: Date
    var hourLimit: Double    // e.g. 25.0
    var monthLimit: Int      // e.g. 3

    // Cached hours — updated each time a session using this racket is saved
    var hoursPlayedSinceRestring: Double = 0

    // MARK: - Computed

    var hoursFraction: Double {
        guard hourLimit > 0 else { return 0 }
        return min(hoursPlayedSinceRestring / hourLimit, 1)
    }

    var monthsSinceRestring: Double {
        let days = Calendar.current.dateComponents([.day], from: lastRestrundDate, to: .now).day ?? 0
        return Double(days) / 30.44
    }

    var monthFraction: Double {
        guard monthLimit > 0 else { return 0 }
        return min(monthsSinceRestring / Double(monthLimit), 1)
    }

    /// Whichever threshold is closer to being exceeded
    var warnFraction: Double { max(hoursFraction, monthFraction) }

    var needsRestring: Bool { warnFraction >= 1.0 }
    var warningSoon: Bool   { warnFraction >= 0.80 }

    var statusLabel: String {
        if needsRestring { return "Restring" }
        if warningSoon   { return "Soon" }
        return "Good"
    }

    var hoursDetail: String {
        "\(String(format: "%.0f", hoursPlayedSinceRestring))h of \(String(format: "%.0f", hourLimit))h"
    }

    var monthsDetail: String {
        "\(String(format: "%.1f", monthsSinceRestring)) of \(monthLimit) months"
    }

    private var lastRestrundDate: Date { lastRestrungDate }

    init(name: String,
         brand: String = "",
         stringName: String = "",
         tensionLbs: Int = 55,
         lastRestrungDate: Date = .now,
         hourLimit: Double = 25,
         monthLimit: Int = 3) {
        self.name = name
        self.brand = brand
        self.stringName = stringName
        self.tensionLbs = tensionLbs
        self.lastRestrungDate = lastRestrungDate
        self.hourLimit = hourLimit
        self.monthLimit = monthLimit
    }
}
