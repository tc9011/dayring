import SwiftUI

struct CalendarDayCellView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let weekday: Weekday
    let calendarText: String
    let selectedCalendar: CalendarType?
    let isHoliday: Bool
    let isMakeupDay: Bool
    let isFirstDayOfHoliday: Bool
    let holidayDisplayText: String?
    let makeupDayDisplayText: String?
    let solarTerm: String?
    let alarmTimes: [String]
    @Environment(\.localeManager) private var locale

    var body: some View {
        VStack(spacing: 2) {
            dateNumberView
            subtitleView
            alarmTimesView
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
            if isFirstDayOfHoliday && isCurrentMonth {
                Circle()
                    .fill(Color.holidayRed)
                    .frame(width: 6, height: 6)
                    .offset(x: -4, y: 4)
            }
        }
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }

    @ViewBuilder
    private var dateNumberView: some View {
        let day = Calendar.current.component(.day, from: date)
        Text("\(day)")
            .font(.system(size: 17, weight: dateNumberWeight))
            .foregroundStyle(dateNumberColor)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if isToday {
            Text(locale.localizedString("今天"))
                .font(Font.tinyCaption())
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
                .lineLimit(1)
        } else if let holidayText = holidayDisplayText, isCurrentMonth {
            Text(holidayText)
                .font(Font.tinyCaption())
                .fontWeight(isFirstDayOfHoliday ? .medium : .semibold)
                .foregroundStyle(Color.holidayRed)
                .lineLimit(1)
        } else if let makeupText = makeupDayDisplayText, isCurrentMonth {
            Text(makeupText)
                .font(Font.tinyCaption())
                .fontWeight(.semibold)
                .foregroundStyle(Color.makeupPurple)
                .lineLimit(1)
        } else if selectedCalendar == .chineseCalendar, let term = solarTerm, isCurrentMonth {
            Text(term)
                .font(Font.tinyCaption())
                .fontWeight(.medium)
                .foregroundStyle(Color.accent)
                .lineLimit(1)
        } else {
            Text(calendarText)
                .font(Font.tinyCaption())
                .foregroundStyle(Color.fgSecondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var alarmTimesView: some View {
        if !alarmTimes.isEmpty && isCurrentMonth {
            VStack(spacing: 0) {
                ForEach(alarmTimes.prefix(2), id: \.self) { time in
                    Text(time)
                        .font(Font.timeAlarmIndicator())
                        .foregroundStyle(Color.accent)
                        .lineLimit(1)
                }
                if alarmTimes.count > 2 {
                    Text("+\(alarmTimes.count - 2)")
                        .font(Font.timeAlarmIndicator())
                        .foregroundStyle(Color.accent)
                }
            }
        }
    }

    private var cellBackground: Color {
        guard isCurrentMonth else { return Color.clear }
        if isToday {
            return Color.todayBg
        } else if isHoliday {
            return Color.holidayRedBg
        } else if isMakeupDay {
            return Color.makeupPurpleBg
        }
        return Color.clear
    }

    private var dateNumberColor: Color {
        guard isCurrentMonth else { return Color.fgSecondary }
        if isToday {
            return Color.accent
        } else if isHoliday {
            return Color.holidayRed
        } else if isMakeupDay {
            return Color.makeupPurple
        } else if weekday == .sunday {
            return Color.holidayRed
        } else if weekday == .saturday {
            return Color.accent
        }
        return Color.fgPrimary
    }

    private var dateNumberWeight: Font.Weight {
        if isToday { return .bold }
        if isHoliday || isMakeupDay { return .semibold }
        return .regular
    }
}
