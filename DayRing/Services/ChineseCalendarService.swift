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
        let gregorian = Calendar(identifier: .gregorian)
        let month = gregorian.component(.month, from: date)
        let day = gregorian.component(.day, from: date)
        let year = gregorian.component(.year, from: date)
        let key = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        return solarTermDates[key]
    }

    private let solarTermDates: [String: String] = [
        "2026-01-05": "小寒", "2026-01-20": "大寒",
        "2026-02-04": "立春", "2026-02-18": "雨水",
        "2026-03-05": "惊蛰", "2026-03-20": "春分",
        "2026-04-05": "清明", "2026-04-20": "谷雨",
        "2026-05-05": "立夏", "2026-05-21": "小满",
        "2026-06-05": "芒种", "2026-06-21": "夏至",
        "2026-07-07": "小暑", "2026-07-22": "大暑",
        "2026-08-07": "立秋", "2026-08-23": "处暑",
        "2026-09-07": "白露", "2026-09-23": "秋分",
        "2026-10-08": "寒露", "2026-10-23": "霜降",
        "2026-11-07": "立冬", "2026-11-22": "小雪",
        "2026-12-07": "大雪", "2026-12-22": "冬至",
    ]

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
