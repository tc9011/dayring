import Foundation
import Testing
@testable import DayRing

@Suite("CalendarGridHelper Tests")
struct CalendarGridHelperTests {

    // MARK: - leadingEmptyCells

    @Test("April 2026 starts on Wednesday → 2 leading empty cells")
    func leadingEmptyCellsApril2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(empty == 2)
    }

    @Test("June 2026 starts on Monday → 0 leading empty cells")
    func leadingEmptyCellsJune2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(empty == 0)
    }

    @Test("March 2026 starts on Sunday → 6 leading empty cells")
    func leadingEmptyCellsMarch2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(empty == 6)
    }

    @Test("February 2026 starts on Sunday → 6 leading empty cells")
    func leadingEmptyCellsFeb2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(empty == 6)
    }

    @Test("January 2026 starts on Thursday → 3 leading empty cells")
    func leadingEmptyCellsJan2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(empty == 3)
    }

    // MARK: - gridCells

    @Test("April 2026 grid has 2 empty + 30 day cells = 32 total")
    func gridCellsApril2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let emptyCells = cells.filter { $0.dateComponents == nil }
        let dayCells = cells.filter { $0.dateComponents != nil }
        #expect(emptyCells.count == 2)
        #expect(dayCells.count == 30)
        #expect(cells.count == 32)
    }

    @Test("June 2026 grid has 0 empty + 30 day cells = 30 total")
    func gridCellsJune2026() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let emptyCells = cells.filter { $0.dateComponents == nil }
        let dayCells = cells.filter { $0.dateComponents != nil }
        #expect(emptyCells.count == 0)
        #expect(dayCells.count == 30)
    }

    @Test("First day cell has day component == 1")
    func gridCellsFirstDayIsOne() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let firstDay = cells.first(where: { $0.dateComponents != nil })
        #expect(firstDay?.dateComponents?.day == 1)
    }

    @Test("Last day cell has correct day component for month length")
    func gridCellsLastDay() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let lastDay = cells.last(where: { $0.dateComponents != nil })
        #expect(lastDay?.dateComponents?.day == 30)
    }

    @Test("Empty cells come before day cells")
    func gridCellsEmptyFirst() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let firstDayIndex = cells.firstIndex(where: { $0.dateComponents != nil })!
        let lastEmptyIndex = cells.lastIndex(where: { $0.dateComponents == nil })!
        #expect(lastEmptyIndex < firstDayIndex)
    }

    // MARK: - gridRows

    @Test("Every grid row has exactly 7 cells")
    func gridRowsAllHave7() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let rows = CalendarGridHelper.gridRows(from: cells)
        for row in rows {
            #expect(row.count == 7)
        }
    }

    @Test("April 2026: 32 cells → 5 rows of 7 (with 3 padding)")
    func gridRowsApril2026Count() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let rows = CalendarGridHelper.gridRows(from: cells)
        #expect(rows.count == 5)
    }

    @Test("June 2026: 30 cells → 5 rows of 7 (with 5 padding)")
    func gridRowsJune2026Count() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let rows = CalendarGridHelper.gridRows(from: cells)
        #expect(rows.count == 5)
    }

    @Test("February 2026: 6 empty + 28 days = 34 → 5 rows")
    func gridRowsFeb2026Count() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let cells = CalendarGridHelper.gridCells(for: date)
        let rows = CalendarGridHelper.gridRows(from: cells)
        #expect(rows.count == 5)
        #expect(cells.count == 34)
    }

    @Test("Empty cells array produces empty rows")
    func gridRowsEmpty() {
        let rows = CalendarGridHelper.gridRows(from: [])
        #expect(rows.isEmpty)
    }

    // MARK: - weekdaySymbols

    @Test("Weekday symbols returns 7 items")
    func weekdaySymbolsCount() {
        let symbols = CalendarGridHelper.weekdaySymbols()
        #expect(symbols.count == 7)
    }

    @Test("Weekday symbols start with Monday in English locale")
    func weekdaySymbolsStartsMonday() {
        let symbols = CalendarGridHelper.weekdaySymbols(locale: Locale(identifier: "en_US"))
        #expect(symbols.first == "M")
        #expect(symbols.last == "S")
    }

    @Test("Weekday symbols start with 一 in Chinese locale")
    func weekdaySymbolsStartsMondayChinese() {
        let symbols = CalendarGridHelper.weekdaySymbols(locale: Locale(identifier: "zh-Hans"))
        #expect(symbols.first == "一")
        #expect(symbols.last == "日")
    }

    // MARK: - rotatingPreviewCount

    @Test("Rotating preview: 4 ring + 2 gap = 7 cells (one full cycle + 1)")
    func rotatingPreviewDefault() {
        let count = CalendarGridHelper.rotatingPreviewCount(ringDays: 4, gapDays: 2)
        #expect(count == 7)
    }

    @Test("Rotating preview: 25 ring + 13 gap = 39 cells")
    func rotatingPreviewLarge() {
        let count = CalendarGridHelper.rotatingPreviewCount(ringDays: 25, gapDays: 13)
        #expect(count == 39)
    }

    @Test("Rotating preview: 1 ring + 1 gap = 3 cells")
    func rotatingPreviewMinimum() {
        let count = CalendarGridHelper.rotatingPreviewCount(ringDays: 1, gapDays: 1)
        #expect(count == 3)
    }

    @Test("Rotating preview: 30 ring + 30 gap = 61 cells")
    func rotatingPreviewMaximum() {
        let count = CalendarGridHelper.rotatingPreviewCount(ringDays: 30, gapDays: 30)
        #expect(count == 61)
    }

    // MARK: - firstDayOfWeek support

    @Test("Leading empty cells with Sunday as first day: April 2026 starts Wed → 3 empty")
    func leadingEmptyCellsSundayFirst() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date, firstDayOfWeek: .sunday)
        #expect(empty == 3)
    }

    @Test("Leading empty cells with Saturday as first day: April 2026 starts Wed → 4 empty")
    func leadingEmptyCellsSaturdayFirst() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let empty = CalendarGridHelper.leadingEmptyCells(for: date, firstDayOfWeek: .saturday)
        #expect(empty == 4)
    }

    @Test("Leading empty cells with Monday as first day matches default: April 2026 → 2 empty")
    func leadingEmptyCellsMondayFirstMatchesDefault() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let withParam = CalendarGridHelper.leadingEmptyCells(for: date, firstDayOfWeek: .monday)
        let withDefault = CalendarGridHelper.leadingEmptyCells(for: date)
        #expect(withParam == withDefault)
    }

    @Test("June 2026 starts Mon: Sunday-first → 1 empty, Monday-first → 0 empty")
    func leadingEmptyCellsJuneSundayVsMonday() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let sundayFirst = CalendarGridHelper.leadingEmptyCells(for: date, firstDayOfWeek: .sunday)
        let mondayFirst = CalendarGridHelper.leadingEmptyCells(for: date, firstDayOfWeek: .monday)
        #expect(sundayFirst == 1)
        #expect(mondayFirst == 0)
    }

    @Test("Weekday symbols with Sunday first start with S in English")
    func weekdaySymbolsSundayFirst() {
        let symbols = CalendarGridHelper.weekdaySymbols(locale: Locale(identifier: "en_US"), firstDayOfWeek: .sunday)
        #expect(symbols.first == "S")
        #expect(symbols[1] == "M")
        #expect(symbols.last == "S")
    }

    @Test("Weekday symbols with Monday first matches default")
    func weekdaySymbolsMondayFirstDefault() {
        let withParam = CalendarGridHelper.weekdaySymbols(locale: Locale(identifier: "en_US"), firstDayOfWeek: .monday)
        let withDefault = CalendarGridHelper.weekdaySymbols(locale: Locale(identifier: "en_US"))
        #expect(withParam == withDefault)
    }

    @Test("Grid cells with Sunday first: April 2026 → 3 empty + 30 days")
    func gridCellsSundayFirst() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let cells = CalendarGridHelper.gridCells(for: date, firstDayOfWeek: .sunday)
        let emptyCells = cells.filter { $0.dateComponents == nil }
        let dayCells = cells.filter { $0.dateComponents != nil }
        #expect(emptyCells.count == 3)
        #expect(dayCells.count == 30)
    }
}
