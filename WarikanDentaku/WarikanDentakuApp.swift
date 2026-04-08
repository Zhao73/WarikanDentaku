import SwiftUI
import SwiftData

@main
struct WarikanDentakuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WarikanRecord.self, PersonResult.self])
    }
}
