import Foundation
import Testing
@testable import DayRing

@Suite("CalendarViewModel Tests")
struct CalendarViewModelTests {

    @Test("Month title formats correctly")
    func monthTitle() {
        let vm = CalendarViewModel()
        // displayedMonth defaults to Date(), so just check it's non-empty and contains 年 and 月
        #expect(vm.monthTitle.contains("年"))
        #expect(vm.monthTitle.contains("月"))
    }

    @Test("Previous month decrements month")
    func previousMonth() {
        let vm = CalendarViewModel()
        let original = vm.displayedMonth
        vm.previousMonth()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.month], from: vm.displayedMonth, to: original)
        #expect(diff.month == 1)
    }

    @Test("Next month increments month")
    func nextMonth() {
        let vm = CalendarViewModel()
        let original = vm.displayedMonth
        vm.nextMonth()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.month], from: original, to: vm.displayedMonth)
        #expect(diff.month == 1)
    }

    @Test("Days in month returns correct count with padding")
    func daysInMonth() {
        let vm = CalendarViewModel()
        // Set to October 2026
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 1
        vm.displayedMonth = Calendar.current.date(from: components)!
        let days = vm.daysInMonth()
        // Oct 2026: 31 days, starts on Thursday (offset 3 for Mon-start), total should be multiple of 7
        #expect(days.count % 7 == 0)
        #expect(days.count >= 31)
        // First current-month entry should be Oct 1
        let firstCurrentMonth = days.first(where: { $0.isCurrentMonth })!
        let day = Calendar.current.component(.day, from: firstCurrentMonth.date)
        #expect(day == 1)
    }

    @Test("Days in month includes previous/next month padding dates")
    func daysInMonthPadding() {
        let vm = CalendarViewModel()
        // Oct 2026 starts on Thursday — first 3 entries should be Mon-Wed from September
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 1
        vm.displayedMonth = Calendar.current.date(from: components)!
        let days = vm.daysInMonth()
        // First 3 should be previous month (Sep 28, 29, 30)
        #expect(days[0].isCurrentMonth == false)
        #expect(days[1].isCurrentMonth == false)
        #expect(days[2].isCurrentMonth == false)
        // Fourth should be Oct 1 (current month)
        #expect(days[3].isCurrentMonth == true)
        let day = Calendar.current.component(.day, from: days[3].date)
        #expect(day == 1)
        // Last entry should be next month (not current)
        let last = days.last!
        #expect(last.isCurrentMonth == false)
    }

    @Test("Go to today resets to current month")
    func goToToday() {
        let vm = CalendarViewModel()
        vm.nextMonth()
        vm.nextMonth()
        vm.goToToday()
        let calendar = Calendar.current
        let vmMonth = calendar.component(.month, from: vm.displayedMonth)
        let currentMonth = calendar.component(.month, from: Date())
        #expect(vmMonth == currentMonth)
    }

    @Test("Alarm times filters enabled alarms that should ring")
    func alarmTimesForDate() {
        let vm = CalendarViewModel()
        // Create a date that is a Wednesday (workday)
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 14 // Wednesday
        let date = Calendar.current.date(from: components)!

        let alarm1 = Alarm(hour: 7, minute: 0, isEnabled: true)
        let alarm2 = Alarm(hour: 8, minute: 30, isEnabled: false) // disabled, should be filtered
        let alarm3 = Alarm(hour: 6, minute: 30, isEnabled: true)

        let times24 = vm.alarmTimes(for: date, alarms: [alarm1, alarm2, alarm3], is24HourFormat: true)
        #expect(times24.count == 2)
        #expect(times24 == ["06:30", "07:00"]) // sorted, 24h format
    }

    @Test("Alarm times respects 12h format")
    func alarmTimes12hFormat() {
        let vm = CalendarViewModel()
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 14 // Wednesday
        let date = Calendar.current.date(from: components)!

        let alarm1 = Alarm(hour: 7, minute: 0, isEnabled: true)
        let alarm2 = Alarm(hour: 14, minute: 30, isEnabled: true) // 2:30 PM

        let times12 = vm.alarmTimes(for: date, alarms: [alarm1, alarm2], is24HourFormat: false)
        #expect(times12.count == 2)
        #expect(times12[0] == "7:00 AM")
        #expect(times12[1] == "2:30 PM")
    }
}
