import Testing
import Foundation
@testable import DayRing

@Suite("Notification Fallback Tests")
struct NotificationFallbackTests {

    private let calendar = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    @Test("Notification content includes alarm label as title")
    func notificationContentHasLabel() {
        let alarm = Alarm(hour: 7, minute: 0, label: "Morning")
        let content = NotificationFallbackScheduler.makeNotificationContent(for: alarm)

        #expect(content.title == "Morning")
        #expect(content.sound != nil)
    }

    @Test("Notification content uses app name when label is empty")
    func notificationContentEmptyLabel() {
        let alarm = Alarm(hour: 7, minute: 0, label: "")
        let content = NotificationFallbackScheduler.makeNotificationContent(for: alarm)

        #expect(content.title == "该起了")
        #expect(content.sound != nil)
    }

    @Test("Notification content interruption level is timeSensitive")
    func notificationContentTimeSensitive() {
        let alarm = Alarm(hour: 7, minute: 0)
        let content = NotificationFallbackScheduler.makeNotificationContent(for: alarm)

        #expect(content.interruptionLevel == .timeSensitive)
    }

    @Test("Trigger components use effective time with advance minutes")
    func triggerComponentsWithAdvance() {
        let ringDate = date(2026, 4, 10)
        let components = NotificationFallbackScheduler.makeTriggerComponents(
            ringDate: ringDate,
            effectiveHour: 6,
            effectiveMinute: 45
        )

        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 10)
        #expect(components.hour == 6)
        #expect(components.minute == 45)
    }

    @Test("Trigger components use exact alarm time when no advance")
    func triggerComponentsNoAdvance() {
        let ringDate = date(2026, 4, 10)
        let components = NotificationFallbackScheduler.makeTriggerComponents(
            ringDate: ringDate,
            effectiveHour: 12,
            effectiveMinute: 30
        )

        #expect(components.hour == 12)
        #expect(components.minute == 30)
    }

    @Test("Notification request ID includes alarm ID and date")
    func requestIdFormat() {
        let alarm = Alarm(hour: 7, minute: 0)
        let ringDate = date(2026, 4, 10)
        let requestId = NotificationFallbackScheduler.makeRequestIdentifier(alarmId: alarm.id, ringDate: ringDate)

        #expect(requestId.contains(alarm.id.uuidString))
        #expect(requestId.contains("2026-04-10"))
    }

    @Test("Different dates produce different request IDs for same alarm")
    func requestIdUniqueness() {
        let alarm = Alarm(hour: 7, minute: 0)
        let date1 = date(2026, 4, 10)
        let date2 = date(2026, 4, 11)

        let id1 = NotificationFallbackScheduler.makeRequestIdentifier(alarmId: alarm.id, ringDate: date1)
        let id2 = NotificationFallbackScheduler.makeRequestIdentifier(alarmId: alarm.id, ringDate: date2)

        #expect(id1 != id2)
    }

    @Test("Cancel prefix matches alarm ID for removing all notifications")
    func cancelPrefixMatchesAlarmId() {
        let alarm = Alarm(hour: 7, minute: 0)
        let prefix = NotificationFallbackScheduler.cancelPrefix(for: alarm.id)
        let requestId = NotificationFallbackScheduler.makeRequestIdentifier(alarmId: alarm.id, ringDate: date(2026, 4, 10))

        #expect(requestId.hasPrefix(prefix))
    }

    @Test("Cancel prefix does not match other alarm IDs")
    func cancelPrefixDoesNotMatchOthers() {
        let alarm1 = Alarm(hour: 7, minute: 0)
        let alarm2 = Alarm(hour: 8, minute: 0)
        let prefix1 = NotificationFallbackScheduler.cancelPrefix(for: alarm1.id)
        let requestId2 = NotificationFallbackScheduler.makeRequestIdentifier(alarmId: alarm2.id, ringDate: date(2026, 4, 10))

        #expect(!requestId2.hasPrefix(prefix1))
    }
}
