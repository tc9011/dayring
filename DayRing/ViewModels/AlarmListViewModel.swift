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

        let diff = calendar.dateComponents([.hour, .minute], from: now, to: target)
        if let h = diff.hour, let m = diff.minute {
            return "下一个闹钟将在 \(h)小时\(m)分钟 后响铃"
        }
        return nil
    }

    func statusInfo(for alarm: Alarm) -> (text: String, color: StatusColor) {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let year = calendar.component(.year, from: today)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)

        guard alarm.isEnabled else {
            return ("已关闭", .gray)
        }

        let tomorrowKey = Alarm.dateKey(for: tomorrow)
        if let name = holidayProvider.holidayName(for: tomorrowKey, year: year),
           alarm.skipHolidays {
            return ("后天响铃 · 明天为\(name)", .orange)
        }

        if alarm.shouldRing(on: tomorrow, holidays: holidays, makeupDays: makeupDays) {
            return ("明天响铃 · 跳过节假日", .green)
        } else {
            return ("明天不响铃", .red)
        }
    }

    func skipNext(_ alarm: Alarm) {
        alarm.skipNextDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        alarm.updatedAt = Date()
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
