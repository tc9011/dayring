import Foundation

struct ChineseCalendarService: Sendable {
    private let chineseCalendar = Calendar(identifier: .chinese)

    func lunarDateString(for date: Date) -> String {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else { return "" }

        let monthName = lunarMonthName(month)
        let dayName = lunarDayName(day)
        return "\(monthName)\(dayName)"
    }

    func solarTerm(for date: Date) -> String? {
        nil
    }

    private func lunarMonthName(_ month: Int) -> String {
        let names = ["", "正月", "二月", "三月", "四月", "五月",
                     "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        guard month > 0, month < names.count else { return "" }
        return names[month]
    }

    private func lunarDayName(_ day: Int) -> String {
        let digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

        guard day >= 1, day <= 30 else { return "" }

        if day == 10 { return "初十" }
        if day == 20 { return "二十" }
        if day == 30 { return "三十" }

        if day < 10 {
            return "初\(digits[day])"
        } else if day < 20 {
            return "十\(digits[day % 10])"
        } else {
            return "廿\(digits[day % 10])"
        }
    }
}
