import Foundation
import Observation

@Observable
final class AlarmListViewModel {
    var alarms: [Alarm] = []
    var showingEditor = false
    var editingAlarm: Alarm?

    private let holidayProvider = HolidayDataProvider()

    func nextAlarmText() -> String? {
        let now = Date()
        guard let next = alarms.first(where: { $0.isEnabled }) else { return nil }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = next.hour
        components.minute = next.minute

        guard let nextTime = calendar.date(from: components) else { return nil }
        let target = nextTime > now ? nextTime : calendar.date(byAdding: .day, value: 1, to: nextTime)!

        let l = LocaleManager.shared
        let diff = calendar.dateComponents([.hour, .minute], from: now, to: target)
        if let h = diff.hour, let m = diff.minute {
            let prefix = l.localizedString("下一个闹钟将在")
            let hourPart = " \(h)" + l.localizedString("小时")
            let minutePart = "\(m)" + l.localizedString("分钟")
            let suffix = " " + l.localizedString("后响铃")
            return prefix + hourPart + minutePart + suffix
        }
        return nil
    }

    func statusInfo(for alarm: Alarm) -> (text: String, color: StatusColor) {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        let l = LocaleManager.shared

        guard alarm.isEnabled else {
            return (l.localizedString("已关闭"), .gray)
        }

        if let skipDate = alarm.skipNextDate {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: calendar.startOfDay(for: skipDate)).day ?? 0
            if days == 1 {
                return (l.localizedString("已跳过明天"), .orange)
            } else {
                return (l.localizedString("已跳过") + "\(days)" + l.localizedString("天后的响铃"), .orange)
            }
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let tomorrowKey = Alarm.dateKey(for: tomorrow)
        if let name = holidayProvider.holidayName(for: tomorrowKey, year: year),
           alarm.skipHolidays {
            return (l.localizedString("后天响铃 · 明天为") + name, .orange)
        }

        if alarm.shouldRing(on: tomorrow, holidays: holidays, makeupDays: makeupDays) {
            return (l.localizedString("明天响铃"), .green)
        } else {
            return (l.localizedString("明天不响铃"), .red)
        }
    }

    func skipNext(_ alarm: Alarm) {
        if alarm.skipNextDate != nil {
            alarm.skipNextDate = nil
        } else if let nextDate = nextRingDate(for: alarm) {
            alarm.skipNextDate = nextDate
        }
        alarm.updatedAt = Date()
        rescheduleAlarm(alarm)
    }

    func isSkipActive(_ alarm: Alarm) -> Bool {
        alarm.skipNextDate != nil
    }

    private func nextRingDate(for alarm: Alarm) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)

        var current = calendar.date(byAdding: .day, value: 1, to: today)!
        for _ in 0..<365 {
            let saved = alarm.skipNextDate
            alarm.skipNextDate = nil
            let wouldRing = alarm.shouldRing(on: current, holidays: holidays, makeupDays: makeupDays)
            alarm.skipNextDate = saved
            if wouldRing { return current }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return nil
    }

    func toggleAlarm(_ alarm: Alarm) {
        alarm.isEnabled.toggle()
        alarm.updatedAt = Date()
        rescheduleAlarm(alarm)
    }

    private func rescheduleAlarm(_ alarm: Alarm) {
        let year = Calendar.current.component(.year, from: Date())
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        // nonisolated(unsafe): @Model isn't Sendable but alarm is only read, not mutated
        nonisolated(unsafe) let alarmRef = alarm
        Task {
            try? await AlarmScheduler.shared.scheduleAlarm(alarmRef, holidays: holidays, makeupDays: makeupDays)
        }
    }

    enum StatusColor {
        case green, orange, red, gray

        var color: Color {
            switch self {
            case .green: .iosGreen
            case .orange: .accent
            case .red: .holidayRed
            case .gray: .fgSecondary
            }
        }
    }
}

import SwiftUI
