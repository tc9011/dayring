import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var settings = AppSettings()

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "DayRing v\(version).\(build)"
    }

    var timezoneDisplayName: String {
        settings.timezone.displayName
    }

    func timezoneDisplayName(for s: AppSettings) -> String {
        s.timezone.displayName
    }

    var firstDayDisplayName: String {
        let l = LocaleManager.shared
        return l.localizedString("周") + settings.firstDayOfWeek.shortName
    }

    func firstDayDisplayName(for s: AppSettings) -> String {
        let l = LocaleManager.shared
        return l.localizedString("周") + s.firstDayOfWeek.shortName
    }

    var calendarDisplayName: String {
        guard let cal = settings.selectedCalendar else {
            return LocaleManager.shared.localizedString("无")
        }
        return cal.localizedName
    }

    func calendarDisplayName(for s: AppSettings) -> String {
        guard let cal = s.selectedCalendar else {
            return LocaleManager.shared.localizedString("无")
        }
        return cal.localizedName
    }

    var languageDisplayName: String {
        settings.locale.nativeName
    }

    var appearanceDisplayName: String {
        settings.appearanceMode.localizedName
    }
}
