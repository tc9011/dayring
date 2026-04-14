import Testing
import Foundation
@testable import DayRing

@Suite("Alarm Model Tests")
struct AlarmTests {

    @Test("Default alarm is 07:00 no repeat")
    func defaultAlarm() {
        let alarm = Alarm()
        #expect(alarm.hour == 7)
        #expect(alarm.minute == 0)
        #expect(alarm.isEnabled == true)
        #expect(alarm.repeatMode.isNone)
    }

    @Test("24h time string formatting")
    func timeString() {
        let alarm = Alarm(hour: 7, minute: 0)
        #expect(alarm.timeString == "07:00")
        #expect(alarm.hour12 == 7)

        let pm = Alarm(hour: 14, minute: 30)
        #expect(pm.timeString == "14:30")
        #expect(pm.hour12 == 2)

        #expect(alarm.amPmString != pm.amPmString)
    }

    @Test("Midnight and noon edge cases for 12h conversion")
    func hour12EdgeCases() {
        let midnight = Alarm(hour: 0, minute: 0)
        #expect(midnight.hour12 == 12)
        #expect(midnight.amPmString == Alarm(hour: 6, minute: 0).amPmString)

        let noon = Alarm(hour: 12, minute: 0)
        #expect(noon.hour12 == 12)
        #expect(noon.amPmString == Alarm(hour: 18, minute: 0).amPmString)

        #expect(midnight.amPmString != noon.amPmString)
    }

