import Foundation

extension Date {
    var shortDay: String {
        formatted(.dateTime.weekday(.abbreviated))
    }

    var dayMonth: String {
        formatted(.dateTime.day().month(.abbreviated))
    }

    var relativeShort: String {
        let cal = Calendar.current
        if cal.isDateInToday(self)     { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let days = cal.dateComponents([.day], from: self, to: .now).day ?? 0
        if days < 7 { return "\(days)d ago" }
        return dayMonth
    }

    /// "3 months ago" or "2 weeks ago"
    var relativeVerbose: String {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: self, to: .now).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        if days < 7  { return "\(days) days ago" }
        let weeks = days / 7
        if weeks < 5 { return "\(weeks) week\(weeks == 1 ? "" : "s") ago" }
        let months = days / 30
        return "\(months) month\(months == 1 ? "" : "s") ago"
    }

    /// Hours since this date as a decimal, e.g. 1.5 = 1h 30m
    func hoursSince(_ other: Date) -> Double {
        other.timeIntervalSince(self) / 3600
    }
}

extension TimeInterval {
    var hoursMinutesShort: String {
        let h = Int(self) / 3600
        let m = (Int(self) % 3600) / 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
}
