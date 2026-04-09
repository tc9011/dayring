import SwiftUI

struct CalendarGridView: View {
    let viewModel: CalendarViewModel
    let alarms: [Alarm]
    let onDateTapped: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            weekHeaderRow
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(viewModel.daysInMonth().enumerated()), id: \.offset) { _, entry in
                    cellView(for: entry)
                        .onTapGesture {
                            if entry.isCurrentMonth { onDateTapped(entry.date) }
                        }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private var weekHeaderRow: some View {
        HStack(spacing: 3) {
            ForEach(Weekday.allCases, id: \.self) { day in
                Text(day.shortName)
                    .font(Font.smallCaption())
                    .foregroundStyle(weekHeaderColor(for: day))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private func weekHeaderColor(for day: Weekday) -> Color {
        switch day {
        case .saturday:
            return Color.accent
        case .sunday:
            return Color.holidayRed
        default:
            return Color.fgSecondary
        }
    }

    private func cellView(for entry: (date: Date, isCurrentMonth: Bool)) -> CalendarDayCellView {
        let calendar = Calendar.current
        let date = entry.date
        let isToday = calendar.isDateInToday(date) && entry.isCurrentMonth
        let year = calendar.component(.year, from: date)
        let dateKey = date.dateKey
        let weekdayNum = calendar.component(.weekday, from: date)
        let weekday = Weekday(rawValue: weekdayNum == 1 ? 7 : weekdayNum - 1) ?? .monday

        let lunarText = viewModel.chineseCalendar.lunarDateString(for: date)
        let isHoliday = viewModel.holidayProvider.isHoliday(dateKey, year: year)
        let isMakeupDay = viewModel.holidayProvider.isMakeupDay(dateKey, year: year)
        let isFirstDayOfHoliday = viewModel.holidayProvider.isFirstDayOfHoliday(dateKey, year: year)
        let holidayDisplayText = viewModel.holidayProvider.holidayDisplayText(for: dateKey, year: year)
        let makeupDayDisplayText = viewModel.holidayProvider.makeupDayDisplayText(for: dateKey, year: year)
        let solarTerm = viewModel.chineseCalendar.solarTerm(for: date)
        let times = viewModel.alarmTimes(for: date, alarms: alarms)

        return CalendarDayCellView(
            date: date,
            isCurrentMonth: entry.isCurrentMonth,
            isToday: isToday,
            weekday: weekday,
            lunarText: lunarText,
            isHoliday: isHoliday,
            isMakeupDay: isMakeupDay,
            isFirstDayOfHoliday: isFirstDayOfHoliday,
            holidayDisplayText: holidayDisplayText,
            makeupDayDisplayText: makeupDayDisplayText,
            solarTerm: solarTerm,
            alarmTimes: times
        )
    }
}
