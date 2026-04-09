import Testing
@testable import DayRing

@Suite("AlarmEditViewModel Tests")
struct AlarmEditViewModelTests {

    @Test("Default state is 07:00 with workday weekly repeat")
    func defaultState() {
        let vm = AlarmEditViewModel()
        #expect(vm.hour == 7)
        #expect(vm.minute == 0)
        #expect(vm.label == "")
        #expect(vm.ringtone == "radar")
        #expect(vm.snoozeDuration == 5)
        #expect(vm.advanceMinutes == 0)
        #expect(vm.deleteAfterRing == false)
        #expect(vm.isEnabled == true)
        #expect(vm.skipHolidays == true)
        #expect(vm.ringOnMakeupDays == true)
        #expect(vm.isEditing == false)
    }

    @Test("Load populates all fields from alarm")
    func loadFromAlarm() {
        let alarm = Alarm(
            hour: 8,
            minute: 30,
            label: "Work",
            repeatMode: .daily,
            ringtone: "beacon",
            snoozeDuration: 10,
            advanceMinutes: 15,
            deleteAfterRing: true,
            isEnabled: false,
            skipHolidays: false,
            ringOnMakeupDays: false
        )
        let vm = AlarmEditViewModel()
        vm.load(from: alarm)

        #expect(vm.hour == 8)
        #expect(vm.minute == 30)
        #expect(vm.label == "Work")
        #expect(vm.ringtone == "beacon")
        #expect(vm.snoozeDuration == 10)
        #expect(vm.advanceMinutes == 15)
        #expect(vm.deleteAfterRing == true)
        #expect(vm.isEnabled == false)
        #expect(vm.skipHolidays == false)
        #expect(vm.ringOnMakeupDays == false)
        #expect(vm.isEditing == true)
    }

    @Test("Load from nil does not change defaults")
    func loadFromNil() {
        let vm = AlarmEditViewModel()
        vm.load(from: nil)
        #expect(vm.hour == 7)
        #expect(vm.minute == 0)
        #expect(vm.isEditing == false)
    }

    @Test("Save creates new alarm when nil")
    func saveNewAlarm() {
        let vm = AlarmEditViewModel()
        vm.hour = 9
        vm.minute = 45
        vm.label = "Meeting"
        vm.skipHolidays = false

        let alarm = vm.save(to: nil)
        #expect(alarm.hour == 9)
        #expect(alarm.minute == 45)
        #expect(alarm.label == "Meeting")
        #expect(alarm.skipHolidays == false)
    }

    @Test("Save updates existing alarm")
    func saveExistingAlarm() {
        let existing = Alarm(hour: 6, minute: 0)
        let vm = AlarmEditViewModel()
        vm.load(from: existing)
        vm.hour = 10
        vm.minute = 15

        let updated = vm.save(to: existing)
        #expect(updated.hour == 10)
        #expect(updated.minute == 15)
        #expect(updated === existing) // same reference
    }

    @Test("advanceMinutesText returns correct strings")
    func advanceMinutesText() {
        let vm = AlarmEditViewModel()
        #expect(vm.advanceMinutesText == "不提前")

        vm.advanceMinutes = 10
        #expect(vm.advanceMinutesText == "10 分钟")

        vm.advanceMinutes = 30
        #expect(vm.advanceMinutesText == "30 分钟")
    }

    @Test("snoozeDurationText returns correct strings")
    func snoozeDurationText() {
        let vm = AlarmEditViewModel()
        #expect(vm.snoozeDurationText == "5 分钟")

        vm.snoozeDuration = 0
        #expect(vm.snoozeDurationText == "关闭")

        vm.snoozeDuration = 15
        #expect(vm.snoozeDurationText == "15 分钟")
    }

    @Test("Load preserves repeat mode")
    func loadRepeatMode() {
        let alarm = Alarm(
            hour: 7,
            minute: 0,
            repeatMode: .biweekly(week1: Weekday.workdays, week2: [.monday, .wednesday])
        )
        let vm = AlarmEditViewModel()
        vm.load(from: alarm)
        if case .biweekly(let w1, let w2) = vm.repeatMode {
            #expect(w1 == Weekday.workdays)
            #expect(w2 == [.monday, .wednesday])
        } else {
            Issue.record("Expected biweekly repeat mode")
        }
    }
}
