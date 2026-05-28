import SwiftUI
import SwiftData

@main
struct TennisLogApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Season.self,
                Session.self,
                Match.self,
                MatchPoint.self,
                Opponent.self,
                Racket.self,
                Shoe.self,
            ])
            // Data protection: complete — encrypted at rest, accessible only
            // when device is unlocked.
            let config = ModelConfiguration(
                "TennisLog",
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
