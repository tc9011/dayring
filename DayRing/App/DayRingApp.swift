import SwiftUI
import SwiftData

@main
struct DayRingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Alarm.self, AppSettings.self])
    }
}
