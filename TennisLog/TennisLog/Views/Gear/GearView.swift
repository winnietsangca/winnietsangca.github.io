import SwiftUI
import SwiftData

struct GearView: View {
    @Query(sort: \Racket.name) private var rackets: [Racket]
    @Query(sort: \Shoe.name)   private var shoes: [Shoe]

    @State private var showAddRacket = false
    @State private var showAddShoe   = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    gearSection(title: "Rackets", isEmpty: rackets.isEmpty, addAction: { showAddRacket = true }) {
                        ForEach(rackets) { r in
                            NavigationLink(destination: RacketDetailView(racket: r)) {
                                GearItemRow(
                                    name: r.name,
                                    detail: "\(r.stringName)  ·  \(r.tensionLbs) lbs",
                                    fraction: r.warnFraction,
                                    barLabel: r.hoursDetail,
                                    badgeLabel: r.statusLabel,
                                    isWarning: r.warningSoon)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    gearSection(title: "Shoes", isEmpty: shoes.isEmpty, addAction: { showAddShoe = true }) {
                        ForEach(shoes) { s in
                            NavigationLink(destination: ShoeDetailView(shoe: s)) {
                                GearItemRow(
                                    name: s.name,
                                    detail: "\(s.surface.rawValue) court  ·  Added \(s.dateAdded.dayMonth)",
                                    fraction: s.wornFraction,
                                    barLabel: s.wornDetail,
                                    badgeLabel: s.statusLabel,
                                    isWarning: s.warningSoon)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("My Gear")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddRacket) { AddRacketView() }
            .sheet(isPresented: $showAddShoe)   { AddShoeView() }
        }
    }

    @ViewBuilder
    private func gearSection<Content: View>(
        title: String,
        isEmpty: Bool,
        addAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).capsLabel()
                Spacer()
                Button(action: addAction) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.tAccent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 4)

            if isEmpty {
                Button(action: addAction) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add \(title.dropLast())")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.tText3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundStyle(Color.tCard2))
                    .padding(.horizontal, 16)
                }
            } else {
                content()
            }
        }
    }
}

// MARK: - Gear item row

struct GearItemRow: View {
    let name: String
    let detail: String
    let fraction: Double
    let barLabel: String
    let badgeLabel: String
    let isWarning: Bool

    private var barColor: Color {
        fraction >= 1.0 ? Color.tAlert :
        fraction >= 0.8 ? Color.tAlert :
        fraction >= 0.5 ? Color.tAccent : Color.tWin
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    Text(detail).font(.system(size: 11)).foregroundStyle(Color.tText2)
                }
                Spacer()
                Text(badgeLabel)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(isWarning ? Color.tAlert : Color.tWin)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background((isWarning ? Color.tAlert : Color.tWin).opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke((isWarning ? Color.tAlert : Color.tWin).opacity(0.3), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.tCard2)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(barColor)
                        .frame(width: geo.size.width * fraction, height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text(barLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(isWarning ? Color.tAlert : Color.tText2)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.tText3)
            }
        }
        .padding(15)
        .tennisCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
}
