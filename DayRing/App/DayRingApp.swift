import SwiftUI
import SwiftData
import UserNotifications

@main
struct DayRingApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
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

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

struct RescheduleAllAlarmsModifier: ViewModifier {
    @Query private var alarms: [Alarm]

    func body(content: Content) -> some View {
        content.task {
            let year = Calendar.current.component(.year, from: Date())
            let provider = HolidayDataProvider()
            let holidays = provider.holidays(for: year)
            let makeupDays = provider.makeupDays(for: year)
            nonisolated(unsafe) let alarmsRef = alarms
            try? await AlarmScheduler.shared.rescheduleAll(alarmsRef, holidays: holidays, makeupDays: makeupDays)
        }
    }
}
