import Foundation
import Observation

@Observable
final class AlarmListViewModel {
    var alarms: [Alarm] = []
    var showingEditor = false
    var editingAlarm: Alarm?

    private let holidayProvider = HolidayDataProvider()

    func nextAlarmText(now: Date = Date()) -> String? {
        let enabledAlarms = alarms.filter { $0.isEnabled }
        guard !enabledAlarms.isEmpty else { return nil }

        let nearest = enabledAlarms
            .compactMap { alarm -> (Alarm, Date)? in
                guard let dt = nextRingDateTime(for: alarm, now: now) else { return nil }
                return (alarm, dt)
            }
            .min { $0.1 < $1.1 }

        guard let target = nearest?.1 else { return nil }

        let l = LocaleManager.shared
        let diff = Calendar.current.dateComponents([.hour, .minute], from: now, to: target)
        if let h = diff.hour, let m = diff.minute {
            let prefix = l.localizedString("下一个闹钟将在")
            let hourPart = " \(h)" + l.localizedString("小时")
            let minutePart = "\(m)" + l.localizedString("分钟")
            let suffix = " " + l.localizedString("后响铃")
            return prefix + hourPart + minutePart + suffix
        }
        return nil
    }

    func nextRingDateTime(for alarm: Alarm, now: Date = Date()) -> Date? {
        guard alarm.isEnabled else { return nil }

        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)

        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = alarm.hour
        todayComponents.minute = alarm.minute
        todayComponents.second = 0

        guard let todayAlarmTime = calendar.date(from: todayComponents) else { return nil }

        if todayAlarmTime > now && alarm.shouldRing(on: now, holidays: holidays, makeupDays: makeupDays) {
            return todayAlarmTime
        }

        var current = calendar.date(byAdding: .day, value: 1, to: now)!
        for _ in 0..<365 {
            if alarm.shouldRing(on: current, holidays: holidays, makeupDays: makeupDays) {
                var comps = calendar.dateComponents([.year, .month, .day], from: current)
                comps.hour = alarm.hour
                comps.minute = alarm.minute
                comps.second = 0
                return calendar.date(from: comps)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return nil
    }

    func sortedByNextRing(now: Date = Date()) -> [Alarm] {
        let withDates: [(Alarm, Date?)] = alarms.map { alarm in
            (alarm, nextRingDateTime(for: alarm, now: now))
        }
        return withDates.sorted { a, b in
            switch (a.1, b.1) {
            case let (dateA?, dateB?): return dateA < dateB
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return false
            }
        }.map(\.0)
    }

    func statusInfo(for alarm: Alarm, now: Date = Date()) -> (text: String, color: StatusColor) {
        let calendar = Calendar.current
        let today = now
        let year = calendar.component(.year, from: today)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        let l = LocaleManager.shared

        guard alarm.isEnabled else {
            return (l.localizedString("已关闭"), .gray)
        }

        if let skipDate = alarm.skipNextDate {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: calendar.startOfDay(for: skipDate)).day ?? 0
            if days == 0 {
                return (l.localizedString("已跳过今天"), .orange)
            } else if days == 1 {
                return (l.localizedString("已跳过明天"), .orange)
            } else {
                return (l.localizedString("已跳过") + "\(days)" + l.localizedString("天后的响铃"), .orange)
            }
        }

        let todayRings = alarm.shouldRing(on: today, holidays: holidays, makeupDays: makeupDays)
        let alarmTimeNotPassed = alarm.hour * 60 + alarm.minute > calendar.component(.hour, from: today) * 60 + calendar.component(.minute, from: today)

        if todayRings && alarmTimeNotPassed {
            return (l.localizedString("今天响铃"), .green)
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
        if alarm.isEnabled && alarm.repeatMode.isNone {
            if let scheduled = alarm.scheduledDate,
               Calendar.current.startOfDay(for: scheduled) < Calendar.current.startOfDay(for: Date()) {
                alarm.computeScheduledDate()
            }
        }
        alarm.updatedAt = Date()
        rescheduleAlarm(alarm)
    }

    private func rescheduleAlarm(_ alarm: Alarm) {
        let year = Calendar.current.component(.year, from: Date())
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        nonisolated(unsafe) let alarmRef = alarm
        Task {
            do {
                try await AlarmScheduler.shared.scheduleAlarm(alarmRef, holidays: holidays, makeupDays: makeupDays)
            } catch {
                print("[AlarmListVM] rescheduleAlarm failed for \(alarmRef.id): \(error)")
            }
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
