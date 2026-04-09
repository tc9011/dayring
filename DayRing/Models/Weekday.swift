import Foundation

// MARK: - Weekday (Monday = 1 ... Sunday = 7)

enum Weekday: Int, Codable, CaseIterable, Hashable, Comparable, Sendable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    var shortName: String {
        switch self {
        case .monday: LocaleManager.shared.localizedString("一")
        case .tuesday: LocaleManager.shared.localizedString("二")
        case .wednesday: LocaleManager.shared.localizedString("三")
        case .thursday: LocaleManager.shared.localizedString("四")
        case .friday: LocaleManager.shared.localizedString("五")
        case .saturday: LocaleManager.shared.localizedString("六")
        case .sunday: LocaleManager.shared.localizedString("日")
        }
    }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static let workdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let allDays: Set<Weekday> = Set(Weekday.allCases)
}
