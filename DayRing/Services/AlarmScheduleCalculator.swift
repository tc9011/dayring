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

        if alarm.deleteAfterRing {
            return nextRingDatesLimited(for: alarm, from: startDate, maxCount: 1, holidays: holidays, makeupDays: makeupDays)
        }

        return nextRingDatesLimited(for: alarm, from: startDate, maxCount: count, holidays: holidays, makeupDays: makeupDays)
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
        let calendar = Calendar.current
        var results: [Date] = []
        var current = startDate
        let maxDaysToSearch = 365

        for _ in 0..<maxDaysToSearch {
            if alarm.shouldRing(on: current, holidays: holidays, makeupDays: makeupDays) {
                results.append(current)
                if results.count >= maxCount { break }
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return results
    }
}
