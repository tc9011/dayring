import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var hour: Int             // 0-23
    var minute: Int           // 0-59
    var label: String
    var repeatModeData: Data
    var ringtone: String
    var snoozeDuration: Int   // minutes (0 = disabled)
    var advanceMinutes: Int   // 0, 5, 10, 15, 30
    var deleteAfterRing: Bool
    var isEnabled: Bool

    var skipHolidays: Bool
    var ringOnMakeupDays: Bool
    var manualOverrides: [String: Bool]
    var skipNextDate: Date?

    var createdAt: Date
    var updatedAt: Date

    @Transient
    var repeatMode: RepeatMode {
        get {
            (try? JSONDecoder().decode(RepeatMode.self, from: repeatModeData))
                ?? .weekly(days: Weekday.workdays)
        }
        set {
            repeatModeData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        hour: Int = 7,
        minute: Int = 0,
        label: String = "",
        repeatMode: RepeatMode = .weekly(days: Weekday.workdays),
        ringtone: String = "radar",
        snoozeDuration: Int = 5,
        advanceMinutes: Int = 0,
        deleteAfterRing: Bool = false,
        isEnabled: Bool = true,
        skipHolidays: Bool = true,
        ringOnMakeupDays: Bool = true,
        manualOverrides: [String: Bool] = [:],
        skipNextDate: Date? = nil
    ) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.label = label
        self.repeatModeData = (try? JSONEncoder().encode(repeatMode)) ?? Data()
        self.ringtone = ringtone
        self.snoozeDuration = snoozeDuration
        self.advanceMinutes = advanceMinutes
        self.deleteAfterRing = deleteAfterRing
        self.isEnabled = isEnabled
        self.skipHolidays = skipHolidays
        self.ringOnMakeupDays = ringOnMakeupDays
        self.manualOverrides = manualOverrides
        self.skipNextDate = skipNextDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var amPmString: String {
        let key = hour < 12 ? "AM" : "PM"
        return LocaleManager.shared.localizedString(key)
    }

    var hour12: Int {
        let h = hour % 12
        return h == 0 ? 12 : h
    }

    var repeatModeDisplayName: String {
        repeatMode.displayName
    }

    var repeatDetailText: String {
        let l = LocaleManager.shared
        switch repeatMode {
        case .daily:
            return l.localizedString("每天")
        case .weekly(let days):
            if days == Weekday.workdays { return l.localizedString("工作日") }
            if days == Weekday.allDays { return l.localizedString("每天") }
            return days.sorted().map(\.shortName).joined(separator: "、")
        case .biweekly:
            return l.localizedString("大小周")
        case .rotating(_, let ring, let gap):
            let ringPart = l.localizedString("响") + "\(ring)" + l.localizedString("天")
            let gapPart = l.localizedString("休") + "\(gap)" + l.localizedString("天")
            return ringPart + gapPart
        case .custom(let dates):
            return "\(dates.count)" + l.localizedString("天")
        }
    }

    /// Priority: manual override > skip-next > makeup day > holiday skip > repeat pattern.
    func shouldRing(on date: Date, holidays: Set<String>, makeupDays: Set<String>) -> Bool {
        let dateKey = Self.dateKey(for: date)

        if let override = manualOverrides[dateKey] {
            return override
        }

        if let skipDate = skipNextDate, Calendar.current.isDate(date, inSameDayAs: skipDate) {
            return false
        }

        if makeupDays.contains(dateKey) && ringOnMakeupDays {
            return true
        }

        if holidays.contains(dateKey) && skipHolidays {
            return false
        }

        return matchesRepeatPattern(date)
    }

    private func matchesRepeatPattern(_ date: Date) -> Bool {
        let calendar = Calendar.current

        switch repeatMode {
        case .daily:
            return true

        case .weekly(let days):
            let weekday = calendar.component(.weekday, from: date)
            // Convert: Sunday=1...Saturday=7 → Monday=1...Sunday=7
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            return days.contains(wd)

        case .biweekly(let week1, let week2):
            let weekday = calendar.component(.weekday, from: date)
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            let weekNumber = calendar.component(.weekOfYear, from: date)
            return weekNumber % 2 == 0 ? week1.contains(wd) : week2.contains(wd)

        case .rotating(let startDate, let ringDays, let gapDays):
            let cycle = ringDays + gapDays
            guard cycle > 0 else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
            guard daysSinceStart >= 0 else { return false }
            let positionInCycle = daysSinceStart % cycle
            return positionInCycle < ringDays

        case .custom(let dateComponents):
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return dateComponents.contains(components)
        }
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
