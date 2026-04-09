import Foundation
import Observation

@Observable
final class CalendarViewModel {
    var displayedMonth = Date()
    var selectedDate: Date?

    let chineseCalendar = ChineseCalendarService()
    let holidayProvider = HolidayDataProvider()

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
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

    func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: components) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday + 5) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            var dc = components
            dc.day = day
            days.append(calendar.date(from: dc))
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    func alarmTimes(for date: Date, alarms: [Alarm]) -> [String] {
        let year = Calendar.current.component(.year, from: date)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        return alarms
            .filter { $0.isEnabled && $0.shouldRing(on: date, holidays: holidays, makeupDays: makeupDays) }
            .map { $0.timeString }
            .sorted()
    }
}
