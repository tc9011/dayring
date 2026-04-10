import SwiftUI
import SwiftData

@main
struct DayRingApp: App {
    private let localeManager = LocaleManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.localeManager, localeManager)
                .task {
                    try? await AlarmScheduler.shared.requestAuthorization()
                }
        }
        .modelContainer(for: [Alarm.self, AppSettings.self])
    }
}
