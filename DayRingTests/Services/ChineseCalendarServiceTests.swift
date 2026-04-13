import Testing
import Foundation
@testable import DayRing

@Suite("ChineseCalendarService Tests")
struct ChineseCalendarServiceTests {

    let service = ChineseCalendarService()

    @Test("Chinese calendar date for known date: Mid-Autumn 2026-09-25 is 八月十五")
    func midAutumnChineseDate() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 25))!
        let result = service.chineseDateString(for: date)
        #expect(result == "八月十五")
    }

    @Test("Chinese calendar date for Spring Festival 2026-02-17 is 正月初一")
    func springFestival() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 17))!
        let result = service.chineseDateString(for: date)
        #expect(result == "正月初一")
    }

    @Test("Chinese calendar month names cover all 12 Gregorian months of 2026")
    func chineseMonthNamesNotEmpty() {
        let calendar = Calendar.current
        for month in 1...12 {
            let date = calendar.date(from: DateComponents(year: 2026, month: month, day: 1))!
            let result = service.chineseDateString(for: date)
            #expect(!result.isEmpty, "Month \(month) should produce a non-empty Chinese calendar date")
        }
    }

    @Test("Chinese calendar day names are non-empty for 60 consecutive days starting 2026-01-01")
    func chineseDaySpecialCases() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        for dayOffset in 0..<60 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let result = service.chineseDateString(for: date)
            #expect(!result.isEmpty, "Day offset \(dayOffset) should produce non-empty Chinese calendar date")
        }
    }

    @Test("dateString for Chinese calendar returns same as chineseDateString")
    func dateStringChineseCalendar() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 17))!
        let result = service.chineseDateString(for: date)
        #expect(result == "正月初一")
    }
}

@Suite("HolidayDataProvider Tests")
struct HolidayDataProviderTests {

    let provider = HolidayDataProvider()

    @Test("Oct 1 2026 is a holiday named 国庆节")
    func nationalDay() {
        #expect(provider.isHoliday("2026-10-01", year: 2026) == true)
        #expect(provider.holidayName(for: "2026-10-01", year: 2026) == "国庆节")
    }

    @Test("All 7 days of National Day holiday are holidays")
    func fullNationalDayWeek() {
        for day in 1...7 {
            let key = String(format: "2026-10-%02d", day)
            #expect(provider.isHoliday(key, year: 2026) == true, "\(key) should be a holiday")
        }
    }

    @Test("Oct 10 2026 is a makeup workday")
    func makeupDay() {
        #expect(provider.isMakeupDay("2026-10-10", year: 2026) == true)
    }

    @Test("Spring Festival 2026-02-14 to 02-20 are holidays")
    func springFestivalRange() {
        for day in 14...20 {
            let key = String(format: "2026-02-%02d", day)
            #expect(provider.isHoliday(key, year: 2026) == true, "\(key) should be a Spring Festival holiday")
        }
    }

    @Test("Spring Festival makeup days")
    func springFestivalMakeup() {
        #expect(provider.isMakeupDay("2026-02-11", year: 2026) == true)
        #expect(provider.isMakeupDay("2026-02-22", year: 2026) == true)
    }

    @Test("Regular workday is neither holiday nor makeup day")
    func regularDay() {
        #expect(provider.isHoliday("2026-04-13", year: 2026) == false)
        #expect(provider.isMakeupDay("2026-04-13", year: 2026) == false)
        #expect(provider.holidayName(for: "2026-04-13", year: 2026) == nil)
    }

    @Test("Unknown year returns empty sets")
    func unknownYear() {
        #expect(provider.holidays(for: 2030).isEmpty)
        #expect(provider.makeupDays(for: 2030).isEmpty)
    }

    @Test("Holiday name returns nil for non-holiday date")
    func noHolidayName() {
        #expect(provider.holidayName(for: "2026-03-15", year: 2026) == nil)
    }
}
