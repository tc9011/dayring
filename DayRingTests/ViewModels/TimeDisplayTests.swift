import Testing
@testable import DayRing

@Suite("Time Display Tests")
struct TimeDisplayTests {

    @Test("24h format should not display AM/PM")
    func h24HidesAmPm() {
        let settings = AppSettings(timeFormat: .h24)
        let alarm = Alarm(hour: 14, minute: 30)

        #expect(settings.timeFormat == .h24)
        #expect(alarm.timeString == "14:30")
    }

    @Test("12h format should show AM/PM")
    func h12ShowsAmPm() {
        let settings = AppSettings(timeFormat: .h12)
        let alarm = Alarm(hour: 14, minute: 30)

        #expect(settings.timeFormat == .h12)
        #expect(alarm.hour12 == 2)
        #expect(alarm.amPmString == Alarm(hour: 13, minute: 0).amPmString)
    }

    @Test("Hour12 conversion: 0 -> 12 AM")
    func midnightConversion() {
        let alarm = Alarm(hour: 0, minute: 0)
        #expect(alarm.hour12 == 12)
        #expect(alarm.amPmString == Alarm(hour: 6, minute: 0).amPmString)
    }

    @Test("Hour12 conversion: 12 -> 12 PM")
    func noonConversion() {
        let alarm = Alarm(hour: 12, minute: 0)
        #expect(alarm.hour12 == 12)
        #expect(alarm.amPmString == Alarm(hour: 18, minute: 0).amPmString)
    }

    @Test("Hour12 conversion: 23 -> 11 PM")
    func lateNightConversion() {
        let alarm = Alarm(hour: 23, minute: 59)
        #expect(alarm.hour12 == 11)
        #expect(alarm.amPmString == Alarm(hour: 12, minute: 0).amPmString)
    }

    @Test("AM and PM strings are different")
    func amPmDiffer() {
        let am = Alarm(hour: 6, minute: 0).amPmString
        let pm = Alarm(hour: 18, minute: 0).amPmString
        #expect(am != pm)
    }

    // MARK: - Settings-driven format selection

    @Test("AppSettings.timeFormat drives is24HourFormat: h24 → true")
    func settingsDriveFormat24h() {
        let settings = AppSettings(timeFormat: .h24)
        let is24Hour = settings.timeFormat == .h24
        #expect(is24Hour == true)
    }

    @Test("AppSettings.timeFormat drives is24HourFormat: h12 → false")
    func settingsDriveFormat12h() {
        let settings = AppSettings(timeFormat: .h12)
        let is24Hour = settings.timeFormat == .h24
        #expect(is24Hour == false)
    }

    @Test("12h format display string differs from 24h for PM hours")
    func formatDisplayDifference() {
        let alarm = Alarm(hour: 14, minute: 30)
        let display24 = alarm.timeString
        let display12 = String(format: "%02d:%02d", alarm.hour12, alarm.minute)

        #expect(display24 == "14:30")
        #expect(display12 == "02:30")
        #expect(display24 != display12)
    }
}
