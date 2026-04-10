import Testing
import Foundation
@testable import DayRing

@Suite("AlarmListViewModel Tests")
struct AlarmListViewModelTests {

    private func makeDate(year: Int = 2026, month: Int = 4, day: Int = 10, hour: Int = 11, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }

    // MARK: - nextRingDateTime

    @Test("nextRingDateTime returns today if alarm time is later today and alarm is daily")
    func nextRingDateTimeTodayLater() {
        let now = makeDate(hour: 10, minute: 0)
        let alarm = Alarm(hour: 14, minute: 30, repeatMode: .daily)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        #expect(cal.component(.hour, from: result!) == 14)
        #expect(cal.component(.minute, from: result!) == 30)
        #expect(cal.isDate(result!, inSameDayAs: now))
    }

    @Test("nextRingDateTime returns tomorrow if alarm time already passed today")
    func nextRingDateTimeTomorrowIfPassed() {
        let now = makeDate(hour: 15, minute: 0)
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: now)!
        #expect(cal.isDate(result!, inSameDayAs: tomorrow))
        #expect(cal.component(.hour, from: result!) == 7)
    }

    @Test("nextRingDateTime returns nil for disabled alarm")
    func nextRingDateTimeDisabled() {
        let now = makeDate(hour: 10, minute: 0)
        let alarm = Alarm(hour: 14, minute: 0, repeatMode: .daily, isEnabled: false)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result == nil)
    }

    @Test("nextRingDateTime skips non-matching weekday for weekly alarm")
    func nextRingDateTimeSkipsWeekday() {
        // April 10, 2026 is Friday (weekday 6 in gregorian)
        let now = makeDate(year: 2026, month: 4, day: 10, hour: 10, minute: 0)
        // Only Monday
        let alarm = Alarm(hour: 8, minute: 0, repeatMode: .weekly(days: [.monday]))
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        // Next Monday after April 10 (Fri) is April 13
        let cal = Calendar.current
        #expect(cal.component(.day, from: result!) == 13)
        #expect(cal.component(.month, from: result!) == 4)
    }

    // MARK: - sortedByNextRing

    @Test("sortedByNextRing orders by nearest ring time, not by hour")
    func sortedByNextRingTime() {
        // Now is 10:30. Alarm at 11:00 today is closer than alarm at 07:00 tomorrow.
        let now = makeDate(hour: 10, minute: 30)
        let alarm7 = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let alarm11 = Alarm(hour: 11, minute: 0, repeatMode: .daily)
        let alarm19 = Alarm(hour: 19, minute: 0, repeatMode: .daily)

        let vm = AlarmListViewModel()
        vm.alarms = [alarm7, alarm19, alarm11]

        let sorted = vm.sortedByNextRing(now: now)
        // 11:00 today (30 min away) < 19:00 today (8.5h away) < 07:00 tomorrow (~20.5h away)
        #expect(sorted.count == 3)
        #expect(sorted[0].hour == 11)
        #expect(sorted[1].hour == 19)
        #expect(sorted[2].hour == 7)
    }

    @Test("sortedByNextRing puts disabled alarms at the end")
    func sortedDisabledAtEnd() {
        let now = makeDate(hour: 10, minute: 0)
        let enabled = Alarm(hour: 14, minute: 0, repeatMode: .daily, isEnabled: true)
        let disabled = Alarm(hour: 11, minute: 0, repeatMode: .daily, isEnabled: false)

        let vm = AlarmListViewModel()
        vm.alarms = [disabled, enabled]

        let sorted = vm.sortedByNextRing(now: now)
        #expect(sorted[0].hour == 14)
        #expect(sorted[1].hour == 11)
    }

    @Test("sortedByNextRing: alarm at 00:00 tomorrow vs 23:00 today")
    func sortedMidnightVsLateEvening() {
        // Now is 22:00. 23:00 today is 1h away. 00:00 tomorrow is 2h away.
        let now = makeDate(hour: 22, minute: 0)
        let alarm23 = Alarm(hour: 23, minute: 0, repeatMode: .daily)
        let alarm0 = Alarm(hour: 0, minute: 0, repeatMode: .daily)

        let vm = AlarmListViewModel()
        vm.alarms = [alarm0, alarm23]

        let sorted = vm.sortedByNextRing(now: now)
        #expect(sorted[0].hour == 23) // 1h away
        #expect(sorted[1].hour == 0)  // 2h away
    }

    // MARK: - nextAlarmText

    @Test("nextAlarmText picks the nearest alarm, not the first by hour")
    func nextAlarmTextPicksNearest() {
        // Now is 10:30. Alarm at 10:45 is 15 min away. Alarm at 7:00 is ~20.5h away.
        let now = makeDate(hour: 10, minute: 30)
        let alarm7 = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let alarm1045 = Alarm(hour: 10, minute: 45, repeatMode: .daily)

        let vm = AlarmListViewModel()
        vm.alarms = [alarm7, alarm1045]

        let text = vm.nextAlarmText(now: now)
        #expect(text != nil)
        // Should show ~15 minutes (0 hours 15 minutes), not ~20 hours
        #expect(text!.contains("0"))     // 0 hours
        #expect(text!.contains("15") || text!.contains("14"))  // ~15 minutes (allow 14 from rounding)
    }

    @Test("nextAlarmText returns nil when no alarms enabled")
    func nextAlarmTextNilWhenNoEnabled() {
        let now = makeDate(hour: 10, minute: 0)
        let alarm = Alarm(hour: 14, minute: 0, repeatMode: .daily, isEnabled: false)

        let vm = AlarmListViewModel()
        vm.alarms = [alarm]

        let text = vm.nextAlarmText(now: now)
        #expect(text == nil)
    }

    @Test("nextAlarmText returns nil when alarms list is empty")
    func nextAlarmTextNilWhenEmpty() {
        let vm = AlarmListViewModel()
        vm.alarms = []
        #expect(vm.nextAlarmText(now: makeDate()) == nil)
    }

    // MARK: - nextRingDateTime edge cases

    @Test("nextRingDateTime for no-repeat alarm rings today if time not passed")
    func nextRingDateTimeNoRepeatToday() {
        let now = makeDate(hour: 8, minute: 0)
        let alarm = Alarm(hour: 12, minute: 0, repeatMode: .none)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        #expect(cal.isDate(result!, inSameDayAs: now))
        #expect(cal.component(.hour, from: result!) == 12)
    }

    @Test("nextRingDateTime for no-repeat alarm rings tomorrow if time already passed")
    func nextRingDateTimeNoRepeatTomorrow() {
        let now = makeDate(hour: 15, minute: 0)
        let alarm = Alarm(hour: 9, minute: 0, repeatMode: .none)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: now)!
        #expect(cal.isDate(result!, inSameDayAs: tomorrow))
    }

    @Test("nextRingDateTime at exact alarm minute returns tomorrow")
    func nextRingDateTimeExactMinute() {
        // If now == alarm time, alarm already passed → tomorrow
        let now = makeDate(hour: 7, minute: 0)
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: now)!
        #expect(cal.isDate(result!, inSameDayAs: tomorrow))
    }

    @Test("nextRingDateTime preserves correct hour and minute in result")
    func nextRingDateTimePreservesTime() {
        let now = makeDate(hour: 6, minute: 0)
        let alarm = Alarm(hour: 23, minute: 45, repeatMode: .daily)
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        #expect(cal.component(.hour, from: result!) == 23)
        #expect(cal.component(.minute, from: result!) == 45)
    }

    @Test("nextRingDateTime for weekly workday alarm skips weekend")
    func nextRingDateTimeSkipsWeekend() {
        // April 10, 2026 is Friday. Workday alarm at 7:00. Now is 20:00 Friday.
        // Next workday is Monday April 13.
        let now = makeDate(year: 2026, month: 4, day: 10, hour: 20, minute: 0)
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .weekly(days: Weekday.workdays))
        let vm = AlarmListViewModel()

        let result = vm.nextRingDateTime(for: alarm, now: now)
        #expect(result != nil)
        let cal = Calendar.current
        #expect(cal.component(.day, from: result!) == 13)
    }

    // MARK: - sortedByNextRing edge cases

    @Test("sortedByNextRing returns empty for empty alarms")
    func sortedByNextRingEmpty() {
        let vm = AlarmListViewModel()
        vm.alarms = []
        #expect(vm.sortedByNextRing(now: makeDate()).isEmpty)
    }

    @Test("sortedByNextRing with all disabled returns all (in original order)")
    func sortedByNextRingAllDisabled() {
        let now = makeDate(hour: 10, minute: 0)
        let a1 = Alarm(hour: 8, minute: 0, repeatMode: .daily, isEnabled: false)
        let a2 = Alarm(hour: 12, minute: 0, repeatMode: .daily, isEnabled: false)

        let vm = AlarmListViewModel()
        vm.alarms = [a1, a2]

        let sorted = vm.sortedByNextRing(now: now)
        #expect(sorted.count == 2)
    }

    @Test("sortedByNextRing with single alarm returns it")
    func sortedByNextRingSingle() {
        let now = makeDate(hour: 10, minute: 0)
        let alarm = Alarm(hour: 14, minute: 0, repeatMode: .daily)

        let vm = AlarmListViewModel()
        vm.alarms = [alarm]

        let sorted = vm.sortedByNextRing(now: now)
        #expect(sorted.count == 1)
        #expect(sorted[0].hour == 14)
    }

    @Test("sortedByNextRing mixed repeat modes: daily before weekly-skip")
    func sortedByNextRingMixedModes() {
        // April 10, 2026 is Friday. Now 10:00.
        // Daily 11:00 → rings today at 11:00 (1h away)
        // Weekly Mon-only 8:00 → next Monday April 13 at 8:00 (~70h away)
        let now = makeDate(year: 2026, month: 4, day: 10, hour: 10, minute: 0)
        let daily = Alarm(hour: 11, minute: 0, repeatMode: .daily)
        let weeklyMon = Alarm(hour: 8, minute: 0, repeatMode: .weekly(days: [.monday]))

        let vm = AlarmListViewModel()
        vm.alarms = [weeklyMon, daily]

        let sorted = vm.sortedByNextRing(now: now)
        #expect(sorted[0].hour == 11)  // daily, today
        #expect(sorted[1].hour == 8)   // weekly Mon, 3 days away
    }

    // MARK: - statusInfo

    @Test("statusInfo returns disabled text when alarm is off")
    func statusInfoDisabled() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, isEnabled: false)
        let vm = AlarmListViewModel()
        let info = vm.statusInfo(for: alarm)
        #expect(info.color == .gray)
    }

    @Test("statusInfo returns green when alarm rings tomorrow")
    func statusInfoRingsTomorrow() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily, isEnabled: true)
        let vm = AlarmListViewModel()
        let info = vm.statusInfo(for: alarm)
        #expect(info.color == .green)
    }

    // MARK: - skipNext / isSkipActive

    @Test("isSkipActive returns false by default")
    func isSkipActiveFalseByDefault() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let vm = AlarmListViewModel()
        #expect(vm.isSkipActive(alarm) == false)
    }

    @Test("isSkipActive returns true when skipNextDate is set")
    func isSkipActiveTrueWhenSet() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        alarm.skipNextDate = Date()
        let vm = AlarmListViewModel()
        #expect(vm.isSkipActive(alarm) == true)
    }

    @Test("skipNext sets skipNextDate, calling again clears it")
    func skipNextToggles() {
        let alarm = Alarm(hour: 7, minute: 0, repeatMode: .daily)
        let vm = AlarmListViewModel()

        #expect(alarm.skipNextDate == nil)
        vm.skipNext(alarm)
        #expect(alarm.skipNextDate != nil)
        vm.skipNext(alarm)
        #expect(alarm.skipNextDate == nil)
    }
}
