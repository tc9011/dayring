import Foundation

struct HolidayDataProvider: Sendable {

    struct YearData: Codable, Sendable {
        let holidays: [String]
        let makeupDays: [String]
    }

    func holidays(for year: Int) -> Set<String> {
        guard let data = yearData[year] else { return [] }
        return Set(data.holidays)
    }

    func makeupDays(for year: Int) -> Set<String> {
        guard let data = yearData[year] else { return [] }
        return Set(data.makeupDays)
    }

    func isHoliday(_ dateKey: String, year: Int) -> Bool {
        holidays(for: year).contains(dateKey)
    }

    func isMakeupDay(_ dateKey: String, year: Int) -> Bool {
        makeupDays(for: year).contains(dateKey)
    }

    func holidayName(for dateKey: String, year: Int) -> String? {
        guard let data = holidayNames[year] else { return nil }
        return data[dateKey]
    }

    func isFirstDayOfHoliday(_ dateKey: String, year: Int) -> Bool {
        guard let groups = holidayGroups[year] else { return false }
        return groups.contains { $0.first == dateKey }
    }

    func holidayDisplayText(for dateKey: String, year: Int) -> String? {
        guard isHoliday(dateKey, year: year) else { return nil }
        if isFirstDayOfHoliday(dateKey, year: year) {
            return holidayName(for: dateKey, year: year)
        }
        return "休"
    }

    func makeupDayDisplayText(for dateKey: String, year: Int) -> String? {
        guard isMakeupDay(dateKey, year: year) else { return nil }
        return "补班"
    }

    // MARK: - Static Data

    private let yearData: [Int: YearData] = [
        2026: YearData(
            holidays: [
                "2026-10-01", "2026-10-02", "2026-10-03",
                "2026-10-04", "2026-10-05", "2026-10-06", "2026-10-07",
                "2026-02-14", "2026-02-15", "2026-02-16",
                "2026-02-17", "2026-02-18", "2026-02-19", "2026-02-20",
                "2026-04-04", "2026-04-05", "2026-04-06",
                "2026-05-01", "2026-05-02", "2026-05-03",
                "2026-05-04", "2026-05-05",
                "2026-06-19", "2026-06-20", "2026-06-21",
                "2026-09-25", "2026-09-26", "2026-09-27",
            ],
            makeupDays: [
                "2026-10-10",
                "2026-02-11",
                "2026-02-22",
            ]
        )
    ]

    private let holidayNames: [Int: [String: String]] = [
        2026: [
            "2026-10-01": "国庆节", "2026-10-02": "国庆节", "2026-10-03": "国庆节",
            "2026-10-04": "国庆节", "2026-10-05": "国庆节", "2026-10-06": "国庆节",
            "2026-10-07": "国庆节",
            "2026-02-14": "春节", "2026-02-15": "春节", "2026-02-16": "春节",
            "2026-02-17": "春节", "2026-02-18": "春节", "2026-02-19": "春节",
            "2026-02-20": "春节",
            "2026-04-04": "清明节", "2026-04-05": "清明节", "2026-04-06": "清明节",
            "2026-05-01": "劳动节", "2026-05-02": "劳动节", "2026-05-03": "劳动节",
            "2026-05-04": "劳动节", "2026-05-05": "劳动节",
            "2026-06-19": "端午节", "2026-06-20": "端午节", "2026-06-21": "端午节",
            "2026-09-25": "中秋节", "2026-09-26": "中秋节", "2026-09-27": "中秋节",
        ]
    ]

    private let holidayGroups: [Int: [[String]]] = [
        2026: [
            ["2026-02-14", "2026-02-15", "2026-02-16", "2026-02-17", "2026-02-18", "2026-02-19", "2026-02-20"],
            ["2026-04-04", "2026-04-05", "2026-04-06"],
            ["2026-05-01", "2026-05-02", "2026-05-03", "2026-05-04", "2026-05-05"],
            ["2026-06-19", "2026-06-20", "2026-06-21"],
            ["2026-09-25", "2026-09-26", "2026-09-27"],
            ["2026-10-01", "2026-10-02", "2026-10-03", "2026-10-04", "2026-10-05", "2026-10-06", "2026-10-07"],
        ]
    ]
}
