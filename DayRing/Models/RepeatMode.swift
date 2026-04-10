import Foundation

// MARK: - Repeat Mode

enum RepeatMode: Codable, Hashable, Sendable {
    case none
    case daily
    case weekly(days: Set<Weekday>)
    case biweekly(week1: Set<Weekday>, week2: Set<Weekday>)
    case rotating(startDate: Date, ringDays: Int, gapDays: Int)
    case custom(dates: Set<DateComponents>)

    var displayName: String {
        let l = LocaleManager.shared
        switch self {
        case .none: return l.localizedString("不重复")
        case .daily: return l.localizedString("每天")
        case .weekly: return l.localizedString("每周")
        case .biweekly: return l.localizedString("大小周")
        case .rotating: return l.localizedString("轮休")
        case .custom: return l.localizedString("自定义")
        }
    }

    var isNone: Bool {
        if case .none = self { return true }
        return false
    }
}


