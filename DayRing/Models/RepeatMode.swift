import Foundation

// MARK: - Repeat Mode

enum RepeatMode: Codable, Hashable, Sendable {
    case daily
    case weekly(days: Set<Weekday>)
    case biweekly(week1: Set<Weekday>, week2: Set<Weekday>)
    case rotating(startDate: Date, ringDays: Int, gapDays: Int)
    case custom(dates: Set<DateComponents>)

    var displayName: String {
        switch self {
        case .daily: "每天"
        case .weekly: "每周"
        case .biweekly: "大小周"
        case .rotating: "轮休"
        case .custom: "自定义"
        }
    }
}


