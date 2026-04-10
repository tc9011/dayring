import Foundation

struct CalendarGridCell: Identifiable, Hashable {
    let id: String
    let dateComponents: DateComponents?
}

enum CalendarGridHelper {

    static func gridCells(for month: Date) -> [CalendarGridCell] {
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: monthComponents) else { return [] }

        let emptyCells = leadingEmptyCells(for: firstDay)

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

    static func leadingEmptyCells(for firstDayOfMonth: Date) -> Int {
        let calendar = Calendar.current
        // weekday: 1=Sun..7=Sat → Mon=0
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 5) % 7
    }

    static func weekdaySymbols(locale: Locale? = nil) -> [String] {
        var calendar = Calendar.current
        if let locale { calendar.locale = locale }
        let symbols = calendar.veryShortWeekdaySymbols
        return Array(symbols[1...]) + [symbols[0]]
    }

    static func rotatingPreviewCount(ringDays: Int, gapDays: Int) -> Int {
        ringDays + gapDays + 1
    }
}
