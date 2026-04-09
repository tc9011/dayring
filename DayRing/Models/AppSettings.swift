import Foundation
import SwiftData

@Model
final class AppSettings {
    var timeFormat: TimeFormat
    var firstDayOfWeek: Weekday
    var locale: AppLocale
    var selectedCalendarsData: Data
    var timezoneData: Data

    @Transient
    var selectedCalendars: Set<CalendarType> {
        get {
            (try? JSONDecoder().decode(Set<CalendarType>.self, from: selectedCalendarsData))
                ?? [.lunar]
        }
        set {
            selectedCalendarsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    @Transient
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
        selectedCalendars: Set<CalendarType> = [.lunar],
        timezone: TimezoneOption = .system
    ) {
        self.timeFormat = timeFormat
        self.firstDayOfWeek = firstDayOfWeek
        self.locale = locale
        self.selectedCalendarsData = (try? JSONEncoder().encode(selectedCalendars)) ?? Data()
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
    case zhHant = "繁體中文"
    case en = "English"
    case ja = "日本語"
}

enum CalendarType: String, Codable, CaseIterable, Hashable, Sendable {
    case lunar = "农历"
    case islamic = "伊斯兰历"
    case hebrew = "希伯来历"
    case persian = "波斯历"
    case indian = "印度历"
}

enum TimezoneOption: Codable, Hashable, Sendable {
    case system
    case specific(identifier: String)

    var displayName: String {
        switch self {
        case .system: "跟随系统"
        case .specific(let id):
            TimeZone(identifier: id)?.localizedName(for: .standard, locale: .current) ?? id
        }
    }
}
