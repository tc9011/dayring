import Testing
import Foundation
@testable import DayRing

@Suite("Alarm Schedule Calculator Tests")
struct AlarmScheduleCalculatorTests {
    
    private let calendar = Calendar.current
    
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    // MARK: - Next Ring Dates
    
    @Test("Daily alarm returns next 7 dates")
    func dailyAlarmNextSevenDays() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        #expect(dates.count == 7)
        for (i, d) in dates.enumerated() {
            let expected = calendar.date(byAdding: .day, value: i, to: from)!
            #expect(calendar.isDate(d, inSameDayAs: expected))
        }
    }
    
    @Test("Weekly alarm only includes selected weekdays")
    func weeklyAlarmSelectedDays() {
        // Monday and Wednesday only
        let alarm = Alarm(hour: 8, minute: 30, repeatMode: .weekly(days: [.monday, .wednesday]))
        let from = date(2026, 4, 6) // Monday
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 4, holidays: [], makeupDays: [])
        
        #expect(dates.count == 4)
        for d in dates {
            let weekday = calendar.component(.weekday, from: d)
            let adjusted = weekday == 1 ? 7 : weekday - 1
            #expect(adjusted == 1 || adjusted == 3, "Expected Monday(1) or Wednesday(3), got \(adjusted)")
        }
    }
    
    @Test("Disabled alarm returns empty dates")
    func disabledAlarmNoDates() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, isEnabled: false)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        #expect(dates.isEmpty)
    }
    
    // MARK: - Holiday Skip
    
    @Test("Holiday skip removes holiday dates from schedule")
    func holidaySkipRemovesDates() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, skipHolidays: true)
        let from = date(2026, 10, 1)
        let holidays: Set<String> = ["2026-10-01", "2026-10-02", "2026-10-03"]
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: holidays, makeupDays: [])
        
        // Oct 1-3 are holidays, so first 3 days should be skipped
        for d in dates {
            let key = Alarm.dateKey(for: d)
            #expect(!holidays.contains(key), "Holiday \(key) should not be in schedule")
        }
    }
    
    @Test("Holiday skip disabled includes holiday dates")
    func holidaySkipDisabledIncludesHolidays() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, skipHolidays: false)
        let from = date(2026, 10, 1)
        let holidays: Set<String> = ["2026-10-01"]
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: holidays, makeupDays: [])
        
        // Oct 1 should still be included since skip is disabled
        let hasOct1 = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 10, 1)) }
        #expect(hasOct1)
    }
    
    // MARK: - Makeup Day
    
    @Test("Makeup day rings even on non-repeat day")
    func makeupDayRingsOnNonRepeatDay() {
        // Weekday-only alarm, but Saturday is a makeup day
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .weekly(days: Weekday.workdays), ringOnMakeupDays: true)
        let from = date(2026, 10, 10) // Saturday
        let makeupDays: Set<String> = ["2026-10-10"]
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: makeupDays)
        
        let hasMakeupDay = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 10, 10)) }
        #expect(hasMakeupDay)
    }
    
    // MARK: - Advance Minutes
    
    @Test("Advance minutes shifts alarm time earlier")
    func advanceMinutesShiftsTime() {
        let alarm = Alarm(hour: 7, minute: 0, advanceMinutes: 15)
        let calculator = AlarmScheduleCalculator()
        let (h, m) = calculator.effectiveTime(for: alarm)
        
        #expect(h == 6)
        #expect(m == 45)
    }
    
    @Test("Advance minutes wraps around midnight")
    func advanceMinutesMidnightWrap() {
        let alarm = Alarm(hour: 0, minute: 10, advanceMinutes: 30)
        let calculator = AlarmScheduleCalculator()
        let (h, m) = calculator.effectiveTime(for: alarm)
        
        #expect(h == 23)
        #expect(m == 40)
    }
    
    @Test("Zero advance minutes keeps original time")
    func zeroAdvanceMinutesNoChange() {
        let alarm = Alarm(hour: 14, minute: 30, advanceMinutes: 0)
        let calculator = AlarmScheduleCalculator()
        let (h, m) = calculator.effectiveTime(for: alarm)
        
        #expect(h == 14)
        #expect(m == 30)
    }
    
    // MARK: - Skip Next
    
    @Test("Skip next date removes that date from schedule")
    func skipNextDateRemoved() {
        let skipDate = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 11))!
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        alarm.skipNextDate = skipDate
        
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        let hasSkipped = dates.contains { calendar.isDate($0, inSameDayAs: skipDate) }
        #expect(!hasSkipped, "Skip date should not appear in schedule")
    }
    
    // MARK: - Manual Override
    
    @Test("Manual override force-on adds date to schedule")
    func manualOverrideForceOn() {
        // Weekend alarm but forced on for a weekday
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .weekly(days: [.saturday, .sunday]))
        alarm.manualOverrides["2026-04-13"] = true // Monday
        
        let from = date(2026, 4, 13)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        let hasMonday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 13)) }
        #expect(hasMonday, "Manual override force-on should include the date")
    }
    
    @Test("Manual override force-off removes date from schedule")
    func manualOverrideForceOff() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        alarm.manualOverrides["2026-04-10"] = false
        
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        let hasOverriddenDate = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(!hasOverriddenDate, "Manual override force-off should exclude the date")
    }
    
    // MARK: - Rotating Pattern
    
    @Test("Rotating pattern follows ring/gap cycle")
    func rotatingPatternCycle() {
        let startDate = date(2026, 4, 1)
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .rotating(startDate: startDate, ringDays: 3, gapDays: 2))
        let from = date(2026, 4, 1)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 10, holidays: [], makeupDays: [])
        
        // Cycle: ring ring ring gap gap ring ring ring gap gap
        // Days 1-3: ring, 4-5: gap, 6-8: ring, 9-10: gap
        // From Apr 1: ring Apr 1,2,3 - gap Apr 4,5 - ring Apr 6,7,8 - gap Apr 9,10
        // So we expect 6 ring dates in the first 10 days
        let expectedRingDates = [
            date(2026, 4, 1), date(2026, 4, 2), date(2026, 4, 3),
            date(2026, 4, 6), date(2026, 4, 7), date(2026, 4, 8)
        ]
        
        #expect(dates.count >= 6)
        for expected in expectedRingDates {
            let found = dates.contains { calendar.isDate($0, inSameDayAs: expected) }
            #expect(found, "Expected ring date \(Alarm.dateKey(for: expected)) not found")
        }
    }
    
    // MARK: - Past Time Filtering

    @Test("nextRingDates skips today when alarm time already passed")
    func skipsTodayWhenTimePassed() {
        let alarm = Alarm(hour: 15, minute: 41, repeatMode: .daily)
        // "now" is 15:42 on Apr 10 — alarm time 15:41 already passed
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 15, minute: 42))!
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 3, holidays: [], makeupDays: [])

        // Today (Apr 10) should NOT be in the result — its time already passed
        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(!hasToday, "Today should be skipped when alarm time already passed")
        // First date should be tomorrow
        #expect(dates.count == 3)
        #expect(calendar.isDate(dates[0], inSameDayAs: date(2026, 4, 11)))
    }

    @Test("nextRingDates includes today when alarm time not yet passed")
    func includesTodayWhenTimeNotPassed() {
        let alarm = Alarm(hour: 15, minute: 41, repeatMode: .daily)
        // "now" is 15:30 on Apr 10 — alarm time 15:41 not passed yet
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 15, minute: 30))!
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 3, holidays: [], makeupDays: [])

        // Today should be included — time hasn't passed
        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(hasToday, "Today should be included when alarm time hasn't passed")
        #expect(calendar.isDate(dates[0], inSameDayAs: date(2026, 4, 10)))
    }

    @Test("nextRingDates skips today for .none alarm when time passed")
    func noneAlarmSkipsTodayWhenTimePassed() {
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .none)
        // "now" is 10:00 — alarm at 08:00 already passed
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 10, minute: 0))!
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 1, holidays: [], makeupDays: [])

        // For .none, once today's time passed, there should be no future dates
        // (.none matches every day, so without time check it would return today)
        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(!hasToday, ".none alarm should skip today when time passed")
    }

    @Test("nextRingDates with advance minutes uses effective time for filtering")
    func advanceMinutesUsedForFiltering() {
        // Alarm at 16:00 with 15min advance → effective time 15:45
        let alarm = Alarm(hour: 16, minute: 0, advanceMinutes: 15)
        alarm.repeatMode = .daily
        // "now" is 15:50 — effective time 15:45 already passed
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 15, minute: 50))!
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 3, holidays: [], makeupDays: [])

        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(!hasToday, "Today should be skipped when effective alarm time (with advance) already passed")
    }

    // MARK: - Delete After Ring
    
    @Test("Delete-after-ring alarm only schedules one date")
    func deleteAfterRingOnlyOneDate() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, deleteAfterRing: true)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])
        
        #expect(dates.count == 1, "Delete-after-ring should only schedule one date, got \(dates.count)")
    }
}
