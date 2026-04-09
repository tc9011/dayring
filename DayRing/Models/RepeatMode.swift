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
        case .daily: LocaleManager.shared.localizedString("每天")
        case .weekly: LocaleManager.shared.localizedString("每周")
        case .biweekly: LocaleManager.shared.localizedString("大小周")
        case .rotating: LocaleManager.shared.localizedString("轮休")
        case .custom: LocaleManager.shared.localizedString("自定义")
        }
    }
}


