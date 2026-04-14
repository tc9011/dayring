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
    var scheduledDate: Date?

    var createdAt: Date
    var updatedAt: Date

    @Transient
    var repeatMode: RepeatMode {
        get {
            (try? JSONDecoder().decode(RepeatMode.self, from: repeatModeData))
                ?? .none
        }
        set {
            repeatModeData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        hour: Int = 7,
        minute: Int = 0,
        label: String = "",
        repeatMode: RepeatMode = .none,
        ringtone: String = "radar",
        snoozeDuration: Int = 5,
        advanceMinutes: Int = 0,
        deleteAfterRing: Bool = false,
        isEnabled: Bool = true,
        skipHolidays: Bool = true,
        ringOnMakeupDays: Bool = true,
        manualOverrides: [String: Bool] = [:],
        skipNextDate: Date? = nil,
        scheduledDate: Date? = nil
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
        self.scheduledDate = scheduledDate
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
        case .none:
            return l.localizedString("不重复")
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

    // MARK: - Scheduled Date

    /// Computes and sets `scheduledDate` for non-repeating alarms.
    /// If alarm time is in the future today, schedules for today.
    /// If alarm time has passed or is equal to now, schedules for tomorrow.
    /// For repeating alarms, clears `scheduledDate`.
    func computeScheduledDate(now: Date = Date()) {
        guard repeatMode.isNone else {
            scheduledDate = nil
            return
        }
        let calendar = Calendar.current
        let todayAlarmMinutes = hour * 60 + minute
        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        if todayAlarmMinutes > nowMinutes {
            scheduledDate = calendar.startOfDay(for: now)
        } else {
            scheduledDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
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
        case .none:
            guard let scheduled = scheduledDate else { return false }
            return calendar.isDate(date, inSameDayAs: scheduled)

        case .daily:
            return true

        case .weekly(let days):
            let weekday = calendar.component(.weekday, from: date)
            // Convert: Sunday=1...Saturday=7 → Monday=1...Sunday=7
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            return days.contains(wd)

        case .biweekly(let referenceDate, let week1, let week2):
            let weekday = calendar.component(.weekday, from: date)
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            let daysSinceRef = calendar.dateComponents([.day], from: referenceDate, to: date).day ?? 0
            let weekIndex: Int
            if daysSinceRef >= 0 {
                weekIndex = daysSinceRef / 7
            } else {
                weekIndex = (daysSinceRef - 6) / 7
            }
            return weekIndex % 2 == 0 ? week1.contains(wd) : week2.contains(wd)

        case .rotating(let startDate, let ringDays, let gapDays):
            let cycle = ringDays + gapDays
            guard cycle > 0 else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
            guard daysSinceStart >= 0 else { return false }
            let positionInCycle = daysSinceStart % cycle
            return positionInCycle < ringDays

        case .custom(let dateComponents):
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return dateComponents.contains { dc in
                dc.year == components.year && dc.month == components.month && dc.day == components.day
            }
        }
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
