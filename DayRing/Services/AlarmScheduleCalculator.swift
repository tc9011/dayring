import Foundation

struct AlarmScheduleCalculator: Sendable {

    func nextRingDates(
        for alarm: Alarm,
        from startDate: Date,
        count: Int,
        holidays: Set<String>,
        makeupDays: Set<String>
    ) -> [Date] {
        guard alarm.isEnabled else { return [] }

        let maxCount = alarm.deleteAfterRing ? 1 : count
        return nextRingDatesLimited(for: alarm, from: startDate, maxCount: maxCount, holidays: holidays, makeupDays: makeupDays)
    }

    func effectiveTime(for alarm: Alarm) -> (hour: Int, minute: Int) {
        guard alarm.advanceMinutes > 0 else {
            return (alarm.hour, alarm.minute)
        }

        var totalMinutes = alarm.hour * 60 + alarm.minute - alarm.advanceMinutes
        if totalMinutes < 0 {
            totalMinutes += 24 * 60
        }
        return (totalMinutes / 60, totalMinutes % 60)
    }

    private func nextRingDatesLimited(
        for alarm: Alarm,
        from startDate: Date,
        maxCount: Int,
        holidays: Set<String>,
        makeupDays: Set<String>
    ) -> [Date] {
        guard maxCount > 0 else { return [] }
        let calendar = Calendar.current
        var results: [Date] = []
        var current = startDate
        let maxDaysToSearch = 365

        let (effectiveHour, effectiveMinute) = effectiveTime(for: alarm)
        let startHour = calendar.component(.hour, from: startDate)
        let startMinute = calendar.component(.minute, from: startDate)
        let startTimeMinutes = startHour * 60 + startMinute
        let effectiveTimeMinutes = effectiveHour * 60 + effectiveMinute

        for dayOffset in 0..<maxDaysToSearch {
            if alarm.shouldRing(on: current, holidays: holidays, makeupDays: makeupDays) {
                if dayOffset == 0 && startTimeMinutes >= effectiveTimeMinutes {
                    current = calendar.date(byAdding: .day, value: 1, to: current)!
                    continue
                }
                results.append(current)
                if results.count >= maxCount { break }
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return results
    }
}
