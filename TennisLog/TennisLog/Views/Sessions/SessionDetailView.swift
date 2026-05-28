import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                if let match = session.match { matchCard(match) }
                healthCard
                if let match = session.match, !match.points.isEmpty { statsCard(match) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.tBg.ignoresSafeArea())
        .navigationTitle(session.date.formatted(.dateTime.weekday().month().day()))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SessionRowCard.TypePillInline(type: session.type)
                Spacer()
                Text(session.surface.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.tText2)
            }
            if let weather = session.weatherDescription, let temp = session.weatherTempC {
                Text("\(weather)  \(String(format: "%.0f", temp))°C")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.tText2)
            }
            // Quality rating
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        session.qualityRating = (session.qualityRating == i) ? nil : i
                        try? context.save()
                    } label: {
                        Text(i <= (session.qualityRating ?? 0) ? "★" : "☆")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.tAccent)
                    }
                }
                Text("Session quality")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.tText2)
                    .padding(.leading, 4)
            }
        }
        .padding(16)
        .tennisCard()
    }

    private func matchCard(_ match: Match) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MATCH").capsLabel()

            if let opp = match.opponent {
                HStack {
                    Text("vs \(opp.name)")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text(opp.recordDisplay)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.tText2)
                }
            }

            // Sets
            HStack(spacing: 16) {
                ForEach(match.sets) { s in
                    VStack(spacing: 2) {
                        Text(s.display)
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.white)
                        if s.isTiebreak || s.isSuperTiebreak {
                            Text(s.isSuperTiebreak ? "Super TB" : "TB")
                                .capsLabel()
                        }
                    }
                }
            }

            if let won = match.didWin {
                Text(won ? "Won ✓" : "Lost")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(won ? Color.tWin : Color.tLoss)
            }
        }
        .padding(16)
        .tennisCard()
    }

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HEALTH").capsLabel()
            HStack(spacing: 24) {
                HealthStat(label: "Duration",   value: session.durationSeconds.hoursMinutesShort)
                if let hr = session.heartRateAvg {
                    HealthStat(label: "Avg HR",  value: "\(Int(hr)) bpm")
                }
                if let cal = session.caloriesActive {
                    HealthStat(label: "Calories", value: "\(Int(cal)) kcal")
                }
            }
        }
        .padding(16)
        .tennisCard()
    }

    private func statsCard(_ match: Match) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATS").capsLabel()
            StatRow(label: "My winners",      value: "\(match.myWinners.count)")
            StatRow(label: "My errors",        value: "\(match.myErrors.count)")
            StatRow(label: "Aces",             value: "\(match.aces.count)")
            StatRow(label: "Double faults",    value: "\(match.doubleFaults.count)")
            if let pct = match.firstServePercentage {
                StatRow(label: "1st serve %", value: "\(Int(pct * 100))%")
            }
        }
        .padding(16)
        .tennisCard()
    }
}

private struct HealthStat: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.system(size: 18, weight: .black)).foregroundStyle(.white)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.tText2)
        }
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Color.tText2)
            Spacer()
            Text(value).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
        }
    }
}

// Expose TypePill for reuse from SessionsView
extension SessionRowCard {
    struct TypePillInline: View {
        let type: SessionType
        var body: some View {
            Text(type.rawValue.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundStyle(type == .match ? Color.tAccent : Color.tBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background((type == .match ? Color.tAccent : Color.tBlue).opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke((type == .match ? Color.tAccent : Color.tBlue).opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }
}
