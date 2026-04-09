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
        case .monday: "一"
        case .tuesday: "二"
        case .wednesday: "三"
        case .thursday: "四"
        case .friday: "五"
        case .saturday: "六"
        case .sunday: "日"
        }
    }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static let workdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let allDays: Set<Weekday> = Set(Weekday.allCases)
}
