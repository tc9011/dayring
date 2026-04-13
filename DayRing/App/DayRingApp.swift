import SwiftUI
import SwiftData
import UserNotifications
import os.log

private let logger = Logger(subsystem: "com.dayring.app", category: "AppLifecycle")

@main
struct DayRingApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    private let localeManager = LocaleManager.shared
    let container: ModelContainer

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Alarm.self, AppSettings.self)
        } catch {
            logger.error("ModelContainer failed, destroying store and retrying: \(error.localizedDescription)")
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)
            container = try! ModelContainer(for: Alarm.self, AppSettings.self)
        }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<AppSettings>()
        let all = (try? context.fetch(descriptor)) ?? []
        if all.isEmpty {
            context.insert(AppSettings())
            try? context.save()
        } else if all.count > 1 {
            for extra in all.dropFirst() {
                context.delete(extra)
            }
            try? context.save()
        }
        self.container = container
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.localeManager, localeManager)
                .task {
                    do {
                        try await AlarmScheduler.shared.requestAuthorization()
                        logger.info("Alarm authorization granted")
                    } catch {
                        logger.error("Alarm authorization failed: \(error.localizedDescription)")
                    }
                }
        }
        .modelContainer(container)
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
            do {
                try await AlarmScheduler.shared.rescheduleAll(alarmsRef, holidays: holidays, makeupDays: makeupDays)
                logger.info("Rescheduled \(alarmsRef.count) alarm(s) on launch")
            } catch {
                logger.error("rescheduleAll failed: \(error.localizedDescription)")
            }
        }
    }
}
