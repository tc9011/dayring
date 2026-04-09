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
                ForEach(Array(viewModel.daysInMonth().enumerated()), id: \.offset) { _, date in
                    cellView(for: date)
                        .onTapGesture {
                            if let date { onDateTapped(date) }
                        }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private var weekHeaderRow: some View {
        HStack(spacing: 3) {
            ForEach(Weekday.allCases, id: \.self) { day in
                Text(day.shortName)
                    .font(Font.smallCaption())
                    .foregroundStyle(weekdayColor(for: day))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func weekdayColor(for day: Weekday) -> Color {
        switch day {
        case .saturday, .sunday:
            return Color.fgTertiary
        default:
            return Color.fgSecondary
        }
    }

    private func cellView(for date: Date?) -> CalendarDayCellView {
        let calendar = Calendar.current
        let today = Date()
        let isToday = date.map { calendar.isDateInToday($0) } ?? false
        let year = date.map { calendar.component(.year, from: $0) } ?? calendar.component(.year, from: today)
        let dateKey = date?.dateKey ?? ""

        let lunarText = date.map { viewModel.chineseCalendar.lunarDateString(for: $0) } ?? ""
        let holidayName = viewModel.holidayProvider.holidayName(for: dateKey, year: year)
        let isHoliday = viewModel.holidayProvider.isHoliday(dateKey, year: year)
        let isMakeupDay = viewModel.holidayProvider.isMakeupDay(dateKey, year: year)
        let times = date.map { viewModel.alarmTimes(for: $0, alarms: alarms) } ?? []

        return CalendarDayCellView(
            date: date,
            isToday: isToday,
            lunarText: lunarText,
            holidayName: holidayName,
            isHoliday: isHoliday,
            isMakeupDay: isMakeupDay,
            alarmTimes: times
        )
    }
}
