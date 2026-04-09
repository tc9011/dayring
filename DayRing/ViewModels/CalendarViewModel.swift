import Foundation
import Observation

@Observable
final class CalendarViewModel {
    var displayedMonth = Date()
    var selectedDate: Date?

    let chineseCalendar = ChineseCalendarService()
    let holidayProvider = HolidayDataProvider()

    var monthTitle: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: displayedMonth)
        let month = calendar.component(.month, from: displayedMonth)
        let l = LocaleManager.shared
        return "\(year)" + l.localizedString("年") + "\(month)" + l.localizedString("月")
    }

    func previousMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    func nextMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    func goToToday() {
        displayedMonth = Date()
    }

    func daysInMonth() -> [(date: Date, isCurrentMonth: Bool)] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday + 5) % 7

        var days: [(date: Date, isCurrentMonth: Bool)] = []

        for i in (0..<offset).reversed() {
            if let prevDate = calendar.date(byAdding: .day, value: -(i + 1), to: firstDay) {
                days.append((prevDate, false))
            }
        }

        for day in range {
            var dc = components
            dc.day = day
            if let date = calendar.date(from: dc) {
                days.append((date, true))
            }
        }

        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1,
            to: calendar.date(byAdding: .month, value: 1, to: firstDay)!)!
        var nextDay = 1
        while days.count % 7 != 0 {
            if let nextDate = calendar.date(byAdding: .day, value: nextDay, to: lastDayOfMonth) {
                days.append((nextDate, false))
            }
            nextDay += 1
        }

        return days
    }

    func alarmTimes(for date: Date, alarms: [Alarm], is24HourFormat: Bool) -> [String] {
        let year = Calendar.current.component(.year, from: date)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        return alarms
            .filter { $0.isEnabled && $0.shouldRing(on: date, holidays: holidays, makeupDays: makeupDays) }
            .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
            .map { alarm in
                if is24HourFormat {
                    return alarm.timeString
                } else {
                    return String(format: "%d:%02d %@", alarm.hour12, alarm.minute, alarm.amPmString)
                }
            }
    }
}
