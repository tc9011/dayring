import Foundation
import SwiftUI
import SwiftData

@Model
final class AppSettings {
    var timeFormat: TimeFormat
    var firstDayOfWeek: Weekday
    var locale: AppLocale
    var appearanceMode: AppearanceMode
    @Attribute(originalName: "selectedCalendarsData")
    var selectedCalendarData: Data
    var timezoneData: Data

    var selectedCalendar: CalendarType? {
        get {
            guard let raw = String(data: selectedCalendarData, encoding: .utf8),
                  !raw.isEmpty else {
                return nil
            }
            // Handle legacy JSON array format: ["农历"]
            if raw.hasPrefix("[") {
                guard let array = try? JSONDecoder().decode([String].self, from: selectedCalendarData),
                      let first = array.first else { return .chineseCalendar }
                return CalendarType(rawValue: first) ?? .chineseCalendar
            }
            return CalendarType(rawValue: raw) ?? .chineseCalendar
        }
        set {
            if let type = newValue {
                selectedCalendarData = Data(type.rawValue.utf8)
            } else {
                selectedCalendarData = Data()
            }
        }
    }

    var timezone: TimezoneOption {
        get {
            (try? JSONDecoder().decode(TimezoneOption.self, from: timezoneData))
                ?? .system
        }
        set {
            timezoneData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        timeFormat: TimeFormat = .h24,
        firstDayOfWeek: Weekday = .monday,
        locale: AppLocale = .system,
        appearanceMode: AppearanceMode = .system,
        selectedCalendar: CalendarType? = .chineseCalendar,
        timezone: TimezoneOption = .system
    ) {
        self.timeFormat = timeFormat
        self.firstDayOfWeek = firstDayOfWeek
        self.locale = locale
        self.appearanceMode = appearanceMode
        if let cal = selectedCalendar {
            self.selectedCalendarData = Data(cal.rawValue.utf8)
        } else {
            self.selectedCalendarData = Data()
        }
        self.timezoneData = (try? JSONEncoder().encode(timezone)) ?? Data()
    }
}

enum TimeFormat: String, Codable, CaseIterable, Sendable {
    case h12 = "12h"
    case h24 = "24h"
}

enum AppLocale: String, Codable, CaseIterable, Sendable {
    case system = "跟随系统"
    case zhHans = "简体中文"
    case en = "English"

    /// The `.lproj` folder identifier used to load localized bundles at runtime.
    var bundleIdentifier: String? {
        switch self {
        case .system: nil
        case .zhHans: "zh-Hans"
        case .en: "en"
        }
    }

    /// Display name shown in the language picker, always in the target language.
    var nativeName: String {
        switch self {
        case .system: "跟随系统"
        case .zhHans: "简体中文"
        case .en: "English"
        }
    }
}

enum CalendarType: String, Codable, CaseIterable, Hashable, Sendable {
    case chineseCalendar = "农历"

    var localizedName: String {
        LocaleManager.shared.localizedString(rawValue)
    }
}

enum TimezoneOption: Codable, Hashable, Sendable {
    case system
    case specific(identifier: String)

    var displayName: String {
        switch self {
        case .system:
            return LocaleManager.shared.localizedString("跟随系统")
        case .specific(let id):
            let appLocale = LocaleManager.shared.currentLocale.bundleIdentifier
                .map { Locale(identifier: $0) } ?? .current
            return TimeZone(identifier: id)?.localizedName(for: .standard, locale: appLocale) ?? id
        }
    }
}

enum AppearanceMode: String, Codable, CaseIterable, Sendable {
    case system = "自动"
    case light = "浅色"
    case dark = "深色"

    var localizedName: String {
        LocaleManager.shared.localizedString(rawValue)
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
