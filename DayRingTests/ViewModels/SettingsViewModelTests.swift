import Testing
@testable import DayRing

@Suite("SettingsViewModel Tests")
struct SettingsViewModelTests {

    // MARK: - AppSettings Defaults

    @Test("Default time format is 24h")
    func defaultTimeFormat() {
        let settings = AppSettings()
        #expect(settings.timeFormat == .h24)
    }

    @Test("Default first day of week is Monday")
    func defaultFirstDay() {
        let settings = AppSettings()
        #expect(settings.firstDayOfWeek == .monday)
    }

    @Test("Default locale is system")
    func defaultLocale() {
        let settings = AppSettings()
        #expect(settings.locale == .system)
    }

    @Test("Default calendar includes lunar")
    func defaultCalendar() {
        let settings = AppSettings()
        #expect(settings.selectedCalendars.contains(.lunar))
    }

    @Test("Time format can be toggled to 12h")
    func toggleTimeFormat() {
        let settings = AppSettings()
        settings.timeFormat = .h12
        #expect(settings.timeFormat == .h12)
    }

    @Test("Timezone default is system")
    func defaultTimezone() {
        let settings = AppSettings()
        if case .system = settings.timezone {
        } else {
            Issue.record("Default timezone should be .system")
        }
    }

    // MARK: - SettingsViewModel

    @Test("ViewModel appVersion returns expected format")
    func appVersionFormat() {
        let vm = SettingsViewModel()
        #expect(vm.appVersion.hasPrefix("DayRing v"))
    }

    @Test("ViewModel timezoneDisplayName returns 跟随系统")
    func timezoneDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.timezoneDisplayName == "跟随系统")
    }

    @Test("ViewModel firstDayDisplayName returns 周一")
    func firstDayDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.firstDayDisplayName == "周一")
    }

    @Test("ViewModel calendarDisplayName returns 农历")
    func calendarDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.calendarDisplayName == "农历")
    }

    @Test("ViewModel languageDisplayName returns 跟随系统")
    func languageDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.languageDisplayName == "跟随系统")
    }
}
