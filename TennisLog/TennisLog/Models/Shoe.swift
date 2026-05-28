import SwiftData
import Foundation

@Model
final class Shoe {
    var name: String
    var brand: String
    var surface: Surface
    var dateAdded: Date
    var hourLimit: Double    // e.g. 60.0
    var hoursWorn: Double = 0

    // MARK: - Computed

    var wornFraction: Double {
        guard hourLimit > 0 else { return 0 }
        return min(hoursWorn / hourLimit, 1)
    }

    var needsReplacement: Bool { wornFraction >= 1.0 }
    var warningSoon: Bool      { wornFraction >= 0.90 }

    var statusLabel: String {
        if needsReplacement { return "Replace" }
        if warningSoon      { return "Replace Soon" }
        return "Good"
    }

    var wornDetail: String {
        "\(String(format: "%.1f", hoursWorn))h of \(String(format: "%.0f", hourLimit))h"
    }

    init(name: String,
         brand: String = "",
         surface: Surface = .hard,
         dateAdded: Date = .now,
         hourLimit: Double = 60) {
        self.name = name
        self.brand = brand
        self.surface = surface
        self.dateAdded = dateAdded
        self.hourLimit = hourLimit
    }
}
