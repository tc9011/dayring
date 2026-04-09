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

    var firstDayDisplayName: String {
        "周\(settings.firstDayOfWeek.shortName)"
    }

    var calendarDisplayName: String {
        settings.selectedCalendars.map(\.rawValue).sorted().joined(separator: "、")
    }

    var languageDisplayName: String {
        settings.locale.rawValue
    }

    var appearanceDisplayName: String {
        settings.appearanceMode.rawValue
    }
}
