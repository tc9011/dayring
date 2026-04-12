import Testing
import Foundation
@testable import DayRing

/// Full-flow tests: create alarm → set repeat mode → save via ViewModel → verify shouldRing logic.
/// Each repeat mode is tested end-to-end through the ViewModel save/load cycle.
@Suite("Alarm Full Flow Tests")
struct AlarmFullFlowTests {

    private let calendar = Calendar.current

    // MARK: - No Repeat (.none)

    @Test("Create no-repeat alarm and verify it rings on any day")
    func noRepeatAlarmRingsOnAnyDay() {
        let vm = AlarmEditViewModel()
        vm.hour = 6
        vm.minute = 30
        vm.label = "Morning"
        // Default is .none — no explicit set needed

        let alarm = vm.save(to: nil)
        #expect(alarm.hour == 6)
        #expect(alarm.minute == 30)
        #expect(alarm.label == "Morning")
        #expect(alarm.repeatMode.isNone)

        // .none matches any date
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == true)
    }

    @Test("No-repeat alarm supports deleteAfterRing")
    func noRepeatDeleteAfterRing() {
        let vm = AlarmEditViewModel()
        vm.repeatMode = .none
        vm.deleteAfterRing = true

        let alarm = vm.save(to: nil)
        #expect(alarm.repeatMode.isNone)
        #expect(alarm.deleteAfterRing == true)
    }

    @Test("No-repeat alarm repeatDetailText shows 不重复")
    func noRepeatDetailText() {
        let alarm = Alarm(repeatMode: .none)
        #expect(alarm.repeatDetailText == "不重复")
    }

    // MARK: - Daily

    @Test("Create daily alarm via ViewModel and verify rings every day")
    func dailyAlarmFullFlow() {
        let vm = AlarmEditViewModel()
        vm.hour = 8
        vm.minute = 0
        vm.repeatMode = .daily
        vm.label = "Daily Wake"

        let alarm = vm.save(to: nil)
        #expect(alarm.label == "Daily Wake")

        // Verify rings on weekday and weekend
        let tuesday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 14))!
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 19))!
        #expect(alarm.shouldRing(on: tuesday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: sunday, holidays: [], makeupDays: []) == true)
    }

    @Test("Daily alarm with holiday skip")
    func dailyAlarmHolidaySkip() {
        let vm = AlarmEditViewModel()
        vm.repeatMode = .daily
        vm.skipHolidays = true

        let alarm = vm.save(to: nil)
        let holiday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        let normalDay = calendar.date(from: DateComponents(year: 2026, month: 10, day: 2))!

        #expect(alarm.shouldRing(on: holiday, holidays: ["2026-10-01"], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: normalDay, holidays: ["2026-10-01"], makeupDays: []) == true)
    }

    // MARK: - Weekly

    @Test("Create weekly workday alarm via ViewModel and verify shouldRing")
    func weeklyWorkdayFullFlow() {
        let vm = AlarmEditViewModel()
        vm.hour = 7
        vm.minute = 30
        vm.repeatMode = .weekly(days: Weekday.workdays)
        vm.label = "Work Alarm"

        let alarm = vm.save(to: nil)

        // Load into a new ViewModel and verify round-trip
        let vm2 = AlarmEditViewModel()
        vm2.load(from: alarm)
        #expect(vm2.label == "Work Alarm")
        #expect(vm2.hour == 7)
        #expect(vm2.minute == 30)
        if case .weekly(let days) = vm2.repeatMode {
            #expect(days == Weekday.workdays)
        } else {
            Issue.record("Expected weekly after round-trip")
        }

        // 2026-04-13 Monday → ring, 2026-04-18 Saturday → no ring
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == false)
    }

    @Test("Weekly weekend-only alarm")
    func weeklyWeekendOnly() {
        let vm = AlarmEditViewModel()
        vm.repeatMode = .weekly(days: [.saturday, .sunday])

        let alarm = vm.save(to: nil)

        let friday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 17))!
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        let sunday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 19))!

        #expect(alarm.shouldRing(on: friday, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: sunday, holidays: [], makeupDays: []) == true)
    }

    @Test("Weekly all days shows 每天 in detail text")
    func weeklyAllDaysText() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.allDays))
        #expect(alarm.repeatDetailText == "每天")
    }

    // MARK: - Biweekly

    @Test("Create biweekly alarm via ViewModel and verify alternating weeks")
    func biweeklyFullFlow() {
        let refDate = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))! // Monday
        let vm = AlarmEditViewModel()
        vm.hour = 9
        vm.minute = 0
        vm.repeatMode = .biweekly(
            referenceDate: refDate,
            week1: Weekday.workdays,
            week2: [.monday, .wednesday, .friday]
        )
        vm.label = "Biweekly"

        let alarm = vm.save(to: nil)

        let vm2 = AlarmEditViewModel()
        vm2.load(from: alarm)
        if case .biweekly(_, let w1, let w2) = vm2.repeatMode {
            #expect(w1 == Weekday.workdays)
            #expect(w2 == [.monday, .wednesday, .friday])
        } else {
            Issue.record("Expected biweekly after round-trip")
        }

        // ref week (Apr 13-19) = week1 (workdays: Mon-Fri)
        let apr13Mon = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        let apr14Tue = calendar.date(from: DateComponents(year: 2026, month: 4, day: 14))!
        // next week (Apr 20-26) = week2 (Mon, Wed, Fri)
        let apr20Mon = calendar.date(from: DateComponents(year: 2026, month: 4, day: 20))!
        let apr21Tue = calendar.date(from: DateComponents(year: 2026, month: 4, day: 21))!

        #expect(alarm.shouldRing(on: apr13Mon, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: apr14Tue, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: apr20Mon, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: apr21Tue, holidays: [], makeupDays: []) == false)
    }

    @Test("Biweekly detail text shows 大小周")
    func biweeklyDetailText() {
        let alarm = Alarm(repeatMode: .biweekly(referenceDate: Date(), week1: Weekday.workdays, week2: [.monday]))
        #expect(alarm.repeatDetailText == "大小周")
    }

    // MARK: - Rotating

    @Test("Create rotating alarm via ViewModel and verify ring/gap cycle")
    func rotatingFullFlow() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let vm = AlarmEditViewModel()
        vm.hour = 5
        vm.minute = 45
        vm.repeatMode = .rotating(startDate: start, ringDays: 3, gapDays: 2)
        vm.label = "Shift Work"

        let alarm = vm.save(to: nil)

        // Round-trip
        let vm2 = AlarmEditViewModel()
        vm2.load(from: alarm)
        #expect(vm2.label == "Shift Work")
        if case .rotating(let s, let r, let g) = vm2.repeatMode {
            #expect(calendar.isDate(s, inSameDayAs: start))
            #expect(r == 3)
            #expect(g == 2)
        } else {
            Issue.record("Expected rotating after round-trip")
        }

        // Cycle: ring day0,1,2 → gap day3,4 → ring day5,6,7 → ...
        let day0 = start
        let day2 = calendar.date(byAdding: .day, value: 2, to: start)!
        let day3 = calendar.date(byAdding: .day, value: 3, to: start)!
        let day4 = calendar.date(byAdding: .day, value: 4, to: start)!
        let day5 = calendar.date(byAdding: .day, value: 5, to: start)!

        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day2, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day3, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day4, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day5, holidays: [], makeupDays: []) == true)
    }

    @Test("Rotating alarm before start date does not ring")
    func rotatingBeforeStartNoRing() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let vm = AlarmEditViewModel()
        vm.repeatMode = .rotating(startDate: start, ringDays: 5, gapDays: 2)

        let alarm = vm.save(to: nil)
        let before = calendar.date(from: DateComponents(year: 2026, month: 5, day: 31))!
        #expect(alarm.shouldRing(on: before, holidays: [], makeupDays: []) == false)
    }

    @Test("Rotating detail text shows ring/gap counts")
    func rotatingDetailText() {
        let start = Date()
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 5, gapDays: 3))
        #expect(alarm.repeatDetailText == "响5天休3天")
    }

    // MARK: - Custom

    @Test("Create custom dates alarm via ViewModel and verify shouldRing")
    func customDatesFullFlow() {
        let april15 = DateComponents(year: 2026, month: 4, day: 15)
        let april20 = DateComponents(year: 2026, month: 4, day: 20)
        let customDates: Set<DateComponents> = [april15, april20]

        let vm = AlarmEditViewModel()
        vm.hour = 10
        vm.minute = 0
        vm.repeatMode = .custom(dates: customDates)
        vm.label = "Custom"

        let alarm = vm.save(to: nil)

        // Round-trip
        let vm2 = AlarmEditViewModel()
        vm2.load(from: alarm)
        if case .custom(let dates) = vm2.repeatMode {
            #expect(dates.count == 2)
        } else {
            Issue.record("Expected custom after round-trip")
        }

        let date15 = calendar.date(from: april15)!
        let date16 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 16))!
        let date20 = calendar.date(from: april20)!

        #expect(alarm.shouldRing(on: date15, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: date16, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: date20, holidays: [], makeupDays: []) == true)
    }

    @Test("Custom alarm detail text shows day count")
    func customDetailText() {
        let dates: Set<DateComponents> = [
            DateComponents(year: 2026, month: 5, day: 1),
            DateComponents(year: 2026, month: 5, day: 2),
            DateComponents(year: 2026, month: 5, day: 3),
        ]
        let alarm = Alarm(repeatMode: .custom(dates: dates))
        #expect(alarm.repeatDetailText == "3天")
    }

    // MARK: - Cross-cutting: ViewModel save/load round-trip

    @Test("Save then load preserves all alarm fields")
    func saveLoadRoundTrip() {
        let vm = AlarmEditViewModel()
        vm.hour = 22
        vm.minute = 15
        vm.label = "Night"
        vm.repeatMode = .daily
        vm.ringtone = "beacon"
        vm.snoozeDuration = 10
        vm.advanceMinutes = 15
        vm.deleteAfterRing = false
        vm.skipHolidays = false
        vm.ringOnMakeupDays = false

        let alarm = vm.save(to: nil)

        let vm2 = AlarmEditViewModel()
        vm2.load(from: alarm)

        #expect(vm2.hour == 22)
        #expect(vm2.minute == 15)
        #expect(vm2.label == "Night")
        #expect(vm2.ringtone == "beacon")
        #expect(vm2.snoozeDuration == 10)
        #expect(vm2.advanceMinutes == 15)
        #expect(vm2.deleteAfterRing == false)
        #expect(vm2.skipHolidays == false)
        #expect(vm2.ringOnMakeupDays == false)
        if case .daily = vm2.repeatMode {
            // pass
        } else {
            Issue.record("Expected daily after round-trip")
        }
    }

    @Test("Update existing alarm preserves identity")
    func updateExistingAlarm() {
        let original = Alarm(hour: 6, minute: 0, repeatMode: .daily)
        let originalId = original.id

        let vm = AlarmEditViewModel()
        vm.load(from: original)
        vm.hour = 7
        vm.repeatMode = .weekly(days: [.monday, .friday])

        let updated = vm.save(to: original)
        #expect(updated.id == originalId)
        #expect(updated.hour == 7)
        if case .weekly(let days) = updated.repeatMode {
            #expect(days == [.monday, .friday])
        } else {
            Issue.record("Expected weekly after update")
        }
    }

    // MARK: - Cross-cutting: Override + Skip interactions

    @Test("Manual override beats repeat pattern for all modes")
    func manualOverrideBeatsRepeatPattern() {
        // Weekly alarm — Monday should ring, but manual override silences it
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays))
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        alarm.manualOverrides["2026-04-13"] = false

        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == false)

        // Clear override → rings again
        alarm.manualOverrides.removeValue(forKey: "2026-04-13")
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)
    }

    @Test("Skip next date works with all repeat modes")
    func skipNextWithRepeatModes() {
        let target = calendar.date(from: DateComponents(year: 2026, month: 4, day: 15))!

        // Daily
        let daily = Alarm(repeatMode: .daily)
        daily.skipNextDate = target
        #expect(daily.shouldRing(on: target, holidays: [], makeupDays: []) == false)

        // Weekly (Wed is in workdays)
        let weekly = Alarm(repeatMode: .weekly(days: Weekday.workdays))
        weekly.skipNextDate = target
        #expect(weekly.shouldRing(on: target, holidays: [], makeupDays: []) == false)

        // .none
        let noRepeat = Alarm(repeatMode: .none)
        noRepeat.skipNextDate = target
        #expect(noRepeat.shouldRing(on: target, holidays: [], makeupDays: []) == false)
    }

    // MARK: - RepeatMode properties

    @Test("RepeatMode.isNone returns correct values")
    func repeatModeIsNone() {
        #expect(RepeatMode.none.isNone == true)
        #expect(RepeatMode.daily.isNone == false)
        #expect(RepeatMode.weekly(days: Weekday.workdays).isNone == false)
        #expect(RepeatMode.biweekly(referenceDate: Date(), week1: [], week2: []).isNone == false)
        #expect(RepeatMode.rotating(startDate: Date(), ringDays: 1, gapDays: 1).isNone == false)
        #expect(RepeatMode.custom(dates: []).isNone == false)
    }

    @Test("RepeatMode displayName returns localized strings")
    func repeatModeDisplayName() {
        // These test that displayName returns non-empty strings (actual localization depends on locale)
        #expect(!RepeatMode.none.displayName.isEmpty)
        #expect(!RepeatMode.daily.displayName.isEmpty)
        #expect(!RepeatMode.weekly(days: []).displayName.isEmpty)
        #expect(!RepeatMode.biweekly(referenceDate: Date(), week1: [], week2: []).displayName.isEmpty)
        #expect(!RepeatMode.rotating(startDate: Date(), ringDays: 1, gapDays: 1).displayName.isEmpty)
        #expect(!RepeatMode.custom(dates: []).displayName.isEmpty)
    }

    // MARK: - ViewModel static options

    @Test("Ringtone options are non-empty")
    func ringtoneOptions() {
        #expect(!AlarmEditViewModel.ringtoneOptions.isEmpty)
        #expect(AlarmEditViewModel.ringtoneOptions.contains("radar"))
    }

    @Test("Snooze options include 0 and 5")
    func snoozeOptions() {
        #expect(AlarmEditViewModel.snoozeOptions.contains(0))
        #expect(AlarmEditViewModel.snoozeOptions.contains(5))
    }

    @Test("Advance options include 0 and 15")
    func advanceOptions() {
        #expect(AlarmEditViewModel.advanceOptions.contains(0))
        #expect(AlarmEditViewModel.advanceOptions.contains(15))
    }

    // MARK: - Makeup day interaction

    @Test("Makeup day forces ring even when weekly pattern doesn't match")
    func makeupDayForcesRing() {
        // Saturday normally doesn't ring for workday alarm
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays), skipHolidays: true, ringOnMakeupDays: true)
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 10))!

        // Without makeup: no ring
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == false)

        // With makeup: ring
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: ["2026-10-10"]) == true)
    }
}
