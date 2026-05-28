import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \Season.startDate, order: .reverse) private var seasons: [Season]
    @Query(sort: \Opponent.name)                      private var opponents: [Opponent]

    @State private var selectedSeasonIndex = 0

    private var activeSeason: Season? {
        guard !seasons.isEmpty else { return nil }
        return seasons[min(selectedSeasonIndex, seasons.count - 1)]
    }

    private var matches: [Match]   { activeSeason?.matchSessions.compactMap(\.match) ?? [] }
    private var wins: Int          { matches.filter { $0.didWin == true }.count }
    private var losses: Int        { matches.filter { $0.didWin == false }.count }
    private var totalHours: Double { activeSeason?.totalPlayHours ?? 0 }
    private var sessionCount: Int  { activeSeason?.sessions.count ?? 0 }
    private var winRate: Double?   { (wins + losses) > 0 ? Double(wins) / Double(wins + losses) : nil }

    // Error analysis across all match points in selected season
    private var allPoints: [MatchPoint] {
        matches.flatMap(\.points)
    }
    private var myErrors: [MatchPoint] { allPoints.filter { $0.winner == .them && $0.errorType != nil } }
    private var forehandErrors: Int    { myErrors.filter { $0.errorType == .forehandNet || $0.errorType == .forehandOut }.count }
    private var backhandErrors: Int    { myErrors.filter { $0.errorType == .backhandNet || $0.errorType == .backhandOut }.count }
    private var forehandNetErrors: Int { myErrors.filter { $0.errorType == .forehandNet }.count }
    private var forehandOutErrors: Int { myErrors.filter { $0.errorType == .forehandOut }.count }
    private var backhandNetErrors: Int { myErrors.filter { $0.errorType == .backhandNet }.count }
    private var backhandOutErrors: Int { myErrors.filter { $0.errorType == .backhandOut }.count }

    private var aces: Int         { allPoints.filter { $0.shotType == .ace }.count }
    private var dfs: Int          { allPoints.filter { $0.shotType == .doubleFault }.count }
    private var firstServeIn: Int { allPoints.filter { !$0.serveWasFault }.count }
    private var totalServes: Int  { allPoints.count }
    private var firstServePct: Double? {
        guard totalServes > 0 else { return nil }
        return Double(firstServeIn) / Double(totalServes)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if seasons.isEmpty {
                        emptyState
                    } else {
                        seasonPicker
                        summaryGrid
                        winLossBar
                        opponentsSection
                        errorSection
                        serveSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 60)
            Text("No seasons yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.tText2)
            Text("Create a season to start tracking stats.")
                .font(.system(size: 13))
                .foregroundStyle(Color.tText3)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var seasonPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(seasons.indices, id: \.self) { i in
                    Button { selectedSeasonIndex = i } label: {
                        Text(seasons[i].name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selectedSeasonIndex == i ? Color.tBg : Color.tText2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedSeasonIndex == i ? Color.tAccent : Color.tCard)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var summaryGrid: some View {
        HStack(spacing: 8) {
            StatBox(value: String(format: "%.0f", totalHours), label: "Hours", color: .tAccent)
            StatBox(value: "\(sessionCount)", label: "Sessions", color: .white)
            if let wr = winRate {
                StatBox(value: "\(Int(wr * 100))%", label: "Win Rate", color: .tWin)
            }
        }
    }

    private var winLossBar: some View {
        HStack(spacing: 2) {
            VStack(spacing: 4) {
                Text("\(wins)")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(Color.tWin)
                Text("WINS").capsLabel()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.tWin.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 4) {
                Text("\(losses)")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(Color.tLoss)
                Text("LOSSES").capsLabel()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.tLoss.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var opponentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VS. OPPONENTS").capsLabel()
            let activeOpponents = opponents.filter { !$0.matches.isEmpty }
            if activeOpponents.isEmpty {
                Text("No matches recorded yet")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.tText3)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tennisCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(activeOpponents) { opp in
                        HStack {
                            Text(opp.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            HStack(spacing: 2) {
                                Text("\(opp.wins)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.tWin)
                                Text("–")
                                    .foregroundStyle(Color.tText3)
                                Text("\(opp.losses)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.tLoss)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        if opp.id != activeOpponents.last?.id {
                            Divider().background(Color.tCard2).padding(.horizontal, 16)
                        }
                    }
                }
                .tennisCard()
            }
        }
    }

    private var errorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MY UNFORCED ERRORS").capsLabel()
            if myErrors.isEmpty {
                Text("No error data yet — log matches with shot tracking to see breakdown.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.tText3)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tennisCard()
            } else {
                VStack(spacing: 10) {
                    let total = Double(forehandErrors + backhandErrors)
                    ErrorBar(type: "Forehand", count: forehandErrors, total: total,
                             netPct: forehandErrors > 0 ? Double(forehandNetErrors)/Double(forehandErrors) : 0)
                    ErrorBar(type: "Backhand", count: backhandErrors, total: total,
                             netPct: backhandErrors > 0 ? Double(backhandNetErrors)/Double(backhandErrors) : 0)
                }
                .padding(16)
                .tennisCard()
            }
        }
    }

    private var serveSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SERVE").capsLabel()
            VStack(spacing: 0) {
                if let pct = firstServePct {
                    ServeRow(label: "1st serve %", value: "\(Int(pct * 100))%", accent: true)
                    Divider().background(Color.tCard2).padding(.horizontal, 16)
                }
                ServeRow(label: "Aces",         value: "\(aces)")
                Divider().background(Color.tCard2).padding(.horizontal, 16)
                ServeRow(label: "Double faults", value: "\(dfs)")
            }
            .tennisCard()
        }
    }
}

// MARK: - Sub-views

private struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 30, weight: .black)).foregroundStyle(color)
            Text(label).capsLabel()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .tennisCard()
    }
}

private struct ErrorBar: View {
    let type: String
    let count: Int
    let total: Double
    let netPct: Double

    private var fraction: Double { total > 0 ? Double(count) / total : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(type).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.tText2)
                Spacer()
                Text("\(Int(fraction * 100))%").font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                Text("(net \(Int(netPct * 100))%  out \(Int((1 - netPct) * 100))%)")
                    .font(.system(size: 10)).foregroundStyle(Color.tText3)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.tCard2).frame(height: 4)
                    Capsule().fill(Color.tAccent).frame(width: geo.size.width * fraction, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

private struct ServeRow: View {
    let label: String
    let value: String
    var accent = false
    var body: some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Color.tText2)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold))
                .foregroundStyle(accent ? Color.tAccent : .white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
