import SwiftUI

struct CalendarDayCellView: View {
    let date: Date?
    let isToday: Bool
    let lunarText: String
    let holidayName: String?
    let isHoliday: Bool
    let isMakeupDay: Bool
    let alarmTimes: [String]

    var body: some View {
        VStack(spacing: 2) {
            dateNumberView
            lunarDateView
            alarmTimesView
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var dateNumberView: some View {
        if let date {
            let day = Calendar.current.component(.day, from: date)
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 28, height: 28)
                }
                Text("\(day)")
                    .font(.system(size: 15, weight: isToday ? .bold : .regular))
                    .foregroundStyle(dateNumberColor)
            }
        } else {
            Text("")
                .font(.system(size: 15))
                .frame(height: 28)
        }
    }

    @ViewBuilder
    private var lunarDateView: some View {
        if date != nil {
            if let holidayName {
                Text(holidayName)
                    .font(Font.tinyCaption())
                    .foregroundStyle(badgeColor)
                    .lineLimit(1)
            } else {
                Text(lunarText)
                    .font(Font.tinyCaption())
                    .foregroundStyle(Color.fgSecondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var alarmTimesView: some View {
        if !alarmTimes.isEmpty {
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
        if isHoliday {
            return Color.holidayRedBg
        } else if isMakeupDay {
            return Color.makeupPurpleBg
        } else if isToday {
            return Color.todayBg
        }
        return Color.clear
    }

    private var dateNumberColor: Color {
        if isToday {
            return .white
        } else if isHoliday {
            return Color.holidayRed
        } else if isMakeupDay {
            return Color.makeupPurple
        }
        return Color.fgPrimary
    }

    private var badgeColor: Color {
        if isHoliday {
            return Color.holidayRed
        } else if isMakeupDay {
            return Color.makeupPurple
        }
        return Color.fgSecondary
    }
}
