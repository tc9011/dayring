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
        #expect(alarm.amPmString == "PM")
    }

    @Test("Hour12 conversion: 0 -> 12 AM")
    func midnightConversion() {
        let alarm = Alarm(hour: 0, minute: 0)
        #expect(alarm.hour12 == 12)
        #expect(alarm.amPmString == "AM")
    }

    @Test("Hour12 conversion: 12 -> 12 PM")
    func noonConversion() {
        let alarm = Alarm(hour: 12, minute: 0)
        #expect(alarm.hour12 == 12)
        #expect(alarm.amPmString == "PM")
    }

    @Test("Hour12 conversion: 23 -> 11 PM")
    func lateNightConversion() {
        let alarm = Alarm(hour: 23, minute: 59)
        #expect(alarm.hour12 == 11)
        #expect(alarm.amPmString == "PM")
    }
}
