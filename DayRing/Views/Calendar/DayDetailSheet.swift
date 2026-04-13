import SwiftUI
import SwiftData

struct DayDetailSheet: View {
    let date: Date
    let alarms: [Alarm]
    let is24HourFormat: Bool
    var selectedCalendar: CalendarType? = .chineseCalendar
    @Environment(\.localeManager) private var locale

    private let calendarService = ChineseCalendarService()
    private let holidayProvider = HolidayDataProvider()

    private var dateKey: String { Alarm.dateKey(for: date) }
    private var calendar: Calendar { Calendar.current }
    private var year: Int { calendar.component(.year, from: date) }
    private var dayNumber: Int { calendar.component(.day, from: date) }

    private var isHoliday: Bool { holidayProvider.isHoliday(dateKey, year: year) }
    private var isMakeupDay: Bool { holidayProvider.isMakeupDay(dateKey, year: year) }
    private var holidayName: String? { holidayProvider.holidayName(for: dateKey, year: year) }
    private var calendarString: String {
        guard selectedCalendar != nil else { return "" }
        return calendarService.chineseDateString(for: date)
    }

    private var isToday: Bool { calendar.isDateInToday(date) }

    private var monthString: String {
        let m = calendar.component(.month, from: date)
        return "\(m)" + locale.localizedString("月")
    }

    private var yearString: String {
        "\(year)"
    }

    private var weekdayString: String {
        let weekday = calendar.component(.weekday, from: date)
        let keys = ["", "周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return locale.localizedString(keys[weekday])
    }

    private var dayNumberColor: Color {
        if isHoliday { return Color.holidayRed }
        if isToday { return Color.accent }
        return Color.fgPrimary
    }

    private var calendarDisplayString: String {
        if let name = holidayName {
            if calendarString.isEmpty {
                return name
            }
            return "\(calendarString) · \(name)"
        }
        return calendarString
    }

    private var calendarDisplayColor: Color {
        if isHoliday { return Color.holidayRed }
        return Color.fgSecondary
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                dateHeaderSection
                calendarInfoSection
                separatorLine
                alarmSection
                hintSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background { Color.bgPrimary.ignoresSafeArea() }
        .presentationDetents([.medium, .large])
    }

    private var dateHeaderSection: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(dayNumberColor)
                Text(monthString)
                    .font(Font.caption())
                    .foregroundStyle(Color.fgSecondary)
            }

            Text("\(yearString) · \(weekdayString)")
                .font(Font.caption())
                .foregroundStyle(Color.fgSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var calendarInfoSection: some View {
        VStack(spacing: 8) {
            if !calendarDisplayString.isEmpty {
                Text(calendarDisplayString)
                    .font(Font.caption())
                    .foregroundStyle(calendarDisplayColor)
            }

            if isHoliday {
                badgeView(
                    text: locale.localizedString("法定节假日 · 闹钟默认不响铃"),
                    dotColor: Color.holidayRed,
                    textColor: Color.holidayRed,
                    bgColor: Color.holidayRedBg
                )
            } else if isMakeupDay {
                badgeView(
                    text: locale.localizedString("补班日 · 闹钟默认响铃"),
                    dotColor: Color.makeupPurple,
                    textColor: Color.makeupPurple,
                    bgColor: Color.makeupPurpleBg
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func badgeView(
        text: String,
        dotColor: Color,
        textColor: Color,
        bgColor: Color
    ) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(text)
                .font(Font.smallCaption())
                .foregroundStyle(textColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(bgColor, in: Capsule())
    }

    private var alarmSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(locale.localizedString("当天闹钟响铃状态"))
                .font(Font.caption())
                .foregroundStyle(Color.fgSecondary)

            if alarms.isEmpty {
                Text(locale.localizedString("暂无闹钟"))
                    .font(Font.bodyText())
                    .foregroundStyle(Color.fgTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(alarms, id: \.id) { alarm in
                    alarmCard(alarm)
                }
            }
        }
    }

    private func alarmCard(_ alarm: Alarm) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                timeDisplay(for: alarm)
                if !alarm.label.isEmpty {
                    Text(alarm.label)
                        .font(Font.caption())
                        .foregroundStyle(Color.fgSecondary)
                }
                statusView(for: alarm)
            }

            Spacer()

            Toggle(isOn: overrideBinding(for: alarm)) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.iosGreen)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    private func timeDisplay(for alarm: Alarm) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if is24HourFormat {
                Text(alarm.timeString)
                    .font(Font.timeCard())
                    .foregroundStyle(Color.fgPrimary)
            } else {
                Text(String(format: "%d:%02d", alarm.hour12, alarm.minute))
                    .font(Font.timeCard())
                    .foregroundStyle(Color.fgPrimary)
                Text(alarm.amPmString)
                    .font(Font.caption())
                    .foregroundStyle(Color.fgSecondary)
            }
        }
    }

    private func statusView(for alarm: Alarm) -> some View {
        let info = statusInfo(for: alarm)
        return HStack(spacing: 4) {
            Circle()
                .fill(info.color)
                .frame(width: 6, height: 6)
            Text(info.text)
                .font(Font.smallCaption())
                .foregroundStyle(info.color)
        }
    }

    private var separatorLine: some View {
        Color(light: "E5E5EA", dark: "38383A")
            .frame(height: 0.5)
    }

    private var hintSection: some View {
        Text(locale.localizedString("开启开关可手动覆盖该天的闹钟响铃状态，优先级高于自动规则。"))
            .font(Font.smallCaption())
            .foregroundStyle(Color.fgSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
    }

    private func overrideBinding(for alarm: Alarm) -> Binding<Bool> {
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        let defaultWillRing = alarm.shouldRing(on: date, holidays: holidays, makeupDays: makeupDays)

        return Binding(
            get: {
                if let override = alarm.manualOverrides[dateKey] {
                    return override
                }
                return defaultWillRing
            },
            set: { newValue in
                if newValue == defaultWillRing {
                    alarm.manualOverrides.removeValue(forKey: dateKey)
                } else {
                    alarm.manualOverrides[dateKey] = newValue
                }
            }
        )
    }

    private func statusInfo(for alarm: Alarm) -> (text: String, color: Color) {
        if let override = alarm.manualOverrides[dateKey] {
            if override {
                return (locale.localizedString("手动覆盖 · 强制响铃"), Color.iosGreen)
            } else {
                return (locale.localizedString("手动覆盖 · 不响铃"), Color.holidayRed)
            }
        }

        if holidayProvider.isHoliday(dateKey, year: year) && alarm.skipHolidays {
            return (locale.localizedString("节假日跳过 · 不响铃"), Color.holidayRed)
        }

        if holidayProvider.isMakeupDay(dateKey, year: year) && alarm.ringOnMakeupDays {
            return (locale.localizedString("补班日 · 正常响铃"), Color.iosGreen)
        }

        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)
        if alarm.shouldRing(on: date, holidays: holidays, makeupDays: makeupDays) {
            return (locale.localizedString("正常响铃"), Color.iosGreen)
        } else {
            return (locale.localizedString("不响铃"), Color.fgSecondary)
        }
    }
}
