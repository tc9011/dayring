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

    @Test("Default calendar is Chinese calendar")
    func defaultCalendar() {
        let settings = AppSettings()
        #expect(settings.selectedCalendar == .chineseCalendar)
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

    // MARK: - Calendar Single Select

    @Test("selectedCalendar can be set to nil (none)")
    func calendarSetToNone() {
        let settings = AppSettings()
        settings.selectedCalendar = nil
        #expect(settings.selectedCalendar == nil)
    }

    @Test("selectedCalendar round-trips through chineseCalendar")
    func calendarSetToChineseCalendar() {
        let settings = AppSettings()
        settings.selectedCalendar = nil
        #expect(settings.selectedCalendar == nil)
        settings.selectedCalendar = .chineseCalendar
        #expect(settings.selectedCalendar == .chineseCalendar)
    }

    @Test("ViewModel calendarDisplayName returns 无 when nil")
    func calendarDisplayNameNone() {
        let vm = SettingsViewModel()
        vm.settings.selectedCalendar = nil
        #expect(vm.calendarDisplayName == "无")
    }

    @Test("ViewModel calendarDisplayName returns 农历 after re-selecting")
    func calendarDisplayNameReselect() {
        let vm = SettingsViewModel()
        vm.settings.selectedCalendar = nil
        #expect(vm.calendarDisplayName == "无")
        vm.settings.selectedCalendar = .chineseCalendar
        #expect(vm.calendarDisplayName == "农历")
    }

    @Test("ViewModel languageDisplayName returns 跟随系统")
    func languageDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.languageDisplayName == "跟随系统")
    }

    // MARK: - AppearanceMode

    @Test("Default appearance mode is system")
    func defaultAppearanceMode() {
        let settings = AppSettings()
        #expect(settings.appearanceMode == .system)
    }

    @Test("Appearance mode can be set to light")
    func setAppearanceLight() {
        let settings = AppSettings()
        settings.appearanceMode = .light
        #expect(settings.appearanceMode == .light)
    }

    @Test("Appearance mode can be set to dark")
    func setAppearanceDark() {
        let settings = AppSettings()
        settings.appearanceMode = .dark
        #expect(settings.appearanceMode == .dark)
    }

    @Test("AppearanceMode has correct colorScheme mapping")
    func appearanceColorScheme() {
        #expect(AppearanceMode.system.colorScheme == nil)
        #expect(AppearanceMode.light.colorScheme == .light)
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }

    @Test("ViewModel appearanceDisplayName returns 自动 for system")
    func appearanceDisplayName() {
        let vm = SettingsViewModel()
        #expect(vm.appearanceDisplayName == "自动")
    }

    // MARK: - Timezone and First Day of Week Settings

    @Test("First day of week can be changed to Sunday")
    func changeFirstDayToSunday() {
        let settings = AppSettings()
        settings.firstDayOfWeek = .sunday
        #expect(settings.firstDayOfWeek == .sunday)
    }

    @Test("Timezone can be changed to a specific timezone")
    func changeTimezoneToSpecific() {
        let settings = AppSettings()
        settings.timezone = .specific(identifier: "America/New_York")
        if case .specific(let id) = settings.timezone {
            #expect(id == "America/New_York")
        } else {
            Issue.record("Expected specific timezone")
        }
    }

    @Test("ViewModel firstDayDisplayName updates after change")
    func firstDayDisplayNameAfterChange() {
        let vm = SettingsViewModel()
        vm.settings.firstDayOfWeek = .sunday
        #expect(vm.firstDayDisplayName == "周日")
    }

    @Test("ViewModel timezoneDisplayName updates after change")
    func timezoneDisplayNameAfterChange() {
        let vm = SettingsViewModel()
        vm.settings.timezone = .specific(identifier: "America/New_York")
        #expect(!vm.timezoneDisplayName.isEmpty)
        #expect(vm.timezoneDisplayName != "跟随系统")
    }

    // MARK: - Timezone displayName respects app locale

    @Test("Timezone displayName uses app locale, not system locale")
    func timezoneDisplayNameRespectsAppLocale() {
        let saved = LocaleManager.shared.currentLocale
        defer { LocaleManager.shared.currentLocale = saved }

        LocaleManager.shared.currentLocale = .en
        let tz = TimezoneOption.specific(identifier: "Asia/Shanghai")
        let name = tz.displayName
        #expect(!name.contains("中国"), "Timezone name should be in English when app locale is English, got: \(name)")
        #expect(name.contains("China") || name.contains("Shanghai"),
                "Expected English timezone name containing 'China' or 'Shanghai', got: \(name)")
    }

    @Test("Timezone displayName shows Chinese when app locale is zh-Hans")
    func timezoneDisplayNameInChinese() {
        let saved = LocaleManager.shared.currentLocale
        defer { LocaleManager.shared.currentLocale = saved }

        LocaleManager.shared.currentLocale = .zhHans
        let tz = TimezoneOption.specific(identifier: "Asia/Shanghai")
        let name = tz.displayName
        #expect(name.contains("中国"), "Timezone name should be Chinese when app locale is zh-Hans, got: \(name)")
    }
}
