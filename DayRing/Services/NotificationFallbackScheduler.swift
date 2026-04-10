import Foundation
import UserNotifications

struct NotificationFallbackScheduler: Sendable {

    static func makeNotificationContent(for alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "该起了" : alarm.label
        content.body = String(format: "%02d:%02d", alarm.hour, alarm.minute)
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        return content
    }

    static func makeTriggerComponents(
        ringDate: Date,
        effectiveHour: Int,
        effectiveMinute: Int
    ) -> DateComponents {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: ringDate)
        components.hour = effectiveHour
        components.minute = effectiveMinute
        return components
    }

    static func makeRequestIdentifier(alarmId: UUID, ringDate: Date) -> String {
        "\(alarmId.uuidString)-\(Alarm.dateKey(for: ringDate))"
    }

    static func cancelPrefix(for alarmId: UUID) -> String {
        "\(alarmId.uuidString)-"
    }

    static func schedule(
        alarm: Alarm,
        ringDates: [Date],
        effectiveHour: Int,
        effectiveMinute: Int
    ) async throws {
        let center = UNUserNotificationCenter.current()
        let content = makeNotificationContent(for: alarm)

        for ringDate in ringDates {
            let components = makeTriggerComponents(
                ringDate: ringDate,
                effectiveHour: effectiveHour,
                effectiveMinute: effectiveMinute
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let requestId = makeRequestIdentifier(alarmId: alarm.id, ringDate: ringDate)
            let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
            try await center.add(request)
        }
    }

    static func cancel(alarmId: UUID) async {
        let center = UNUserNotificationCenter.current()
        let prefix = cancelPrefix(for: alarmId)
        let pending = await center.pendingNotificationRequests()
        let matchingIds = pending.filter { $0.identifier.hasPrefix(prefix) }.map(\.identifier)
        if !matchingIds.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: matchingIds)
        }
    }

    static func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
}
