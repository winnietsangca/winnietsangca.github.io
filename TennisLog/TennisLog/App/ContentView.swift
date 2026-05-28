import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showStartSession = false

    enum Tab { case home, sessions, gear, stats }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showStartSession: $showStartSession)
                .tabItem { Label("Home",     systemImage: "house.fill") }
                .tag(Tab.home)

            SessionsView()
                .tabItem { Label("Sessions", systemImage: "clock.fill") }
                .tag(Tab.sessions)

            GearView()
                .tabItem { Label("Gear",     systemImage: "circle.fill") }
                .tag(Tab.gear)

            StatsView()
                .tabItem { Label("Stats",    systemImage: "chart.line.uptrend.xyaxis") }
                .tag(Tab.stats)
        }
        .tint(.tAccent)
        .background(Color.tBg)
        .sheet(isPresented: $showStartSession) {
            StartSessionView()
        }
    }
}
