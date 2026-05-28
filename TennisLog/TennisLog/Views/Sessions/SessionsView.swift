import SwiftUI
import SwiftData

struct SessionsView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @State private var filterType: SessionType? = nil

    var filtered: [Session] {
        guard let t = filterType else { return sessions }
        return sessions.filter { $0.type == t }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All",      selected: filterType == nil)  { filterType = nil }
                        FilterChip(label: "Matches",  selected: filterType == .match)    { filterType = .match }
                        FilterChip(label: "Practice", selected: filterType == .practice) { filterType = .practice }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if filtered.isEmpty {
                    Spacer()
                    Text("No sessions yet")
                        .foregroundStyle(Color.tText2)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filtered) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionRowCard(session: session)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct FilterChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(selected ? Color.tBg : Color.tText2)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.tAccent : Color.tCard)
                .clipShape(Capsule())
        }
    }
}
