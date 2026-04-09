import Foundation
#if canImport(AlarmKit)
import AlarmKit
typealias SystemAlarm = AlarmKit.Alarm
#endif

protocol AlarmScheduling: Sendable {
    func scheduleAlarm(_ alarm: Alarm, holidays: Set<String>, makeupDays: Set<String>) async throws
    func cancelAlarm(_ alarmID: UUID) async throws
    func rescheduleAll(_ alarms: [Alarm], holidays: Set<String>, makeupDays: Set<String>) async throws
}

final class AlarmScheduler: @unchecked Sendable, AlarmScheduling {

    static let shared = AlarmScheduler()

    private let calculator = AlarmScheduleCalculator()
    private let scheduleDaysAhead = 7

    private init() {}

    func scheduleAlarm(_ alarm: Alarm, holidays: Set<String>, makeupDays: Set<String>) async throws {
        try await cancelAlarm(alarm.id)

        guard alarm.isEnabled else { return }

        let ringDates = calculator.nextRingDates(
            for: alarm,
            from: Date(),
            count: scheduleDaysAhead,
            holidays: holidays,
            makeupDays: makeupDays
        )

        let (effectiveHour, effectiveMinute) = calculator.effectiveTime(for: alarm)

        #if canImport(AlarmKit)
        let manager = AlarmManager.shared
        for ringDate in ringDates {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: ringDate)
            components.hour = effectiveHour
            components.minute = effectiveMinute

            guard let fireDate = calendar.date(from: components) else { continue }

            let schedule = SystemAlarm.Schedule.fixed(fireDate)
            let stopButton = AlarmButton(
                text: "Stop",
                textColor: .white,
                systemImageName: "stop.fill"
            )
            let presentation = AlarmPresentation(
                alert: AlarmPresentation.Alert(title: "\(alarm.label)", stopButton: stopButton)
            )
            let attributes = AlarmAttributes<DayRingAlarmMetadata>(
                presentation: presentation,
                metadata: DayRingAlarmMetadata(label: alarm.label),
                tintColor: .accentColor
            )
            let configuration = AlarmManager.AlarmConfiguration.alarm(
                schedule: schedule,
                attributes: attributes
            )
            _ = try await manager.schedule(id: alarm.id, configuration: configuration)
        }
        #else
        _ = effectiveHour
        _ = effectiveMinute
        _ = ringDates
        #endif
    }

    func cancelAlarm(_ alarmID: UUID) async throws {
        #if canImport(AlarmKit)
        let manager = AlarmManager.shared
        try manager.cancel(id: alarmID)
        #endif
    }

    func rescheduleAll(_ alarms: [Alarm], holidays: Set<String>, makeupDays: Set<String>) async throws {
        for alarm in alarms {
            try await scheduleAlarm(alarm, holidays: holidays, makeupDays: makeupDays)
        }
    }

    func requestAuthorization() async throws {
        #if canImport(AlarmKit)
        let manager = AlarmManager.shared
        _ = try await manager.requestAuthorization()
        #endif
    }
}

#if canImport(AlarmKit)
struct DayRingAlarmMetadata: AlarmKit.AlarmMetadata, Codable, Hashable {
    var label: String = ""
}
#endif
