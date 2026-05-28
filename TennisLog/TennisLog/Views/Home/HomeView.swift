import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var showStartSession: Bool
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query(sort: \Season.startDate, order: .reverse) private var seasons: [Season]
    @Query private var rackets: [Racket]
    @Query private var shoes: [Shoe]

    private var activeSeason: Season? { seasons.first(where: \.isActive) }
    private var lastSession: Session? { sessions.first }

    // Gear that needs attention
    private var alertedRackets: [Racket] { rackets.filter(\.warningSoon) }
    private var alertedShoes: [Shoe]     { shoes.filter(\.warningSoon) }
    private var hasAlerts: Bool { !alertedRackets.isEmpty || !alertedShoes.isEmpty }

    // Streak: consecutive days with a session (most recent first)
    private var currentStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var checkDate = cal.startOfDay(for: .now)
        let sessionDays = Set(sessions.map { cal.startOfDay(for: $0.date) })
        while sessionDays.contains(checkDate) {
            streak += 1
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
        }
        return streak
    }

    private var bestStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        let cal = Calendar.current
        let days = sessions
            .map { cal.startOfDay(for: $0.date) }
            .sorted(by: >)
        var best = 0, cur = 0
        var prev: Date? = nil
        for day in days {
            if let p = prev, cal.dateComponents([.day], from: day, to: p).day == 1 {
                cur += 1
            } else {
                cur = 1
            }
            best = max(best, cur)
            prev = day
        }
        return best
    }

    private var weekDays: [(letter: String, played: Bool, isToday: Bool)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekStart = cal.date(from: cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: today))!
        let sessionDays = Set(sessions.map { cal.startOfDay(for: $0.date) })
        return (0..<7).map { i in
            let d = cal.date(byAdding: .day, value: i, to: weekStart)!
            let letter = String(cal.shortWeekdaySymbols[cal.component(.weekday, from: d) - 1].prefix(1))
            return (letter, sessionDays.contains(d), cal.isDate(d, inSameDayAs: today))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        streakCard
                        if hasAlerts { alertsSection }
                        lastSessionSection
                        Spacer(minLength: 100)
                    }
                }

                // Floating start button
                Button { showStartSession = true } label: {
                    Label("Start Session", systemImage: "plus")
                        .font(.system(size: 15, weight: .900))
                        .tracking(1)
                        .foregroundStyle(Color.tBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(.white)
            if let season = activeSeason {
                Text("\(season.name)  ·  \(season.isIndoor ? "Indoor" : "Outdoor")")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.tText2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let time = hour < 12 ? "morning" : hour < 18 ? "afternoon" : "evening"
        return "Good \(time), Winnie."
    }

    // MARK: - Streak card

    private var streakCard: some View {
        HStack(alignment: .center, spacing: 0) {
            // Number + label
            VStack(alignment: .leading, spacing: 4) {
                Text("\(currentStreak)")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(Color.tAccent)
                    .lineLimit(1)
                Text("DAY STREAK")
                    .capsLabel()
                    .foregroundStyle(Color.tAccent)
                Text("Best: \(bestStreak) days")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.tText2)
                    .padding(.top, 2)
            }

            Spacer()

            // Week dots
            VStack(alignment: .trailing, spacing: 6) {
                Text("THIS WEEK")
                    .capsLabel()
                HStack(spacing: 5) {
                    ForEach(weekDays, id: \.letter) { day in
                        ZStack {
                            Circle()
                                .fill(day.played ? Color.tAccent :
                                      day.isToday ? Color.clear : Color.tCard2)
                                .overlay(
                                    Circle().stroke(day.isToday ? Color.tAccent : Color.clear,
                                                    lineWidth: 2))
                                .frame(width: 28, height: 28)
                            Text(day.letter)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(day.played ? Color.tBg :
                                                 day.isToday ? Color.tAccent : Color.tText3)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.tAccent.opacity(0.12), Color.tAccent.opacity(0.04)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.tAccent.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Alerts

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("GEAR ALERTS")
                .capsLabel()
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ForEach(alertedRackets) { racket in
                GearAlertRow(
                    name: racket.name,
                    detail: "\(racket.statusLabel) · \(racket.hoursDetail) · \(racket.monthsDetail)")
            }
            ForEach(alertedShoes) { shoe in
                GearAlertRow(name: shoe.name, detail: "\(shoe.statusLabel) · \(shoe.wornDetail)")
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Last session

    @ViewBuilder
    private var lastSessionSection: some View {
        Text("LAST SESSION")
            .capsLabel()
            .padding(.horizontal, 20)
            .padding(.top, 8)

        if let session = lastSession {
            NavigationLink(destination: SessionDetailView(session: session)) {
                SessionRowCard(session: session)
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
        } else {
            Text("No sessions yet — tap Start Session to begin.")
                .font(.system(size: 13))
                .foregroundStyle(Color.tText2)
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
    }
}

// MARK: - Sub-views

private struct GearAlertRow: View {
    let name: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                Circle().fill(Color.tAlert).frame(width: 7, height: 7)
                Text(name).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
            }
            Text(detail)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.tAlert)
                .padding(.leading, 15)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tAlert.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.tAlert.opacity(0.3), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
    }
}

struct SessionRowCard: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TypePill(type: session.type)
                Spacer()
                Text(session.date.relativeShort + " · " + session.durationSeconds.hoursMinutesShort)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.tText2)
                if let temp = session.weatherTempC {
                    Text(String(format: "%.0f°C", temp))
                        .font(.system(size: 11))
                        .foregroundStyle(Color.tText2)
                }
            }

            if let match = session.match {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(match.scoreDisplay)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                    if let won = match.didWin {
                        Text(won ? "W" : "L")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(won ? Color.tWin : Color.tLoss)
                    }
                }
                if let opp = match.opponent {
                    Text("vs \(opp.name)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.tText2)
                }
            } else {
                Text("Practice")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tBlue)
            }

            HStack(spacing: 14) {
                if let hr = session.heartRateAvg {
                    StatBit(label: "HR", value: "\(Int(hr))")
                }
                if let cal = session.caloriesActive {
                    StatBit(label: "cal", value: "\(Int(cal))")
                }
                if let rating = session.qualityRating {
                    Text(String(repeating: "★", count: rating) +
                         String(repeating: "☆", count: 5 - rating))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.tAccent)
                }
            }
        }
        .padding(16)
        .tennisCard()
    }
}

private struct TypePill: View {
    let type: SessionType
    var body: some View {
        Text(type.rawValue.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(2)
            .foregroundStyle(type == .match ? Color.tAccent : Color.tBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                (type == .match ? Color.tAccent : Color.tBlue).opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke((type == .match ? Color.tAccent : Color.tBlue).opacity(0.3),
                            lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

private struct StatBit: View {
    let label: String
    let value: String
    var body: some View {
        HStack(spacing: 3) {
            Text(value).font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.tText2)
        }
    }
}