    @Test("Weekly pattern matches weekdays, not weekends")
    func weeklyPattern() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays))
        let calendar = Calendar.current

        // 2026-04-13 is a Monday
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)

        // 2026-04-18 is a Saturday
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == false)
    }

    @Test("Daily pattern matches every day")
    func dailyPattern() {
        let alarm = Alarm(repeatMode: .daily)
        let calendar = Calendar.current
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!

        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == true)
    }

    @Test("Holiday skip prevents ringing on holidays")
    func holidaySkip() {
        let alarm = Alarm(skipHolidays: true)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        let holidays: Set<String> = ["2026-10-01"]

        #expect(alarm.shouldRing(on: date, holidays: holidays, makeupDays: []) == false)
    }

    @Test("Holiday skip disabled allows ringing on holidays")
    func holidayNoSkip() {
        let alarm = Alarm(skipHolidays: false)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        alarm.scheduledDate = date
        let holidays: Set<String> = ["2026-10-01"]

        #expect(alarm.shouldRing(on: date, holidays: holidays, makeupDays: []) == true)
    }

    @Test("Manual override beats holiday skip")
    func manualOverride() {
        let alarm = Alarm(skipHolidays: true)
        alarm.manualOverrides["2026-10-01"] = true
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        let holidays: Set<String> = ["2026-10-01"]

        #expect(alarm.shouldRing(on: date, holidays: holidays, makeupDays: []) == true)
    }

    @Test("Manual override can force silence")
    func manualOverrideSilence() {
        let alarm = Alarm(repeatMode: .daily)
        alarm.manualOverrides["2026-04-13"] = false
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 13))!

        #expect(alarm.shouldRing(on: date, holidays: [], makeupDays: []) == false)
    }

    @Test("Rotating pattern: 4 ring, 2 gap")
    func rotatingPattern() {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 4, gapDays: 2))

        let day0 = start
        let day3 = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        let day4 = Calendar.current.date(byAdding: .day, value: 4, to: start)!
        let day5 = Calendar.current.date(byAdding: .day, value: 5, to: start)!
        let day6 = Calendar.current.date(byAdding: .day, value: 6, to: start)!

        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day3, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day4, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day5, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day6, holidays: [], makeupDays: []) == true)
    }

    @Test("Rotating pattern before start date does not ring")
    func rotatingBeforeStart() {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 10))!
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 4, gapDays: 2))
        let before = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 5))!

        #expect(alarm.shouldRing(on: before, holidays: [], makeupDays: []) == false)
    }

    @Test("Skip next date prevents single occurrence")
    func skipNext() {
        let alarm = Alarm()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        alarm.skipNextDate = tomorrow

        #expect(alarm.shouldRing(on: tomorrow, holidays: [], makeupDays: []) == false)
    }

    @Test("Skip next clears when already set for same date")
    func skipNextToggle() {
        let alarm = Alarm()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        alarm.scheduledDate = tomorrow
        alarm.skipNextDate = tomorrow
        #expect(alarm.skipNextDate != nil)

        alarm.skipNextDate = nil
        #expect(alarm.skipNextDate == nil)
        #expect(alarm.shouldRing(on: tomorrow, holidays: [], makeupDays: []) == true)
    }

    @Test("Delete after ring flag")
    func deleteAfterRing() {
        let alarm = Alarm(deleteAfterRing: true)
        #expect(alarm.deleteAfterRing == true)
    }

    @Test("Repeat detail text for workdays")
    func repeatDetailWorkdays() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays))
        #expect(alarm.repeatDetailText == "工作日")
    }

    @Test("Repeat detail text for all days shows 每天")
    func repeatDetailAllDays() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.allDays))
        #expect(alarm.repeatDetailText == "每天")
    }

    @Test("Repeat detail text for rotating")
    func repeatDetailRotating() {
        let start = Date()
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 4, gapDays: 2))
        #expect(alarm.repeatDetailText == "响4天休2天")
    }

    @Test("Makeup day rings when enabled")
    func makeupDayRings() {
        let alarm = Alarm(skipHolidays: true, ringOnMakeupDays: true)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 10))!
        let makeupDays: Set<String> = ["2026-10-10"]

        #expect(alarm.shouldRing(on: date, holidays: [], makeupDays: makeupDays) == true)
    }

    @Test("Date key format is yyyy-MM-dd")
    func dateKeyFormat() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 5))!
        let key = Alarm.dateKey(for: date)
        #expect(key == "2026-01-05")
    }

    // MARK: - Non-repeating scheduledDate

    @Test("Non-repeating alarm only rings on its scheduledDate")
    func noneOnlyRingsOnScheduledDate() {
        let calendar = Calendar.current
        let apr14 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 14))!
        let apr15 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let apr16 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 16))!

        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .none)
        alarm.scheduledDate = apr15

        #expect(alarm.shouldRing(on: apr14, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: apr15, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: apr16, holidays: [], makeupDays: []) == false)
    }

    @Test("Non-repeating alarm without scheduledDate does not ring on any day")
    func noneWithoutScheduledDateDoesNotRing() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .none)
        // scheduledDate is nil by default
        let anyDay = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        #expect(alarm.shouldRing(on: anyDay, holidays: [], makeupDays: []) == false)
    }

    @Test("computeScheduledDate returns today when alarm time is in the future")
    func computeScheduledDateToday() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13, hour: 8, minute: 0))!
        let alarm = Alarm(hour: 12, minute: 0, repeatMode: .none)

        alarm.computeScheduledDate(now: now)
        #expect(alarm.scheduledDate != nil)
        #expect(calendar.isDate(alarm.scheduledDate!, inSameDayAs: now))
    }

    @Test("computeScheduledDate returns tomorrow when alarm time has passed")
    func computeScheduledDateTomorrow() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13, hour: 15, minute: 0))!
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .none)

        alarm.computeScheduledDate(now: now)
        #expect(alarm.scheduledDate != nil)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        #expect(calendar.isDate(alarm.scheduledDate!, inSameDayAs: tomorrow))
    }

    @Test("computeScheduledDate returns tomorrow when alarm time equals current time")
    func computeScheduledDateExactTime() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13, hour: 7, minute: 0))!
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .none)

        alarm.computeScheduledDate(now: now)
        #expect(alarm.scheduledDate != nil)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        #expect(calendar.isDate(alarm.scheduledDate!, inSameDayAs: tomorrow))
    }
}
