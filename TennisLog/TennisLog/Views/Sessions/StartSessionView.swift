import SwiftUI
import SwiftData

struct StartSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    @Query(sort: \Season.startDate,   order: .reverse) private var seasons: [Season]
    @Query(sort: \Opponent.name)                        private var opponents: [Opponent]
    @Query(sort: \Racket.name)                          private var rackets: [Racket]
    @Query(sort: \Shoe.name)                            private var shoes: [Shoe]

    // Form state
    @State private var sessionType: SessionType = .match
    @State private var surface: Surface = .hard
    @State private var selectedOpponent: Opponent?
    @State private var matchFormat: MatchFormat = .singles
    @State private var selectedRacket: Racket?
    @State private var selectedShoe: Shoe?
    @State private var newOpponentName = ""
    @State private var showNewOpponent = false

    // Post-session state (set after session completes)
    @State private var createdSession: Session?
    @State private var showPostSession = false

    private var activeSeason: Season? { seasons.first(where: \.isActive) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Type selector
                    typeSelector
                        .padding(.top, 12)

                    if sessionType == .match {
                        matchDetailsSection
                    }

                    surfaceSection
                    gearSection
                    startButtons
                }
                .padding(.bottom, 32)
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.tText2)
                }
            }
        }
        .sheet(isPresented: $showPostSession) {
            if let session = createdSession {
                PostSessionRatingView(session: session)
            }
        }
    }

    // MARK: - Type selector

    private var typeSelector: some View {
        HStack(spacing: 8) {
            TypeButton(label: "Match", icon: "🏆", selected: sessionType == .match) {
                sessionType = .match
            }
            TypeButton(label: "Practice", icon: "🎾", selected: sessionType == .practice) {
                sessionType = .practice
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Match details

    private var matchDetailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Match Details")

            // Opponent
            VStack(alignment: .leading, spacing: 6) {
                Menu {
                    ForEach(opponents) { opp in
                        Button(opp.name) { selectedOpponent = opp }
                    }
                    Divider()
                    Button("New opponent…") { showNewOpponent = true }
                } label: {
                    FieldRow(label: "Opponent",
                             value: selectedOpponent?.name ?? "Select…",
                             highlighted: selectedOpponent != nil)
                }

                if showNewOpponent {
                    HStack {
                        TextField("Opponent name", text: $newOpponentName)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.white)
                        Button("Add") { addNewOpponent() }
                            .foregroundStyle(Color.tAccent)
                            .disabled(newOpponentName.isEmpty)
                    }
                    .padding(14)
                    .background(Color.tCard2)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Format
                Menu {
                    ForEach(MatchFormat.allCases, id: \.self) { f in
                        Button(f.rawValue) { matchFormat = f }
                    }
                } label: {
                    FieldRow(label: "Format", value: matchFormat.rawValue)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Surface

    private var surfaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Surface")
            HStack(spacing: 2) {
                ForEach(Surface.allCases, id: \.self) { s in
                    Button(s.rawValue) { surface = s }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(surface == s ? Color.tBg : Color.tText2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(surface == s ? Color.tAccent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
            .padding(3)
            .background(Color.tCard)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Gear

    private var gearSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Gear")
            VStack(spacing: 6) {
                if !rackets.isEmpty {
                    Menu {
                        ForEach(rackets) { r in Button(r.name) { selectedRacket = r } }
                        Button("None") { selectedRacket = nil }
                    } label: {
                        FieldRow(label: "Racket", value: selectedRacket?.name ?? "None",
                                 highlighted: selectedRacket != nil)
                    }
                }
                if !shoes.isEmpty {
                    Menu {
                        ForEach(shoes) { s in Button(s.name) { selectedShoe = s } }
                        Button("None") { selectedShoe = nil }
                    } label: {
                        FieldRow(label: "Shoes", value: selectedShoe?.name ?? "None",
                                 highlighted: selectedShoe != nil)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Start buttons

    private var startButtons: some View {
        VStack(spacing: 8) {
            Button {
                let session = createSession()
                createdSession = session
                dismiss()
                // In a real implementation, this would launch WatchConnectivity session
            } label: {
                Label("Start on Watch", systemImage: "applewatch")
                    .font(.system(size: 14, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(Color.tBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.tAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button {
                let session = createSession()
                createdSession = session
                dismiss()
            } label: {
                Text("Start on iPhone")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.tText2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.tCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .capsLabel()
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 6)
    }

    private func addNewOpponent() {
        guard !newOpponentName.isEmpty else { return }
        let opp = Opponent(name: newOpponentName)
        context.insert(opp)
        selectedOpponent = opp
        newOpponentName = ""
        showNewOpponent = false
    }

    @discardableResult
    private func createSession() -> Session {
        let session = Session(type: sessionType, surface: surface)
        session.season = activeSeason
        session.racketID = selectedRacket?.persistentModelID
        session.shoeID   = selectedShoe?.persistentModelID

        if sessionType == .match {
            let match = Match(format: matchFormat)
            match.opponent = selectedOpponent
            session.match = match
            context.insert(match)
        }

        context.insert(session)
        try? context.save()
        return session
    }
}

// MARK: - Field row

private struct FieldRow: View {
    let label: String
    let value: String
    var highlighted: Bool = false

    var body: some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundStyle(Color.tText2)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(highlighted ? Color.tAccent : .white)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.tText3)
        }
        .padding(14)
        .background(Color.tCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Type button

private struct TypeButton: View {
    let label: String
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(icon).font(.system(size: 32))
                Text(label)
                    .font(.system(size: 13, weight: .black))
                    .tracking(1)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .foregroundStyle(selected ? Color.tBg : .white)
            .background(selected ? Color.tAccent : Color.tCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}
