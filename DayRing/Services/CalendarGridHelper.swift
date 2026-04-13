import Foundation

struct CalendarGridCell: Identifiable, Hashable {
    let id: String
    let dateComponents: DateComponents?
}

enum CalendarGridHelper {

    static func gridCells(for month: Date, firstDayOfWeek: Weekday = .monday) -> [CalendarGridCell] {
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: monthComponents) else { return [] }

        let emptyCells = leadingEmptyCells(for: firstDay, firstDayOfWeek: firstDayOfWeek)

        var cells: [CalendarGridCell] = (0..<emptyCells).map {
            CalendarGridCell(id: "empty-\($0)", dateComponents: nil)
        }

        let range = calendar.range(of: .day, in: .month, for: month)!
        for day in range {
            let dc = DateComponents(year: monthComponents.year, month: monthComponents.month, day: day)
            cells.append(CalendarGridCell(id: "day-\(day)", dateComponents: dc))
        }
        return cells
    }

    static func gridRows(from cells: [CalendarGridCell]) -> [[CalendarGridCell]] {
        stride(from: 0, to: cells.count, by: 7).map { start in
            let end = min(start + 7, cells.count)
            var row = Array(cells[start..<end])
            while row.count < 7 {
                row.append(CalendarGridCell(id: "pad-\(start)-\(row.count)", dateComponents: nil))
            }
            return row
        }
    }

    static func leadingEmptyCells(for firstDayOfMonth: Date, firstDayOfWeek: Weekday = .monday) -> Int {
        let calendar = Calendar.current
        // Foundation weekday: 1=Sun, 2=Mon, ..., 7=Sat
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert to our Weekday rawValue: Mon=1..Sun=7
        let adjusted = weekday == 1 ? 7 : weekday - 1
        let firstDayRaw = firstDayOfWeek.rawValue
        return (adjusted - firstDayRaw + 7) % 7
    }

    static func weekdaySymbols(locale: Locale? = nil, firstDayOfWeek: Weekday = .monday) -> [String] {
        var calendar = Calendar.current
        if let locale { calendar.locale = locale }
        let symbols = calendar.veryShortWeekdaySymbols
        // symbols[0]=Sun, [1]=Mon, ..., [6]=Sat
        // Map Weekday rawValue (Mon=1..Sun=7) to Foundation index (Sun=0..Sat=6)
        let foundationIndex = firstDayOfWeek.rawValue == 7 ? 0 : firstDayOfWeek.rawValue
        var result: [String] = []
        for i in 0..<7 {
            result.append(symbols[(foundationIndex + i) % 7])
        }
        return result
    }

    static func rotatingPreviewCount(ringDays: Int, gapDays: Int) -> Int {
        ringDays + gapDays + 1
    }
}
