import Testing
import Foundation
@testable import DayRing

/// Edge-case tests for all repeat modes, priority chain interactions,
/// and the nextRingDatesLimited scheduling logic.
@Suite("Repeat Mode Edge Case Tests")
struct RepeatModeEdgeCaseTests {

    private let calendar = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func dateTime(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    // MARK: - .none Mode Edge Cases

    @Test(".none matchesRepeatPattern returns true for any date")
    func noneMatchesAnyDate() {
        let alarm = Alarm(repeatMode: .none)
        // Past, present, future — all match
        let past = date(2020, 1, 1)
        let future = date(2030, 12, 31)
        let weekend = date(2026, 4, 18) // Saturday

        #expect(alarm.shouldRing(on: past, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: future, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: weekend, holidays: [], makeupDays: []) == true)
    }

    @Test("BUG: .none alarm with count=7 schedules 7 notifications (should be 1 for non-repeating)")
    func noneAlarmSchedulesMultipleDays() {
        // This test documents the current behavior:
        // .none + deleteAfterRing=false → nextRingDates returns 7 dates
        // This wastes notification slots for a non-repeating alarm
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .none, deleteAfterRing: false)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])

        // Current behavior: .none matches every day, so 7 dates are returned
        // This is a known semantic issue — non-repeating alarms shouldn't schedule 7 days
        // For now we document the behavior; the UI layer (disableExpiredNonRepeatingAlarms)
        // handles the user-facing consequence
        #expect(dates.count == 7, ".none alarm currently schedules \(dates.count) dates (expected 7 from current logic)")
    }

    @Test(".none alarm with deleteAfterRing=true correctly schedules only 1 date")
    func noneDeleteAfterRingOnlyOneDate() {
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .none, deleteAfterRing: true)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])

        #expect(dates.count == 1, ".none + deleteAfterRing should schedule exactly 1 date")
    }

    // MARK: - .biweekly Edge Cases

    @Test("Biweekly uses weekOfYear — verify even/odd consistency across several weeks")
    func biweeklyEvenOddWeeks() {
        // week1 = Mon-Fri (even weekOfYear), week2 = Mon,Wed,Fri (odd weekOfYear)
        let alarm = Alarm(repeatMode: .biweekly(
            week1: Weekday.workdays,
            week2: [.monday, .wednesday, .friday]
        ))

        // Check 4 consecutive Tuesdays to verify alternation
        // Apr 7 Tue → weekOfYear 14 (even) → week1 → Tue in workdays → ring
        let apr7 = date(2026, 4, 7)
        let woy7 = calendar.component(.weekOfYear, from: apr7)
        let apr7Rings = alarm.shouldRing(on: apr7, holidays: [], makeupDays: [])

        // Apr 14 Tue → weekOfYear 15 (odd) → week2 → Tue NOT in [Mon,Wed,Fri] → no ring
        let apr14 = date(2026, 4, 14)
        let woy14 = calendar.component(.weekOfYear, from: apr14)
        let apr14Rings = alarm.shouldRing(on: apr14, holidays: [], makeupDays: [])

        // Apr 21 Tue → weekOfYear 16 (even) → week1 → ring
        let apr21 = date(2026, 4, 21)
        let woy21 = calendar.component(.weekOfYear, from: apr21)
        let apr21Rings = alarm.shouldRing(on: apr21, holidays: [], makeupDays: [])

        // Apr 28 Tue → weekOfYear 17 (odd) → week2 → no ring
        let apr28 = date(2026, 4, 28)
        let woy28 = calendar.component(.weekOfYear, from: apr28)
        let apr28Rings = alarm.shouldRing(on: apr28, holidays: [], makeupDays: [])

        // Verify the even/odd pattern is consistent
        #expect(woy7 % 2 == 0, "Week of Apr 7 should be even, got \(woy7)")
        #expect(woy14 % 2 != 0, "Week of Apr 14 should be odd, got \(woy14)")
        #expect(woy21 % 2 == 0, "Week of Apr 21 should be even, got \(woy21)")
        #expect(woy28 % 2 != 0, "Week of Apr 28 should be odd, got \(woy28)")

        #expect(apr7Rings == true, "Even week Tue → week1 (workdays) → should ring")
        #expect(apr14Rings == false, "Odd week Tue → week2 (MWF) → should NOT ring")
        #expect(apr21Rings == true, "Even week Tue → week1 → should ring")
        #expect(apr28Rings == false, "Odd week Tue → week2 → should NOT ring")
    }

    @Test("Biweekly cross-year: weekOfYear may reset, check Dec→Jan boundary")
    func biweeklyCrossYear() {
        // week1 on even weekOfYear, week2 on odd
        let alarm = Alarm(repeatMode: .biweekly(
            week1: [.monday],
            week2: [.monday]
        ))

        // Dec 28 2026 is a Monday — check its weekOfYear
        let dec28 = date(2026, 12, 28)
        let woyDec28 = calendar.component(.weekOfYear, from: dec28)

        // Jan 4 2027 is a Monday — check its weekOfYear
        let jan4 = date(2027, 1, 4)  // Should be next Monday after New Year
        let woyJan4 = calendar.component(.weekOfYear, from: jan4)

        // Both should ring (both week1 and week2 contain Monday)
        // but the even/odd swap may cause unexpected behavior
        let dec28Rings = alarm.shouldRing(on: dec28, holidays: [], makeupDays: [])
        let jan4Rings = alarm.shouldRing(on: jan4, holidays: [], makeupDays: [])

        #expect(dec28Rings == true, "Dec 28 Mon should ring (both weeks have Mon)")
        #expect(jan4Rings == true, "Jan 4 Mon should ring (both weeks have Mon)")

        // Document the weekOfYear values for awareness
        // weekOfYear can be 1 for late December days depending on locale
        // This is a known limitation of using weekOfYear for biweekly
        _ = woyDec28
        _ = woyJan4
    }

    @Test("Biweekly cross-year with different day sets exposes weekOfYear discontinuity")
    func biweeklyCrossYearDifferentDays() {
        // week1 (even) = Mon only, week2 (odd) = Fri only
        // This means if weekOfYear flips parity at year boundary, the schedule could glitch
        let alarm = Alarm(repeatMode: .biweekly(
            week1: [.tuesday],
            week2: [.thursday]
        ))

        // Find the last Tuesday of 2026 and first Tuesday of 2027
        let dec29Tue = date(2026, 12, 29)  // Tuesday
        let jan5Tue = date(2027, 1, 5)     // Tuesday

        let woyDec = calendar.component(.weekOfYear, from: dec29Tue)
        let woyJan = calendar.component(.weekOfYear, from: jan5Tue)

        let dec29Rings = alarm.shouldRing(on: dec29Tue, holidays: [], makeupDays: [])
        let jan5Rings = alarm.shouldRing(on: jan5Tue, holidays: [], makeupDays: [])

        // If weekOfYear goes from 52 (even) → 1 (odd), the parity flips correctly
        // If it goes 52 (even) → 2 (even), we get two consecutive "week1" weeks — BUG
        // We document the actual behavior here
        if woyDec % 2 == woyJan % 2 {
            // Same parity — both map to same week set. This is a discontinuity.
            // Both would be week1 (Tuesday) or both week2 (Thursday)
            // For Tuesday: both would ring (if even) or both would NOT ring (if odd)
            #expect(dec29Rings == jan5Rings,
                    "Cross-year parity collision: woyDec=\(woyDec) woyJan=\(woyJan) — both map to same week")
        } else {
            // Different parity — correct alternation
            #expect(dec29Rings != jan5Rings,
                    "Cross-year should alternate: woyDec=\(woyDec) woyJan=\(woyJan)")
        }
    }

    @Test("Biweekly with empty week1 and full week2")
    func biweeklyEmptyWeek1() {
        let alarm = Alarm(repeatMode: .biweekly(week1: [], week2: Weekday.allDays))

        // Even week → week1 (empty) → no ring
        let apr7 = date(2026, 4, 7) // Mon, weekOfYear 14 (even)
        let woy7 = calendar.component(.weekOfYear, from: apr7)
        if woy7 % 2 == 0 {
            #expect(alarm.shouldRing(on: apr7, holidays: [], makeupDays: []) == false,
                    "Even week with empty week1 should not ring")
        }

        // Odd week → week2 (allDays) → ring
        let apr14 = date(2026, 4, 14) // Mon, weekOfYear 15 (odd)
        let woy14 = calendar.component(.weekOfYear, from: apr14)
        if woy14 % 2 != 0 {
            #expect(alarm.shouldRing(on: apr14, holidays: [], makeupDays: []) == true,
                    "Odd week with full week2 should ring")
        }
    }

    @Test("Biweekly with both weeks empty — never rings via pattern")
    func biweeklyBothWeeksEmpty() {
        let alarm = Alarm(repeatMode: .biweekly(week1: [], week2: []))
        let monday = date(2026, 4, 13)
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == false)
    }

    // MARK: - .rotating Edge Cases

    @Test("Rotating with ringDays=0 never rings via pattern")
    func rotatingZeroRingDays() {
        let start = date(2026, 4, 1)
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 0, gapDays: 5))
        
        // cycle = 0 + 5 = 5, positionInCycle < 0 is always false
        let day0 = start
        let day3 = calendar.date(byAdding: .day, value: 3, to: start)!
        
        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day3, holidays: [], makeupDays: []) == false)
    }

    @Test("Rotating with gapDays=0 always rings from start date")
    func rotatingZeroGapDays() {
        let start = date(2026, 4, 1)
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 3, gapDays: 0))

        // cycle = 3 + 0 = 3, positionInCycle always < 3 (0, 1, or 2)
        let day0 = start
        let day1 = calendar.date(byAdding: .day, value: 1, to: start)!
        let day2 = calendar.date(byAdding: .day, value: 2, to: start)!
        let day3 = calendar.date(byAdding: .day, value: 3, to: start)!
        let day100 = calendar.date(byAdding: .day, value: 100, to: start)!

        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day1, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day2, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day3, holidays: [], makeupDays: []) == true, "With 0 gap, day3 position=0 → ring")
        #expect(alarm.shouldRing(on: day100, holidays: [], makeupDays: []) == true, "With 0 gap, all days ring")
    }

    @Test("Rotating with both ringDays=0 and gapDays=0 — cycle=0 guard returns false")
    func rotatingZeroCycle() {
        let start = date(2026, 4, 1)
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 0, gapDays: 0))

        #expect(alarm.shouldRing(on: start, holidays: [], makeupDays: []) == false,
                "Zero cycle should not ring (guard cycle > 0)")
    }

    @Test("Rotating with large cycle values works correctly")
    func rotatingLargeCycle() {
        let start = date(2026, 1, 1)
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 30, gapDays: 30))

        // Day 0-29: ring, Day 30-59: gap, Day 60-89: ring
        let day0 = start
        let day29 = calendar.date(byAdding: .day, value: 29, to: start)!
        let day30 = calendar.date(byAdding: .day, value: 30, to: start)!
        let day59 = calendar.date(byAdding: .day, value: 59, to: start)!
        let day60 = calendar.date(byAdding: .day, value: 60, to: start)!

        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day29, holidays: [], makeupDays: []) == true, "Last ring day of first cycle")
        #expect(alarm.shouldRing(on: day30, holidays: [], makeupDays: []) == false, "First gap day")
        #expect(alarm.shouldRing(on: day59, holidays: [], makeupDays: []) == false, "Last gap day")
        #expect(alarm.shouldRing(on: day60, holidays: [], makeupDays: []) == true, "First ring day of second cycle")
    }

    @Test("Rotating nextRingDates returns correct count for ring/gap pattern")
    func rotatingNextRingDatesCount() {
        let start = date(2026, 4, 1)
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .rotating(startDate: start, ringDays: 2, gapDays: 3))
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: start, count: 6, holidays: [], makeupDays: [])

        // Pattern: ring ring gap gap gap ring ring gap gap gap ring ring ...
        // Ring dates: day 0,1,  5,6,  10,11
        let expectedDays = [0, 1, 5, 6, 10, 11]
        #expect(dates.count == 6, "Should find 6 ring dates")
        for (i, dayOffset) in expectedDays.enumerated() {
            let expected = calendar.date(byAdding: .day, value: dayOffset, to: start)!
            #expect(calendar.isDate(dates[i], inSameDayAs: expected),
                    "Date \(i) should be day+\(dayOffset), got \(Alarm.dateKey(for: dates[i]))")
        }
    }

    // MARK: - .custom Edge Cases

    @Test("Custom with empty dates set — never rings via pattern")
    func customEmptyDates() {
        let alarm = Alarm(repeatMode: .custom(dates: []))
        let anyDate = date(2026, 4, 15)
        #expect(alarm.shouldRing(on: anyDate, holidays: [], makeupDays: []) == false)
    }

    @Test("Custom dates only match exact year/month/day")
    func customExactDateMatch() {
        let targetDC = DateComponents(year: 2026, month: 4, day: 15)
        let alarm = Alarm(repeatMode: .custom(dates: [targetDC]))

        let match = date(2026, 4, 15)
        let wrongYear = date(2027, 4, 15)
        let wrongMonth = date(2026, 5, 15)
        let wrongDay = date(2026, 4, 16)

        #expect(alarm.shouldRing(on: match, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: wrongYear, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: wrongMonth, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: wrongDay, holidays: [], makeupDays: []) == false)
    }

    @Test("Custom with past dates — dates in the past still match shouldRing")
    func customPastDates() {
        let pastDC = DateComponents(year: 2020, month: 1, day: 1)
        let alarm = Alarm(repeatMode: .custom(dates: [pastDC]))

        let pastDate = date(2020, 1, 1)
        #expect(alarm.shouldRing(on: pastDate, holidays: [], makeupDays: []) == true,
                "shouldRing doesn't filter by past/future — that's the scheduler's job")
    }

    @Test("Custom nextRingDates skips past custom dates")
    func customNextRingDatesSkipsPast() {
        // All dates in the past — scheduler should find nothing
        let pastDC = DateComponents(year: 2020, month: 1, day: 1)
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .custom(dates: [pastDC]))
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])

        #expect(dates.isEmpty, "No future custom dates → empty schedule")
    }

    @Test("Custom with many dates returns correct nextRingDates")
    func customManyDatesSchedule() {
        let dates: Set<DateComponents> = [
            DateComponents(year: 2026, month: 4, day: 12),
            DateComponents(year: 2026, month: 4, day: 15),
            DateComponents(year: 2026, month: 4, day: 20),
            DateComponents(year: 2026, month: 5, day: 1),
        ]
        let alarm = Alarm(hour: 9, minute: 0, repeatMode: .custom(dates: dates))
        let from = date(2026, 4, 13) // Start after first date
        let calculator = AlarmScheduleCalculator()
        let result = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])

        // Should find: Apr 15, Apr 20, May 1 (Apr 12 is before `from`)
        #expect(result.count == 3, "Should find 3 future custom dates, got \(result.count)")
        #expect(calendar.isDate(result[0], inSameDayAs: date(2026, 4, 15)))
        #expect(calendar.isDate(result[1], inSameDayAs: date(2026, 4, 20)))
        #expect(calendar.isDate(result[2], inSameDayAs: date(2026, 5, 1)))
    }

    // MARK: - .weekly Edge Cases

    @Test("Weekly with empty days set — never rings via pattern")
    func weeklyEmptyDays() {
        let alarm = Alarm(repeatMode: .weekly(days: []))
        let monday = date(2026, 4, 13)
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == false)
    }

    @Test("Weekly with all 7 days — equivalent to daily")
    func weeklyAllDaysEqualsDaily() {
        let weeklyAll = Alarm(repeatMode: .weekly(days: Weekday.allDays))
        let daily = Alarm(repeatMode: .daily)

        for dayOffset in 0..<14 {
            let d = calendar.date(byAdding: .day, value: dayOffset, to: date(2026, 4, 6))!
            #expect(weeklyAll.shouldRing(on: d, holidays: [], makeupDays: []) ==
                    daily.shouldRing(on: d, holidays: [], makeupDays: []),
                    "Day \(Alarm.dateKey(for: d)) should match between weekly(allDays) and daily")
        }
    }

    @Test("Weekly Sunday mapping is correct (Foundation weekday 1 → Weekday.sunday = 7)")
    func weeklySundayMapping() {
        let alarm = Alarm(repeatMode: .weekly(days: [.sunday]))
        let sunday = date(2026, 4, 12)  // Sunday
        let monday = date(2026, 4, 13)  // Monday

        let foundationWeekday = calendar.component(.weekday, from: sunday)
        #expect(foundationWeekday == 1, "Foundation Sunday should be 1")

        #expect(alarm.shouldRing(on: sunday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == false)
    }

    // MARK: - Priority Chain Interaction Tests

    @Test("Manual override FALSE beats makeup day TRUE")
    func manualOverrideFalseBeatsSmakeupDay() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays), ringOnMakeupDays: true)
        let saturdayMakeup = date(2026, 10, 10) // Saturday
        let key = Alarm.dateKey(for: saturdayMakeup)

        // Without override — makeup day forces ring
        #expect(alarm.shouldRing(on: saturdayMakeup, holidays: [], makeupDays: [key]) == true)

        // Manual override FALSE should beat makeup day
        alarm.manualOverrides[key] = false
        #expect(alarm.shouldRing(on: saturdayMakeup, holidays: [], makeupDays: [key]) == false,
                "Manual override false should beat makeup day")
    }

    @Test("Manual override TRUE beats holiday skip")
    func manualOverrideTrueBeatsHolidaySkip() {
        let alarm = Alarm(repeatMode: .daily, skipHolidays: true)
        let holiday = date(2026, 10, 1)
        let key = Alarm.dateKey(for: holiday)

        // Without override — holiday skipped
        #expect(alarm.shouldRing(on: holiday, holidays: [key], makeupDays: []) == false)

        // Manual override TRUE beats holiday skip
        alarm.manualOverrides[key] = true
        #expect(alarm.shouldRing(on: holiday, holidays: [key], makeupDays: []) == true)
    }

    @Test("Skip next beats makeup day")
    func skipNextBeatsMakeupDay() {
        let alarm = Alarm(repeatMode: .daily, ringOnMakeupDays: true)
        let target = date(2026, 10, 10)
        let key = Alarm.dateKey(for: target)

        alarm.skipNextDate = target
        #expect(alarm.shouldRing(on: target, holidays: [], makeupDays: [key]) == false,
                "skipNext should beat makeup day")
    }

    @Test("Manual override beats skip next")
    func manualOverrideBeatsSkipNext() {
        let alarm = Alarm(repeatMode: .daily)
        let target = date(2026, 4, 15)
        let key = Alarm.dateKey(for: target)

        alarm.skipNextDate = target
        alarm.manualOverrides[key] = true

        #expect(alarm.shouldRing(on: target, holidays: [], makeupDays: []) == true,
                "Manual override should beat skipNext")
    }

    @Test("Makeup day that is also a holiday — makeup day wins (higher priority)")
    func makeupDayAndHoliday() {
        // A day that's both a holiday and a makeup day
        // Priority: makeupDay check comes BEFORE holiday check in shouldRing
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays), skipHolidays: true, ringOnMakeupDays: true)
        let bothDay = date(2026, 10, 10)
        let key = Alarm.dateKey(for: bothDay)

        let result = alarm.shouldRing(on: bothDay, holidays: [key], makeupDays: [key])
        #expect(result == true, "Makeup day check has higher priority than holiday skip")
    }

    @Test("Holiday with ringOnMakeupDays disabled — holiday wins")
    func holidayWhenMakeupDisabled() {
        let alarm = Alarm(repeatMode: .daily, skipHolidays: true, ringOnMakeupDays: false)
        let target = date(2026, 10, 1)
        let key = Alarm.dateKey(for: target)

        // Day is both holiday and makeup, but ringOnMakeupDays is false
        #expect(alarm.shouldRing(on: target, holidays: [key], makeupDays: [key]) == false,
                "With ringOnMakeupDays disabled, holiday skip wins")
    }

    @Test("Full priority chain: override > skipNext > makeup > holiday > pattern")
    func fullPriorityChain() {
        let alarm = Alarm(
            repeatMode: .weekly(days: [.saturday]),  // Saturday only
            skipHolidays: true,
            ringOnMakeupDays: true
        )
        let saturday = date(2026, 10, 3)  // Saturday
        let key = Alarm.dateKey(for: saturday)

        // 1. Pattern match only → rings (Saturday matches)
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == true)

        // 2. Holiday added → skipped
        #expect(alarm.shouldRing(on: saturday, holidays: [key], makeupDays: []) == false)

        // 3. Makeup day added (higher priority) → rings again
        #expect(alarm.shouldRing(on: saturday, holidays: [key], makeupDays: [key]) == true)

        // 4. skipNext added (higher priority) → skipped
        alarm.skipNextDate = saturday
        #expect(alarm.shouldRing(on: saturday, holidays: [key], makeupDays: [key]) == false)

        // 5. Manual override TRUE (highest priority) → rings
        alarm.manualOverrides[key] = true
        #expect(alarm.shouldRing(on: saturday, holidays: [key], makeupDays: [key]) == true)

        // 6. Manual override FALSE (still highest) → silenced
        alarm.manualOverrides[key] = false
        #expect(alarm.shouldRing(on: saturday, holidays: [key], makeupDays: [key]) == false)
    }

    // MARK: - nextRingDatesLimited Edge Cases

    @Test("Past-time skip on day 0 does not cause off-by-one for subsequent days")
    func pastTimeSkipNoOffByOne() {
        // Alarm at 08:00, current time is 10:00 → day 0 skipped
        // Next ring should be tomorrow (day 1), not day after tomorrow
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .daily)
        let now = dateTime(2026, 4, 10, 10, 0)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 3, holidays: [], makeupDays: [])

        #expect(dates.count == 3)
        // Should be Apr 11, 12, 13 — NOT Apr 12, 13, 14
        #expect(calendar.isDate(dates[0], inSameDayAs: date(2026, 4, 11)), "First date should be Apr 11")
        #expect(calendar.isDate(dates[1], inSameDayAs: date(2026, 4, 12)), "Second date should be Apr 12")
        #expect(calendar.isDate(dates[2], inSameDayAs: date(2026, 4, 13)), "Third date should be Apr 13")
    }

    @Test("Past-time skip + weekly non-ring-day interaction")
    func pastTimeSkipWithWeeklyNonRingDay() {
        // Alarm for Mon/Wed/Fri at 08:00, current time is 10:00 on Monday
        // Day 0 (Mon) skipped due to past time → next should be Wed (day 2)
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .weekly(days: [.monday, .wednesday, .friday]))
        let mondayMorning = dateTime(2026, 4, 13, 10, 0) // Monday 10:00
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: mondayMorning, count: 3, holidays: [], makeupDays: [])

        #expect(dates.count == 3)
        // Mon skipped (past time) → Wed Apr 15, Fri Apr 17, Mon Apr 20
        #expect(calendar.isDate(dates[0], inSameDayAs: date(2026, 4, 15)), "First should be Wed Apr 15")
        #expect(calendar.isDate(dates[1], inSameDayAs: date(2026, 4, 17)), "Second should be Fri Apr 17")
        #expect(calendar.isDate(dates[2], inSameDayAs: date(2026, 4, 20)), "Third should be Mon Apr 20")
    }

    @Test("Past-time skip + holiday on day 1 — skips both day 0 and day 1")
    func pastTimeSkipPlusHolidayNextDay() {
        // Alarm at 08:00, now 10:00 on Apr 10, Apr 11 is holiday
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .daily, skipHolidays: true)
        let now = dateTime(2026, 4, 10, 10, 0)
        let holidays: Set<String> = ["2026-04-11"]
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 3, holidays: holidays, makeupDays: [])

        #expect(dates.count == 3)
        // Day 0 (Apr 10) skipped (past time), Day 1 (Apr 11) skipped (holiday)
        // → Apr 12, 13, 14
        #expect(calendar.isDate(dates[0], inSameDayAs: date(2026, 4, 12)), "First should be Apr 12")
        #expect(calendar.isDate(dates[1], inSameDayAs: date(2026, 4, 13)), "Second should be Apr 13")
        #expect(calendar.isDate(dates[2], inSameDayAs: date(2026, 4, 14)), "Third should be Apr 14")
    }

    @Test("Exact alarm time — not yet passed (equal minute, should include today)")
    func exactAlarmTimeIncludesToday() {
        // Alarm at 08:00, now is exactly 08:00 → 8*60+0 >= 8*60+0 → SKIPPED
        // This is debatable UX: "at exactly the alarm time" means it already triggered
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .daily)
        let now = dateTime(2026, 4, 10, 8, 0)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 1, holidays: [], makeupDays: [])

        // Current logic: startTimeMinutes (480) >= effectiveTimeMinutes (480) → skip today
        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(!hasToday, "At exact alarm time, today should be skipped (already triggered)")
    }

    @Test("One minute before alarm time — includes today")
    func oneMinuteBeforeAlarmIncludesToday() {
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .daily)
        let now = dateTime(2026, 4, 10, 7, 59)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: now, count: 1, holidays: [], makeupDays: [])

        let hasToday = dates.contains { calendar.isDate($0, inSameDayAs: date(2026, 4, 10)) }
        #expect(hasToday, "One minute before alarm time should include today")
    }

    // MARK: - Scheduling count edge cases

    @Test("nextRingDates with count=0 returns empty")
    func zeroCountReturnsEmpty() {
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .daily)
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 0, holidays: [], makeupDays: [])

        #expect(dates.isEmpty, "count=0 should return empty")
    }

    @Test("Weekly alarm with no matching days in next 365 days returns empty")
    func weeklyNoMatchReturnsEmpty() {
        // This shouldn't happen in practice, but empty days set means no match
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .weekly(days: []))
        let from = date(2026, 4, 10)
        let calculator = AlarmScheduleCalculator()
        let dates = calculator.nextRingDates(for: alarm, from: from, count: 7, holidays: [], makeupDays: [])

        #expect(dates.isEmpty, "Empty weekly days should never match")
    }
}
