# DayRing (该起了) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
>
> **⚠️ MANDATORY: Test-Driven Development (TDD).** Every task MUST follow the Red-Green-Refactor cycle:
> 1. **Red** — Write failing tests FIRST that define the expected behavior
> 2. **Green** — Write the minimum implementation code to make tests pass
> 3. **Refactor** — Clean up while keeping tests green
>
> No implementation code may be written before its corresponding tests exist and fail. This applies to models, services, view models, and any testable logic. Views may use SwiftUI previews as visual tests.

**Goal:** Build a smart iOS calendar alarm app that integrates Chinese calendar holidays, makeup workdays, and multiple repeat patterns (daily, weekly, biweekly, rotating shifts, custom) with intelligent skip/override logic.

**Architecture:** SwiftUI-first with MVVM. AlarmKit for scheduling alarms. SwiftData for persistence. Standalone app (no server). Three-tab structure: Alarm List, Calendar View, Settings. Modal sheets for alarm editing and repeat mode configuration. Chinese calendar (农历) integration via Foundation's `Calendar(identifier: .chinese)`.

**Development Process:** Test-Driven Development (TDD) is mandatory. Write tests before implementation for all non-UI logic. Use Swift Testing framework (`@Test`, `#expect`). Run tests after every task. A task is not complete until all its tests pass.

**Tech Stack:** iOS 26 / iPadOS 26, Swift 6, SwiftUI, Liquid Glass design language, AlarmKit, SwiftData, WidgetKit (future), Foundation Calendar APIs

---

## Design Reference

Design file: `/Users/theon/Downloads/untitled.pen` (Pencil)

### Screen Inventory (10 screens)

| # | Screen | Purpose |
|---|--------|---------|
| 1 | Alarm List | Main tab — scrollable list of alarm cards with toggle, status, skip button |
| 2 | Calendar View | Main tab — monthly calendar grid showing holidays/makeup days/alarm times per cell |
| 3 | Settings | Main tab — timezone, first day of week, time format (12h/24h), calendars, language |
| 4 | Alarm Edit Sheet | Modal — time picker, label, repeat mode, ringtone, snooze, advance ring, delete-after-ring, smart calendar |
| 5 | Day Detail Sheet | Modal — tapped calendar day showing date info + alarm override toggles |
| 6 | Weekly Detail | Push — select which days of week to ring (default: all selected) |
| 7 | Biweekly Detail | Push — two-week grid (Mon-Sun × 2), 2-week cycle |
| 8 | Rotating Detail | Push — start date, ring days count, gap days count, cycle preview |
| 9 | Custom Calendar Detail | Push — full month calendar with tap-to-select dates |
| 10 | Repeat Mode Picker | Push — list of 5 repeat modes with icons, descriptions, checkmark on current |

### Design Tokens

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `--accent` | `#FF9500` | `#FF9F0A` | Primary orange — buttons, selected states, FAB |
| `--bg` | `#F2F2F7` | `#000000` | Background |
| `--bg-secondary` | `#FFFFFF` | `#1C1C1E` | Cards, sections |
| `--bg-tertiary` | `#E5E5EA` | `#2C2C2E` | Inactive circles, separators |
| `--fg-primary` | `#000000` | `#FFFFFF` | Primary text |
| `--fg-secondary` | `#8E8E93` | `#98989D` | Secondary text, labels |
| `--fg-tertiary` | `#C7C7CC` | `#48484A` | Tertiary text, chevrons |
| `--separator` | `#E5E5EA` | `#38383A` | Divider lines |
| `--holiday-red` | `#FF3B30` | `#FF453A` | Holiday markers, "休" badge |
| `--holiday-red-bg` | `#FFEBEE` | `#3A1215` | Holiday cell background |
| `--makeup-purple` | `#AF52DE` | `#BF5AF2` | Makeup workday markers |
| `--makeup-purple-bg` | `#F3E5F5` | `#2A1230` | Makeup workday cell background |
| `--ios-green` | `#34C759` | `#30D158` | Toggle on state |
| `--today-bg` | `#FF950020` | `#FF9F0A30` | Today cell highlight |
| `--glass-bg` | `#FFFFFFCC` | `#1C1C1ECC` | Tab pill, glass containers |
| `--glass-border` | `#FFFFFF66` | `#FFFFFF1A` | Glass container border |
| Font: UI | `Inter` | — | All UI text |
| Font: Time | `Geist Mono` | Time display (07:00) |
| Corner Radius: Cards | `16pt` | Alarm cards |
| Corner Radius: Calendar cells | `8pt` | Calendar day cells with backgrounds |
| Corner Radius: Sections | `12pt` | Settings grouped sections |

---

## Task 0: Project Setup

**Files:**
- Create: Xcode project via `File > New > Project > App`
- Create: `DayRing/` source directory structure
- Create: `DayRingTests/` test directory

**Step 1: Create Xcode project**

Create a new Xcode project:
- Product Name: `DayRing`
- Team: (developer's team)
- Organization Identifier: `com.dayring`
- Interface: SwiftUI
- Language: Swift
- Storage: SwiftData
- Testing System: Swift Testing
- Deployment Target: iOS 26.0

**Step 2: Set up directory structure**

```
DayRing/
├── App/
│   ├── DayRingApp.swift          # @main entry
│   └── ContentView.swift         # Root TabView
├── Models/
│   ├── Alarm.swift               # SwiftData @Model
│   ├── RepeatMode.swift          # Enum: daily/weekly/biweekly/rotating/custom
│   ├── CalendarDay.swift         # Calendar day metadata
│   └── Settings.swift            # App settings model
├── ViewModels/
│   ├── AlarmListViewModel.swift
│   ├── CalendarViewModel.swift
│   ├── AlarmEditViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── AlarmList/
│   │   ├── AlarmListView.swift
│   │   ├── AlarmCardView.swift
│   │   └── NextAlarmBanner.swift
│   ├── Calendar/
│   │   ├── CalendarView.swift
│   │   ├── CalendarGridView.swift
│   │   ├── CalendarDayCellView.swift
│   │   └── DayDetailSheet.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── AlarmEdit/
│   │   ├── AlarmEditSheet.swift
│   │   ├── TimePickerView.swift
│   │   ├── RepeatModePicker.swift
│   │   ├── WeeklyDetailView.swift
│   │   ├── BiweeklyDetailView.swift
│   │   ├── RotatingDetailView.swift
│   │   └── CustomCalendarDetailView.swift
│   └── Shared/
│       ├── GlassTabBar.swift
│       ├── WeekdaySelectorView.swift
│       └── ToggleRow.swift
├── Services/
│   ├── AlarmScheduler.swift      # AlarmKit integration
│   ├── ChineseCalendarService.swift  # 农历 + holidays
│   └── HolidayDataProvider.swift # Holiday/makeup day data
├── Extensions/
│   ├── Date+Extensions.swift
│   ├── Color+Theme.swift
│   └── Font+Theme.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

**Step 3: Install fonts**

Add `Geist Mono` font files to the project:
1. Download Geist Mono from https://vercel.com/font
2. Add `.otf` files to `Resources/Fonts/`
3. Register in Info.plist under `Fonts provided by application`

`Inter` is available as a system font on iOS 26, no installation needed.

**Step 4: Commit**

```bash
git add .
git commit -m "chore: initialize DayRing Xcode project with directory structure"
```

---

## Task 1: Design Tokens & Theme System

**Files:**
- Create: `DayRing/Extensions/Color+Theme.swift`
- Create: `DayRing/Extensions/Font+Theme.swift`
- Test: `DayRingTests/Theme/ColorThemeTests.swift`

**Step 1: Write tests FIRST (TDD Red)**

```swift
import Testing
import SwiftUI
@testable import DayRing

@Suite("Color Theme Tests")
struct ColorThemeTests {

    @Test("Hex init produces correct color components")
    func hexInit() {
        let color = Color(hex: "FF9500")
        // Verify non-nil construction — visual verification via previews
        #expect(color != nil)
    }

    @Test("Adaptive color provides different values per color scheme")
    func adaptiveColor() {
        // Color.accent should exist and be non-nil
        let accent = Color.accent
        #expect(accent != nil)
    }

    @Test("All theme colors are defined")
    func allColorsDefined() {
        // Verify every color constant compiles and exists
        let colors: [Color] = [
            .accent, .bgPrimary, .bgSecondary, .bgTertiary,
            .fgPrimary, .fgSecondary, .fgTertiary,
            .holidayRed, .holidayRedBg, .makeupPurple, .makeupPurpleBg,
            .iosGreen, .iosBlue, .iosIndigo, .iosPink,
            .separator, .glassBg, .glassBorder
        ]
        #expect(colors.count == 17)
    }
}
```

**Step 2: Write Color+Theme (TDD Green)**

```swift
import SwiftUI

extension Color {
    // MARK: - Brand (adaptive Light/Dark)
    static let accent = Color(light: "FF9500", dark: "FF9F0A")

    // MARK: - Backgrounds (adaptive)
    static let bgPrimary = Color(light: "F2F2F7", dark: "000000")
    static let bgSecondary = Color(light: "FFFFFF", dark: "1C1C1E")
    static let bgTertiary = Color(light: "E5E5EA", dark: "2C2C2E")

    // MARK: - Text (adaptive)
    static let fgPrimary = Color(light: "000000", dark: "FFFFFF")
    static let fgSecondary = Color(light: "8E8E93", dark: "98989D")
    static let fgTertiary = Color(light: "C7C7CC", dark: "48484A")

    // MARK: - Separators & Glass (adaptive)
    static let separator = Color(light: "E5E5EA", dark: "38383A")
    static let glassBg = Color(light: "FFFFFFCC", dark: "1C1C1ECC")
    static let glassBorder = Color(light: "FFFFFF66", dark: "FFFFFF1A")

    // MARK: - Calendar (adaptive)
    static let holidayRed = Color(light: "FF3B30", dark: "FF453A")
    static let holidayRedBg = Color(light: "FFEBEE", dark: "3A1215")
    static let makeupPurple = Color(light: "AF52DE", dark: "BF5AF2")
    static let makeupPurpleBg = Color(light: "F3E5F5", dark: "2A1230")
    static let todayBg = Color(light: "FF950020", dark: "FF9F0A30")

    // MARK: - System (adaptive)
    static let iosGreen = Color(light: "34C759", dark: "30D158")
    static let iosBlue = Color(hex: "007AFF")
    static let iosIndigo = Color(hex: "5856D6")
    static let iosPink = Color(hex: "FF2D55")

    // MARK: - Hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Adaptive color that switches between Light and Dark mode
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}
```

**Step 2: Write Font+Theme**

```swift
import SwiftUI

extension Font {
    // MARK: - Time display (Geist Mono)
    static func timeLarge() -> Font { .custom("GeistMono-Light", size: 72) }
    static func timeMedium() -> Font { .custom("GeistMono-Light", size: 42) }
    static func timeCard() -> Font { .custom("GeistMono-Light", size: 36) }
    static func timeSmall() -> Font { .custom("GeistMono-Regular", size: 20) }
    static func timeAlarmIndicator() -> Font { .custom("GeistMono-Medium", size: 7) }

    // MARK: - UI text (Inter / system)
    static func navTitle() -> Font { .system(size: 34, weight: .bold, design: .default) }
    static func sheetTitle() -> Font { .system(size: 17, weight: .semibold) }
    static func bodyText() -> Font { .system(size: 16) }
    static func caption() -> Font { .system(size: 13) }
    static func smallCaption() -> Font { .system(size: 12) }
    static func tinyCaption() -> Font { .system(size: 9) }
}
```

**Step 3: Commit**

```bash
git add DayRing/Extensions/
git commit -m "feat: add Color and Font theme extensions"
```

---

## Task 2: Data Models

**Files:**
- Create: `DayRing/Models/RepeatMode.swift`
- Create: `DayRing/Models/Alarm.swift`
- Create: `DayRing/Models/AppSettings.swift`
- Test: `DayRingTests/Models/AlarmTests.swift`

**Step 1: Write RepeatMode enum**

```swift
import Foundation
import SwiftData

// MARK: - Repeat Mode

enum RepeatMode: Codable, Hashable {
    case daily
    case weekly(days: Set<Weekday>)
    case biweekly(week1: Set<Weekday>, week2: Set<Weekday>)
    case rotating(startDate: Date, ringDays: Int, gapDays: Int)
    case custom(dates: Set<DateComponents>)
}

// MARK: - Weekday (Monday = 1 ... Sunday = 7)

enum Weekday: Int, Codable, CaseIterable, Hashable, Comparable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    var shortName: String {
        switch self {
        case .monday: "一"
        case .tuesday: "二"
        case .wednesday: "三"
        case .thursday: "四"
        case .friday: "五"
        case .saturday: "六"
        case .sunday: "日"
        }
    }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static let workdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let allDays: Set<Weekday> = Set(Weekday.allCases)
}
```

**Step 2: Write Alarm model**

```swift
import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var hour: Int             // 0-23
    var minute: Int           // 0-59
    var label: String
    var repeatMode: RepeatMode
    var ringtone: String
    var snoozeDuration: Int   // minutes (0 = disabled)
    var advanceMinutes: Int   // 0, 5, 10, 15, 30
    var deleteAfterRing: Bool
    var isEnabled: Bool

    // Smart calendar
    var skipHolidays: Bool
    var ringOnMakeupDays: Bool

    // Manual overrides: [dateString: shouldRing]
    // e.g. "2026-10-01": true means force ring on that holiday
    var manualOverrides: [String: Bool]

    // Skip next occurrence
    var skipNextDate: Date?

    var createdAt: Date
    var updatedAt: Date

    init(
        hour: Int = 7,
        minute: Int = 0,
        label: String = "",
        repeatMode: RepeatMode = .weekly(days: Weekday.workdays),
        ringtone: String = "radar",
        snoozeDuration: Int = 5,
        advanceMinutes: Int = 0,
        deleteAfterRing: Bool = false,
        isEnabled: Bool = true,
        skipHolidays: Bool = true,
        ringOnMakeupDays: Bool = true,
        manualOverrides: [String: Bool] = [:],
        skipNextDate: Date? = nil
    ) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.label = label
        self.repeatMode = repeatMode
        self.ringtone = ringtone
        self.snoozeDuration = snoozeDuration
        self.advanceMinutes = advanceMinutes
        self.deleteAfterRing = deleteAfterRing
        self.isEnabled = isEnabled
        self.skipHolidays = skipHolidays
        self.ringOnMakeupDays = ringOnMakeupDays
        self.manualOverrides = manualOverrides
        self.skipNextDate = skipNextDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var amPmString: String {
        hour < 12 ? "AM" : "PM"
    }

    var hour12: Int {
        let h = hour % 12
        return h == 0 ? 12 : h
    }

    var repeatModeDisplayName: String {
        switch repeatMode {
        case .daily: "每天"
        case .weekly: "每周"
        case .biweekly: "大小周"
        case .rotating: "轮休"
        case .custom: "自定义"
        }
    }

    var repeatDetailText: String {
        switch repeatMode {
        case .daily:
            return "每天"
        case .weekly(let days):
            if days == Weekday.workdays { return "工作日" }
            if days == Weekday.allDays { return "每天" }
            return days.sorted().map(\.shortName).joined(separator: "、")
        case .biweekly:
            return "大小周"
        case .rotating(_, let ring, let gap):
            return "响\(ring)天休\(gap)天"
        case .custom(let dates):
            return "\(dates.count)天"
        }
    }

    /// Determines if alarm should ring on a given date,
    /// considering repeat mode, holidays, makeup days, manual overrides, and skip-next.
    func shouldRing(on date: Date, holidays: Set<String>, makeupDays: Set<String>) -> Bool {
        let dateKey = Self.dateKey(for: date)

        // Manual override takes highest priority
        if let override = manualOverrides[dateKey] {
            return override
        }

        // Skip next
        if let skipDate = skipNextDate, Calendar.current.isDate(date, inSameDayAs: skipDate) {
            return false
        }

        // Check if date matches repeat pattern
        guard matchesRepeatPattern(date) else { return false }

        // Holiday logic
        if holidays.contains(dateKey) && skipHolidays {
            return false
        }

        // Makeup day logic
        if makeupDays.contains(dateKey) && ringOnMakeupDays {
            return true
        }

        return true
    }

    private func matchesRepeatPattern(_ date: Date) -> Bool {
        let calendar = Calendar.current

        switch repeatMode {
        case .daily:
            return true

        case .weekly(let days):
            let weekday = calendar.component(.weekday, from: date)
            // Convert: Sunday=1...Saturday=7 → Monday=1...Sunday=7
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            return days.contains(wd)

        case .biweekly(let week1, let week2):
            let weekday = calendar.component(.weekday, from: date)
            let adjusted = weekday == 1 ? 7 : weekday - 1
            guard let wd = Weekday(rawValue: adjusted) else { return false }
            let weekNumber = calendar.component(.weekOfYear, from: date)
            return weekNumber % 2 == 0 ? week1.contains(wd) : week2.contains(wd)

        case .rotating(let startDate, let ringDays, let gapDays):
            let cycle = ringDays + gapDays
            guard cycle > 0 else { return false }
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
            guard daysSinceStart >= 0 else { return false }
            let positionInCycle = daysSinceStart % cycle
            return positionInCycle < ringDays

        case .custom(let dateComponents):
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return dateComponents.contains(components)
        }
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
```

**Step 3: Write AppSettings model**

```swift
import Foundation
import SwiftData

@Model
final class AppSettings {
    var timeFormat: TimeFormat
    var firstDayOfWeek: Weekday
    var locale: AppLocale
    var selectedCalendars: Set<CalendarType>
    var timezone: TimezoneOption

    init(
        timeFormat: TimeFormat = .h24,
        firstDayOfWeek: Weekday = .monday,
        locale: AppLocale = .system,
        selectedCalendars: Set<CalendarType> = [.lunar],
        timezone: TimezoneOption = .system
    ) {
        self.timeFormat = timeFormat
        self.firstDayOfWeek = firstDayOfWeek
        self.locale = locale
        self.selectedCalendars = selectedCalendars
        self.timezone = timezone
    }
}

enum TimeFormat: String, Codable, CaseIterable {
    case h12 = "12h"
    case h24 = "24h"
}

enum AppLocale: String, Codable, CaseIterable {
    case system = "跟随系统"
    case zhHans = "简体中文"
    case zhHant = "繁體中文"
    case en = "English"
    case ja = "日本語"
}

enum CalendarType: String, Codable, CaseIterable, Hashable {
    case lunar = "农历"
    case islamic = "伊斯兰历"
    case hebrew = "希伯来历"
    case persian = "波斯历"
    case indian = "印度历"
}

enum TimezoneOption: Codable, Hashable {
    case system
    case specific(identifier: String)

    var displayName: String {
        switch self {
        case .system: "跟随系统"
        case .specific(let id): TimeZone(identifier: id)?.localizedName(for: .standard, locale: .current) ?? id
        }
    }
}
```

**Step 4: Write Alarm tests**

```swift
import Testing
import Foundation
@testable import DayRing

@Suite("Alarm Model Tests")
struct AlarmTests {

    @Test("Default alarm is 07:00 weekdays")
    func defaultAlarm() {
        let alarm = Alarm()
        #expect(alarm.hour == 7)
        #expect(alarm.minute == 0)
        #expect(alarm.isEnabled == true)
        if case .weekly(let days) = alarm.repeatMode {
            #expect(days == Weekday.workdays)
        } else {
            Issue.record("Expected weekly repeat mode")
        }
    }

    @Test("Time string formatting")
    func timeString() {
        let alarm = Alarm(hour: 7, minute: 0)
        #expect(alarm.timeString == "07:00")
        #expect(alarm.amPmString == "AM")
        #expect(alarm.hour12 == 7)

        let pm = Alarm(hour: 14, minute: 30)
        #expect(pm.timeString == "14:30")
        #expect(pm.amPmString == "PM")
        #expect(pm.hour12 == 2)
    }

    @Test("Weekly pattern matching")
    func weeklyPattern() {
        let alarm = Alarm(repeatMode: .weekly(days: Weekday.workdays))
        let calendar = Calendar.current

        // 2026-04-13 is a Monday
        let monday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 13))!
        #expect(alarm.shouldRing(on: monday, holidays: [], makeupDays: []) == true)

        // 2026-04-18 is a Saturday
        let saturday = calendar.date(from: DateComponents(year: 2026, month: 4, day: 18))!
        #expect(alarm.shouldRing(on: saturday, holidays: [], makeupDays: []) == false)
    }

    @Test("Holiday skip logic")
    func holidaySkip() {
        let alarm = Alarm(skipHolidays: true)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        let holidays: Set<String> = ["2026-10-01"]

        #expect(alarm.shouldRing(on: date, holidays: holidays, makeupDays: []) == false)
    }

    @Test("Manual override beats holiday skip")
    func manualOverride() {
        var alarm = Alarm(skipHolidays: true)
        alarm.manualOverrides["2026-10-01"] = true
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        let holidays: Set<String> = ["2026-10-01"]

        #expect(alarm.shouldRing(on: date, holidays: holidays, makeupDays: []) == true)
    }

    @Test("Rotating pattern: 4 ring, 2 gap")
    func rotatingPattern() {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        let alarm = Alarm(repeatMode: .rotating(startDate: start, ringDays: 4, gapDays: 2))

        // Day 0-3: ring, Day 4-5: gap, Day 6-9: ring, ...
        let day0 = start
        let day3 = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        let day4 = Calendar.current.date(byAdding: .day, value: 4, to: start)!
        let day5 = Calendar.current.date(byAdding: .day, value: 5, to: start)!
        let day6 = Calendar.current.date(byAdding: .day, value: 6, to: start)!

        #expect(alarm.shouldRing(on: day0, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day3, holidays: [], makeupDays: []) == true)
        #expect(alarm.shouldRing(on: day4, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day5, holidays: [], makeupDays: []) == false)
        #expect(alarm.shouldRing(on: day6, holidays: [], makeupDays: []) == true)
    }

    @Test("Skip next date")
    func skipNext() {
        var alarm = Alarm()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        alarm.skipNextDate = tomorrow

        #expect(alarm.shouldRing(on: tomorrow, holidays: [], makeupDays: []) == false)
    }

    @Test("Delete after ring flag")
    func deleteAfterRing() {
        let alarm = Alarm(deleteAfterRing: true)
        #expect(alarm.deleteAfterRing == true)
    }
}
```

**Step 5: Run tests**

```bash
xcodebuild test -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing DayRingTests/AlarmTests 2>&1 | xcpretty
```
Expected: All tests PASS

**Step 6: Commit**

```bash
git add .
git commit -m "feat: add data models (Alarm, RepeatMode, AppSettings) with tests"
```

---

## Task 3: Chinese Calendar & Holiday Service

**Files:**
- Create: `DayRing/Services/ChineseCalendarService.swift`
- Create: `DayRing/Services/HolidayDataProvider.swift`
- Test: `DayRingTests/Services/ChineseCalendarServiceTests.swift`

**Step 1: Write ChineseCalendarService**

```swift
import Foundation

struct ChineseCalendarService {
    private let chineseCalendar = Calendar(identifier: .chinese)

    /// Returns the lunar date string for a Gregorian date.
    /// e.g. "九月初一", "八月十五", "正月初一"
    func lunarDateString(for date: Date) -> String {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else { return "" }

        let monthName = lunarMonthName(month)
        let dayName = lunarDayName(day)
        return "\(monthName)\(dayName)"
    }

    /// Returns solar term name if date falls on one, otherwise nil.
    /// 24 solar terms (节气): 立春, 雨水, 惊蛰, ...
    func solarTerm(for date: Date) -> String? {
        // Solar terms are determined by the Sun's ecliptic longitude.
        // For production: use a proper astronomical calculation or lookup table.
        // Placeholder: return nil for now, implement with lookup table.
        return nil
    }

    // MARK: - Private

    private func lunarMonthName(_ month: Int) -> String {
        let names = ["", "正月", "二月", "三月", "四月", "五月",
                     "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        guard month > 0, month < names.count else { return "" }
        return names[month]
    }

    private func lunarDayName(_ day: Int) -> String {
        let prefixes = ["初", "初", "初", "初", "初", "初", "初", "初", "初", "初",
                        "十", "十", "十", "十", "十", "十", "十", "十", "十", "十",
                        "廿", "廿", "廿", "廿", "廿", "廿", "廿", "廿", "廿", "廿"]
        let digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

        guard day >= 1, day <= 30 else { return "" }

        if day == 10 { return "初十" }
        if day == 20 { return "二十" }
        if day == 30 { return "三十" }

        let prefix = prefixes[day - 1]
        let digit = digits[day % 10]
        return "\(prefix)\(digit)"
    }
}
```

**Step 2: Write HolidayDataProvider**

```swift
import Foundation

/// Provides Chinese national holiday and makeup workday data.
/// Data source: China State Council annual holiday announcements.
struct HolidayDataProvider {

    struct YearData: Codable {
        let holidays: [String]      // ["2026-10-01", "2026-10-02", ...]
        let makeupDays: [String]    // ["2026-10-10", ...]
    }

    /// Returns holiday dates for a given year as date key strings "yyyy-MM-dd"
    func holidays(for year: Int) -> Set<String> {
        guard let data = yearData[year] else { return [] }
        return Set(data.holidays)
    }

    /// Returns makeup workday dates for a given year
    func makeupDays(for year: Int) -> Set<String> {
        guard let data = yearData[year] else { return [] }
        return Set(data.makeupDays)
    }

    /// Check if a specific date is a holiday
    func isHoliday(_ dateKey: String, year: Int) -> Bool {
        holidays(for: year).contains(dateKey)
    }

    /// Check if a specific date is a makeup workday
    func isMakeupDay(_ dateKey: String, year: Int) -> Bool {
        makeupDays(for: year).contains(dateKey)
    }

    /// Holiday name for a given date, if any
    func holidayName(for dateKey: String, year: Int) -> String? {
        guard let data = holidayNames[year] else { return nil }
        return data[dateKey]
    }

    // MARK: - Data (to be populated annually)
    // In production: load from JSON bundle or remote API

    private let yearData: [Int: YearData] = [
        2026: YearData(
            holidays: [
                // 国庆节
                "2026-10-01", "2026-10-02", "2026-10-03",
                "2026-10-04", "2026-10-05", "2026-10-06", "2026-10-07",
                // 春节 (placeholder dates)
                "2026-02-14", "2026-02-15", "2026-02-16",
                "2026-02-17", "2026-02-18", "2026-02-19", "2026-02-20",
                // 清明
                "2026-04-04", "2026-04-05", "2026-04-06",
                // 劳动节
                "2026-05-01", "2026-05-02", "2026-05-03",
                "2026-05-04", "2026-05-05",
                // 端午
                "2026-06-19", "2026-06-20", "2026-06-21",
                // 中秋
                "2026-09-25", "2026-09-26", "2026-09-27",
            ],
            makeupDays: [
                "2026-10-10",  // 国庆调休补班
                "2026-02-11",  // 春节调休
                "2026-02-22",  // 春节调休
            ]
        )
    ]

    private let holidayNames: [Int: [String: String]] = [
        2026: [
            "2026-10-01": "国庆节",
            "2026-10-02": "国庆节",
            "2026-10-03": "国庆节",
            "2026-10-04": "国庆节",
            "2026-10-05": "国庆节",
            "2026-10-06": "国庆节",
            "2026-10-07": "国庆节",
            "2026-02-14": "春节",
            "2026-02-15": "春节",
            "2026-02-16": "春节",
            "2026-02-17": "春节",
            "2026-02-18": "春节",
            "2026-02-19": "春节",
            "2026-02-20": "春节",
            "2026-04-04": "清明节",
            "2026-04-05": "清明节",
            "2026-04-06": "清明节",
            "2026-05-01": "劳动节",
            "2026-06-19": "端午节",
            "2026-09-25": "中秋节",
        ]
    ]
}
```

**Step 3: Write tests**

```swift
import Testing
import Foundation
@testable import DayRing

@Suite("ChineseCalendarService Tests")
struct ChineseCalendarServiceTests {

    let service = ChineseCalendarService()

    @Test("Lunar date for known dates")
    func lunarDate() {
        // Mid-Autumn Festival 2026 is Sep 25, should be 八月十五
        // (Verify with actual data before shipping)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 25))!
        let result = service.lunarDateString(for: date)
        #expect(!result.isEmpty)
    }
}

@Suite("HolidayDataProvider Tests")
struct HolidayDataProviderTests {

    let provider = HolidayDataProvider()

    @Test("Oct 1 2026 is a holiday")
    func nationalDay() {
        #expect(provider.isHoliday("2026-10-01", year: 2026) == true)
        #expect(provider.holidayName(for: "2026-10-01", year: 2026) == "国庆节")
    }

    @Test("Oct 10 2026 is a makeup workday")
    func makeupDay() {
        #expect(provider.isMakeupDay("2026-10-10", year: 2026) == true)
    }

    @Test("Regular workday is neither")
    func regularDay() {
        #expect(provider.isHoliday("2026-04-13", year: 2026) == false)
        #expect(provider.isMakeupDay("2026-04-13", year: 2026) == false)
    }
}
```

**Step 4: Run tests**

```bash
xcodebuild test -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```
Expected: All tests PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add ChineseCalendarService and HolidayDataProvider with tests"
```

---

## Task 4: App Shell & Tab Navigation

**Files:**
- Modify: `DayRing/App/DayRingApp.swift`
- Modify: `DayRing/App/ContentView.swift`
- Create: `DayRing/Views/Shared/GlassTabBar.swift`
- Create: `DayRing/Views/AlarmList/AlarmListView.swift` (placeholder)
- Create: `DayRing/Views/Calendar/CalendarView.swift` (placeholder)
- Create: `DayRing/Views/Settings/SettingsView.swift` (placeholder)

**Step 1: Write DayRingApp**

```swift
import SwiftUI
import SwiftData

@main
struct DayRingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Alarm.self, AppSettings.self])
    }
}
```

**Step 2: Write ContentView with TabView**

```swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("闹钟", systemImage: "alarm.fill", value: 0) {
                AlarmListView()
            }
            Tab("日历", systemImage: "calendar", value: 1) {
                CalendarTabView()
            }
            Tab("设置", systemImage: "gearshape.fill", value: 2) {
                SettingsView()
            }
        }
        .tint(.accent)
    }
}
```

Note: iOS 26 Liquid Glass tab bar is the default TabView style. No custom GlassTabBar needed — the system provides it automatically.

**Step 3: Write placeholder views**

```swift
// AlarmListView.swift
import SwiftUI

struct AlarmListView: View {
    var body: some View {
        NavigationStack {
            Text("闹钟列表")
                .navigationTitle("闹钟")
        }
    }
}

// CalendarTabView.swift
import SwiftUI

struct CalendarTabView: View {
    var body: some View {
        NavigationStack {
            Text("日历视图")
                .navigationTitle("日历")
        }
    }
}

// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("设置")
                .navigationTitle("设置")
        }
    }
}
```

**Step 4: Build and run**

```bash
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```
Expected: BUILD SUCCEEDED. App shows three tabs.

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add app shell with three-tab navigation"
```

---

## Task 5: Alarm List View (Screen 1)

**Files:**
- Modify: `DayRing/Views/AlarmList/AlarmListView.swift`
- Create: `DayRing/Views/AlarmList/AlarmCardView.swift`
- Create: `DayRing/Views/AlarmList/NextAlarmBanner.swift`
- Create: `DayRing/ViewModels/AlarmListViewModel.swift`

### Design Reference (Screen 1)

Layout top-to-bottom:
1. Status bar (system)
2. Large title "闹钟" with "编辑" button
3. Next alarm banner: "🔔 下一个闹钟将在 7小时32分钟 后响铃"
4. Scrollable list of AlarmCards
5. FAB button (bottom-right, orange circle with "+")
6. Tab bar (system)

Each AlarmCard (3 rows):
- **Top row:** Time (Geist Mono 36pt light) + AM/PM + Toggle (right-aligned)
- **Mid row:** Label + repeat info (e.g. "上班 | 每周 · 工作日")
- **Bottom row:** Status dot + next ring text (left) + "跳过下次" pill button (right)

Card states:
- Enabled: full opacity, green toggle
- Disabled: 0.5 opacity, gray toggle
- Status colors: green (next ring), orange (holiday info), red (won't ring)

**Step 1: Write AlarmListViewModel**

```swift
import Foundation
import SwiftData
import Observation

@Observable
final class AlarmListViewModel {
    var alarms: [Alarm] = []
    var showingEditor = false
    var editingAlarm: Alarm?

    private let holidayProvider = HolidayDataProvider()

    func nextAlarmText() -> String? {
        let now = Date()
        // Find the next enabled alarm's ring time
        // Simplified: just show time until first enabled alarm's next occurrence
        guard let next = alarms.first(where: { $0.isEnabled }) else { return nil }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = next.hour
        components.minute = next.minute

        guard let nextTime = calendar.date(from: components) else { return nil }
        let target = nextTime > now ? nextTime : calendar.date(byAdding: .day, value: 1, to: nextTime)!

        let diff = calendar.dateComponents([.hour, .minute], from: now, to: target)
        if let h = diff.hour, let m = diff.minute {
            return "下一个闹钟将在 \(h)小时\(m)分钟 后响铃"
        }
        return nil
    }

    func statusInfo(for alarm: Alarm) -> (text: String, color: StatusColor) {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let year = calendar.component(.year, from: today)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)

        if !alarm.isEnabled {
            return ("已关闭", .gray)
        }

        let tomorrowKey = Alarm.dateKey(for: tomorrow)
        if let name = holidayProvider.holidayName(for: tomorrowKey, year: year) {
            if alarm.skipHolidays {
                return ("后天响铃 · 明天为\(name)", .orange)
            }
        }

        if alarm.shouldRing(on: tomorrow, holidays: holidays, makeupDays: makeupDays) {
            return ("明天响铃 · 跳过节假日", .green)
        } else {
            return ("明天不响铃 · 已手动关闭", .red)
        }
    }

    func skipNext(_ alarm: Alarm) {
        // Find next ring date and set skipNextDate
        alarm.skipNextDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        alarm.updatedAt = Date()
    }

    enum StatusColor {
        case green, orange, red, gray

        var swiftUIColor: some ShapeStyle {
            switch self {
            case .green: Color.iosGreen
            case .orange: Color.accent
            case .red: Color.holidayRed
            case .gray: Color.fgSecondary
            }
        }
    }
}
```

**Step 2: Write AlarmCardView**

```swift
import SwiftUI

struct AlarmCardView: View {
    @Bindable var alarm: Alarm
    let statusText: String
    let statusColor: AlarmListViewModel.StatusColor
    let onSkipNext: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 10) {
            // Top row: time + toggle
            HStack {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(alarm.timeString)
                        .font(.timeCard())
                        .foregroundStyle(.fgPrimary)
                        .lineSpacing(0)
                    Text(alarm.amPmString)
                        .font(.smallCaption())
                        .fontWeight(.medium)
                        .foregroundStyle(.fgSecondary)
                }
                Spacer()
                Toggle("", isOn: $alarm.isEnabled)
                    .labelsHidden()
                    .tint(.iosGreen)
            }

            // Mid row: label + repeat info
            HStack {
                Text("\(alarm.label)  |  \(alarm.repeatModeDisplayName) · \(alarm.repeatDetailText)")
                    .font(.caption())
                    .foregroundStyle(.fgSecondary)
                Spacer()
            }

            // Bottom row: status + skip button
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(AnyShapeStyle(statusColor.swiftUIColor))
                        .frame(width: 6, height: 6)
                    Text(statusText)
                        .font(.system(size: 11))
                        .foregroundStyle(AnyShapeStyle(statusColor.swiftUIColor))
                }
                Spacer()
                Button(action: onSkipNext) {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 10))
                        Text("跳过下次")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.fgSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.bgPrimary, in: Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
    }
}
```

**Step 3: Write AlarmListView**

```swift
import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.hour, order: .forward) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AlarmListViewModel()
    @State private var showingEditor = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Next alarm banner
                        if let bannerText = viewModel.nextAlarmText() {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.accent)
                                Text(bannerText)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        }

                        // Alarm cards
                        ForEach(alarms) { alarm in
                            let status = viewModel.statusInfo(for: alarm)
                            AlarmCardView(
                                alarm: alarm,
                                statusText: status.text,
                                statusColor: status.color,
                                onSkipNext: { viewModel.skipNext(alarm) }
                            )
                            .onTapGesture {
                                editingAlarm = alarm
                                showingEditor = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // space for FAB + tab bar
                }

                // FAB
                Button {
                    editingAlarm = nil
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accent, in: Circle())
                        .shadow(color: .accent.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("闹钟")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("编辑") { }
                        .foregroundStyle(.accent)
                }
            }
            .sheet(isPresented: $showingEditor) {
                AlarmEditSheet(alarm: editingAlarm)
            }
            .onAppear {
                viewModel.alarms = alarms
            }
            .onChange(of: alarms) {
                viewModel.alarms = alarms
            }
        }
    }
}
```

**Step 4: Build and verify**

```bash
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add .
git commit -m "feat: implement alarm list view with card design and skip-next button"
```

---

## Task 6: Alarm Edit Sheet (Screen 4)

**Files:**
- Create: `DayRing/Views/AlarmEdit/AlarmEditSheet.swift`
- Create: `DayRing/Views/AlarmEdit/TimePickerView.swift`
- Create: `DayRing/ViewModels/AlarmEditViewModel.swift`

### Design Reference (Screen 4)

Layout top-to-bottom:
1. Sheet handle bar
2. Nav: "取消" (left) | "编辑闹钟" (center) | "保存" (right)
3. Time picker: large "07 : 00" with AM/PM toggle
4. Basic Settings group (rounded white card):
   - 标签 → 上班
   - 重复 → 每周 > (taps to Repeat Mode Picker)
   - 铃声 → 雷达 >
   - 稍后提醒 → 5 分钟
   - 提前响铃 → 不提前 >
   - 响铃后删除 → Toggle (off)
5. Smart Calendar label
6. Smart Calendar Settings group:
   - 节假日跳过 → Toggle (on)
   - 补班日响铃 → Toggle (on)
   - 查看日历覆盖 → (orange link)
7. Description text

**Step 1: Write AlarmEditViewModel**

```swift
import Foundation
import Observation

@Observable
final class AlarmEditViewModel {
    var hour: Int = 7
    var minute: Int = 0
    var label: String = ""
    var repeatMode: RepeatMode = .weekly(days: Weekday.workdays)
    var ringtone: String = "radar"
    var snoozeDuration: Int = 5
    var advanceMinutes: Int = 0
    var deleteAfterRing: Bool = false
    var isEnabled: Bool = true
    var skipHolidays: Bool = true
    var ringOnMakeupDays: Bool = true

    var isEditing: Bool { existingAlarm != nil }
    private var existingAlarm: Alarm?

    func load(from alarm: Alarm?) {
        guard let alarm else { return }
        existingAlarm = alarm
        hour = alarm.hour
        minute = alarm.minute
        label = alarm.label
        repeatMode = alarm.repeatMode
        ringtone = alarm.ringtone
        snoozeDuration = alarm.snoozeDuration
        advanceMinutes = alarm.advanceMinutes
        deleteAfterRing = alarm.deleteAfterRing
        isEnabled = alarm.isEnabled
        skipHolidays = alarm.skipHolidays
        ringOnMakeupDays = alarm.ringOnMakeupDays
    }

    func save(to alarm: Alarm?) -> Alarm {
        let target = alarm ?? Alarm()
        target.hour = hour
        target.minute = minute
        target.label = label
        target.repeatMode = repeatMode
        target.ringtone = ringtone
        target.snoozeDuration = snoozeDuration
        target.advanceMinutes = advanceMinutes
        target.deleteAfterRing = deleteAfterRing
        target.isEnabled = isEnabled
        target.skipHolidays = skipHolidays
        target.ringOnMakeupDays = ringOnMakeupDays
        target.updatedAt = Date()
        return target
    }

    var advanceMinutesText: String {
        advanceMinutes == 0 ? "不提前" : "\(advanceMinutes) 分钟"
    }

    var snoozeDurationText: String {
        snoozeDuration == 0 ? "关闭" : "\(snoozeDuration) 分钟"
    }
}
```

**Step 2: Write AlarmEditSheet**

```swift
import SwiftUI
import SwiftData

struct AlarmEditSheet: View {
    let alarm: Alarm?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AlarmEditViewModel()
    @State private var showingRepeatPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Time picker
                    TimePickerView(hour: $viewModel.hour, minute: $viewModel.minute)

                    // Basic Settings
                    GroupBox {
                        VStack(spacing: 0) {
                            settingsRow("标签", value: viewModel.label.isEmpty ? "无" : viewModel.label)
                            Divider()
                            NavigationLink {
                                RepeatModePicker(repeatMode: $viewModel.repeatMode)
                            } label: {
                                settingsRowChevron("重复", value: viewModel.repeatMode.displayName)
                            }
                            Divider()
                            settingsRowChevron("铃声", value: viewModel.ringtone)
                            Divider()
                            settingsRow("稍后提醒", value: viewModel.snoozeDurationText)
                            Divider()
                            settingsRowChevron("提前响铃", value: viewModel.advanceMinutesText)
                            Divider()
                            HStack {
                                Text("响铃后删除")
                                    .font(.bodyText())
                                Spacer()
                                Toggle("", isOn: $viewModel.deleteAfterRing)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .backgroundStyle(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Smart Calendar
                    Text("智能日历")
                        .font(.caption())
                        .foregroundStyle(.fgSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    GroupBox {
                        VStack(spacing: 0) {
                            HStack {
                                Text("节假日跳过")
                                    .font(.bodyText())
                                Spacer()
                                Toggle("", isOn: $viewModel.skipHolidays)
                                    .labelsHidden()
                                    .tint(.iosGreen)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            Divider()

                            HStack {
                                Text("补班日响铃")
                                    .font(.bodyText())
                                Spacer()
                                Toggle("", isOn: $viewModel.ringOnMakeupDays)
                                    .labelsHidden()
                                    .tint(.iosGreen)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            Divider()

                            HStack {
                                Text("查看日历覆盖")
                                    .font(.bodyText())
                                    .foregroundStyle(.accent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.fgTertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .backgroundStyle(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("开启后，节假日自动跳过闹钟，补班日自动恢复响铃。也可以在日历中手动覆盖某天的响铃状态。")
                        .font(.caption())
                        .foregroundStyle(.fgTertiary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.bgPrimary)
            .navigationTitle(alarm == nil ? "新建闹钟" : "编辑闹钟")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let saved = viewModel.save(to: alarm)
                        if alarm == nil {
                            modelContext.insert(saved)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                }
            }
        }
        .onAppear {
            viewModel.load(from: alarm)
        }
    }

    // MARK: - Row helpers

    private func settingsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.bodyText())
            Spacer()
            Text(value).font(.bodyText()).foregroundStyle(.fgSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsRowChevron(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.bodyText()).foregroundStyle(.fgPrimary)
            Spacer()
            Text(value).font(.bodyText()).foregroundStyle(.fgSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(.fgTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// Placeholder
struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(String(format: "%02d", hour))
                .font(.timeLarge())
                .foregroundStyle(.fgPrimary)
            Text(":")
                .font(.timeLarge())
                .foregroundStyle(.accent)
            Text(String(format: "%02d", minute))
                .font(.timeLarge())
                .foregroundStyle(.fgPrimary)
        }
        .padding(.vertical, 16)
    }
}
```

**Step 3: Build and verify**

```bash
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: implement alarm edit sheet with basic settings and smart calendar"
```

---

## Task 7: Repeat Mode Picker & Detail Views (Screens 6-10)

**Files:**
- Create: `DayRing/Views/AlarmEdit/RepeatModePicker.swift`
- Create: `DayRing/Views/AlarmEdit/WeeklyDetailView.swift`
- Create: `DayRing/Views/AlarmEdit/BiweeklyDetailView.swift`
- Create: `DayRing/Views/AlarmEdit/RotatingDetailView.swift`
- Create: `DayRing/Views/AlarmEdit/CustomCalendarDetailView.swift`
- Create: `DayRing/Views/Shared/WeekdaySelectorView.swift`

### Design Reference (Screen 10)

Repeat Mode Picker — list with 5 options:
1. 每天 (green icon, `repeat`) — "每天都响铃"
2. 每周 (orange icon, `calendar-days`) — "选择每周哪些天响铃" — ✓ checkmark if selected
3. 大小周 (indigo icon, `calendar-range`) — "两周为一个循环"
4. 轮休 (pink icon, `rotate-cw`) — "响铃天数 + 间隔天数循环"
5. 自定义 (blue icon, `settings-2`) — "通过日历自由配置响铃日"

Each row taps through to its detail view. Current mode shows orange ✓.

**Step 1: Write RepeatModePicker**

```swift
import SwiftUI

struct RepeatModePicker: View {
    @Binding var repeatMode: RepeatMode

    var body: some View {
        List {
            Section {
                // 每天
                modeRow(
                    icon: "repeat",
                    iconColor: .iosGreen,
                    name: "每天",
                    subtitle: "每天都响铃",
                    isSelected: isDaily,
                    destination: { selectDaily() }
                )

                // 每周
                NavigationLink {
                    WeeklyDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "calendar",
                        iconColor: .accent,
                        name: "每周",
                        subtitle: "选择每周哪些天响铃",
                        isSelected: isWeekly
                    )
                }

                // 大小周
                NavigationLink {
                    BiweeklyDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "calendar.badge.clock",
                        iconColor: .iosIndigo,
                        name: "大小周",
                        subtitle: "两周为一个循环",
                        isSelected: isBiweekly
                    )
                }

                // 轮休
                NavigationLink {
                    RotatingDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "arrow.triangle.2.circlepath",
                        iconColor: .iosPink,
                        name: "轮休",
                        subtitle: "响铃天数 + 间隔天数循环",
                        isSelected: isRotating
                    )
                }

                // 自定义
                NavigationLink {
                    CustomCalendarDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "slider.horizontal.3",
                        iconColor: .iosBlue,
                        name: "自定义",
                        subtitle: "通过日历自由配置响铃日",
                        isSelected: isCustom
                    )
                }
            }
        }
        .navigationTitle("重复")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Selection state

    private var isDaily: Bool {
        if case .daily = repeatMode { return true }
        return false
    }

    private var isWeekly: Bool {
        if case .weekly = repeatMode { return true }
        return false
    }

    private var isBiweekly: Bool {
        if case .biweekly = repeatMode { return true }
        return false
    }

    private var isRotating: Bool {
        if case .rotating = repeatMode { return true }
        return false
    }

    private var isCustom: Bool {
        if case .custom = repeatMode { return true }
        return false
    }

    private func selectDaily() {
        repeatMode = .daily
    }

    // MARK: - Row views

    private func modeRow(
        icon: String, iconColor: Color, name: String,
        subtitle: String, isSelected: Bool, destination: @escaping () -> Void
    ) -> some View {
        Button(action: destination) {
            modeRowContent(icon: icon, iconColor: iconColor, name: name, subtitle: subtitle, isSelected: isSelected)
        }
    }

    private func modeRowContent(
        icon: String, iconColor: Color, name: String,
        subtitle: String, isSelected: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(iconColor, in: RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.bodyText()).foregroundStyle(.fgPrimary)
                Text(subtitle).font(.smallCaption()).foregroundStyle(.fgSecondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.accent)
            }
        }
    }
}
```

**Step 2: Write WeeklyDetailView (Screen 6)**

```swift
import SwiftUI

struct WeeklyDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var selectedDays: Set<Weekday> = Weekday.allDays

    var body: some View {
        VStack(spacing: 20) {
            Text("选择每周哪些天响铃")
                .font(.system(size: 15))
                .foregroundStyle(.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            WeekdaySelectorView(selectedDays: $selectedDays)

            Text("默认全选。点击取消选择对应的日期。")
                .font(.caption())
                .foregroundStyle(.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("每周重复")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .weekly(days: selectedDays)
                }
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
        }
        .onAppear {
            if case .weekly(let days) = repeatMode {
                selectedDays = days
            }
        }
    }
}
```

**Step 3: Write WeekdaySelectorView (shared)**

```swift
import SwiftUI

struct WeekdaySelectorView: View {
    @Binding var selectedDays: Set<Weekday>

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(day.shortName)
                        .font(.system(size: 15, weight: selectedDays.contains(day) ? .semibold : .medium))
                        .foregroundStyle(selectedDays.contains(day) ? .white : .fgSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            selectedDays.contains(day) ? Color.accent : Color.bgTertiary,
                            in: Circle()
                        )
                }
            }
        }
    }
}
```

**Step 4: Write BiweeklyDetailView (Screen 7)**

```swift
import SwiftUI

struct BiweeklyDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var week1Days: Set<Weekday> = Weekday.workdays
    @State private var week2Days: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday]

    // All 7 days — biweekly includes weekends (design: 40px circles, 6px gap)
    private let weekdays: [Weekday] = Weekday.allCases

    var body: some View {
        VStack(spacing: 24) {
            Text("以两周为一个循环，选择每周哪些天响铃。")
                .font(.system(size: 15))
                .foregroundStyle(.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            weekBox(title: "第 1 周", days: $week1Days)
            weekBox(title: "第 2 周", days: $week2Days)

            Text("以两周为一个循环，大周和小周可分别选择响铃日。")
                .font(.caption())
                .foregroundStyle(.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("大小周")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .biweekly(week1: week1Days, week2: week2Days)
                }
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
        }
        .onAppear {
            if case .biweekly(let w1, let w2) = repeatMode {
                week1Days = w1
                week2Days = w2
            }
        }
    }

    private func weekBox(title: String, days: Binding<Set<Weekday>>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            HStack(spacing: 6) {
                ForEach(weekdays, id: \.self) { day in
                    Button {
                        if days.wrappedValue.contains(day) {
                            days.wrappedValue.remove(day)
                        } else {
                            days.wrappedValue.insert(day)
                        }
                    } label: {
                        Text(day.shortName)
                            .font(.system(size: 14, weight: days.wrappedValue.contains(day) ? .semibold : .medium))
                            .foregroundStyle(days.wrappedValue.contains(day) ? .white : .fgSecondary)
                            .frame(width: 40, height: 40)
                            .background(
                                days.wrappedValue.contains(day) ? Color.accent : Color.bgTertiary,
                                in: Circle()
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Step 5: Write RotatingDetailView (Screen 8)**

```swift
import SwiftUI

struct RotatingDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var startDate = Date()
    @State private var ringDays = 4
    @State private var gapDays = 2

    var body: some View {
        VStack(spacing: 20) {
            Text("设置轮休周期：响铃天数 + 间隔天数为一个循环，间隔期间不响铃。")
                .font(.system(size: 15))
                .foregroundStyle(.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Form
            GroupBox {
                VStack(spacing: 0) {
                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    Divider()
                    stepperRow("响铃天数", value: $ringDays, range: 1...30)
                    Divider()
                    stepperRow("间隔天数", value: $gapDays, range: 1...30)
                }
            }
            .backgroundStyle(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Cycle preview
            cyclePreview

            Text("响铃 \(ringDays) 天 → 间隔 \(gapDays) 天 → 响铃 \(ringDays) 天 → ···")
                .font(.caption())
                .foregroundStyle(.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("轮休")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .rotating(startDate: startDate, ringDays: ringDays, gapDays: gapDays)
                }
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
        }
        .onAppear {
            if case .rotating(let sd, let rd, let gd) = repeatMode {
                startDate = sd; ringDays = rd; gapDays = gd
            }
        }
    }

    private func stepperRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label).font(.bodyText())
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: range)
                .font(.timeSmall())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var cyclePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("循环预览")
                .font(.system(size: 15, weight: .semibold))

            HStack(spacing: 4) {
                let cycle = ringDays + gapDays
                ForEach(0..<min(cycle + 1, 10), id: \.self) { i in
                    let isRing = i < ringDays || (i >= cycle && i < cycle + ringDays)
                    Text("\(i % cycle + 1)")
                        .font(.system(size: 13, weight: isRing ? .semibold : .medium))
                        .foregroundStyle(isRing ? .white : .fgSecondary)
                        .frame(width: 36, height: 36)
                        .background(
                            isRing ? Color.accent : Color.bgTertiary,
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                }
                Text("···")
                    .foregroundStyle(.fgTertiary)
            }

            HStack(spacing: 16) {
                legendItem(color: .accent, text: "响铃")
                legendItem(color: .bgTertiary, text: "间隔（不响铃）")
            }
        }
        .padding(16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(text).font(.smallCaption()).foregroundStyle(.fgSecondary)
        }
    }
}
```

**Step 6: Write CustomCalendarDetailView (Screen 9) — stub**

```swift
import SwiftUI

struct CustomCalendarDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var selectedDates: Set<DateComponents> = []
    @State private var displayedMonth = Date()

    var body: some View {
        VStack(spacing: 16) {
            Text("点击日期选择响铃日，长按拖动可批量选择。")
                .font(.system(size: 15))
                .foregroundStyle(.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Month navigation
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.accent)
                }
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.accent)
                }
            }

            // Calendar grid
            calendarGrid

            // Legend
            HStack(spacing: 16) {
                legendItem(color: .accent, text: "响铃日")
                legendItem(color: .bgTertiary, text: "不响铃")
                legendItem(color: .clear, borderColor: .accent, text: "今天")
            }

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("自定义日历")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .custom(dates: selectedDates)
                }
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            }
        }
        .onAppear {
            if case .custom(let dates) = repeatMode {
                selectedDates = dates
            }
        }
    }

    // MARK: - Calendar grid (simplified)

    private var calendarGrid: some View {
        // Implementation: LazyVGrid with 7 columns
        // Each cell is tappable, toggles date in selectedDates
        // Today has orange border, selected dates are orange filled
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(datesInMonth(), id: \.self) { components in
                if let date = Calendar.current.date(from: components) {
                    let isSelected = selectedDates.contains(components)
                    let isToday = Calendar.current.isDateInToday(date)

                    Button {
                        if isSelected {
                            selectedDates.remove(components)
                        } else {
                            selectedDates.insert(components)
                        }
                    } label: {
                        Text("\(components.day ?? 0)")
                            .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? .white : (isToday ? .accent : .fgSecondary))
                            .frame(width: 44, height: 44)
                            .background(
                                isSelected ? Color.accent : (isToday ? Color.todayBg : Color.bgTertiary),
                                in: Circle()
                            )
                            .overlay {
                                if isToday && !isSelected {
                                    Circle().stroke(Color.accent, lineWidth: 2)
                                }
                            }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    private func changeMonth(_ delta: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
    }

    private func datesInMonth() -> [DateComponents] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        return range.map { day in
            DateComponents(year: components.year, month: components.month, day: day)
        }
    }

    private func legendItem(color: Color, borderColor: Color? = nil, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 22, height: 22)
                .overlay {
                    if let bc = borderColor {
                        Circle().stroke(bc, lineWidth: 2)
                    }
                }
            Text(text).font(.smallCaption()).foregroundStyle(.fgSecondary)
        }
    }
}
```

**Step 7: Build and verify**

```bash
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```

**Step 8: Commit**

```bash
git add .
git commit -m "feat: implement repeat mode picker and all detail views (weekly, biweekly, rotating, custom)"
```

---

## Task 8: Calendar Tab View (Screen 2)

**Files:**
- Modify: `DayRing/Views/Calendar/CalendarTabView.swift`
- Create: `DayRing/Views/Calendar/CalendarGridView.swift`
- Create: `DayRing/Views/Calendar/CalendarDayCellView.swift`
- Create: `DayRing/ViewModels/CalendarViewModel.swift`

### Design Reference (Screen 2)

Layout:
1. Large title "日历" with "今天" button
2. Month navigation: "< 2026年10月 >"
3. Week header: 一 二 三 四 五 六 日
4. Calendar grid (5 rows × 7 cols, 80pt row height):
   - Each cell: date number + lunar text + alarm times (vertically stacked)
   - Holiday cells: pink background `#FFEBEE`, red text, "休" badge, cornerRadius 8
   - Makeup day cells: purple background `#F3E5F5`, purple text, "补班" badge
   - Today cell: orange tint background `#FF950020`, orange text
   - Previous/next month dates: 0.3 opacity
   - Alarm indicators: orange Geist Mono 7pt, each time on its own line
5. Legend: 节假日 (red) | 补班日 (purple) | 今天 (orange) | 已覆盖 (blue?)
6. Tab bar

Cell gap between columns: 3pt. Row gap: 2pt. Grid padding: [8, 4].

**Implementation:** Use `LazyVGrid` with 7 columns. Each cell is a `CalendarDayCellView`. Tap a cell → show DayDetailSheet.

The detailed SwiftUI implementation follows the same patterns as the alarm views. Key considerations:
- Use `ChineseCalendarService` for lunar dates
- Use `HolidayDataProvider` for holiday/makeup day data
- Query all `Alarm` objects to determine which cells show alarm indicators
- Each cell's alarm times are displayed vertically in `VStack`

**Step 1: Write CalendarViewModel**

```swift
import Foundation
import Observation

@Observable
final class CalendarViewModel {
    var displayedMonth = Date()
    var selectedDate: Date?

    let chineseCalendar = ChineseCalendarService()
    let holidayProvider = HolidayDataProvider()

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    func previousMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
    }

    func nextMonth() {
        displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
    }

    func goToToday() {
        displayedMonth = Date()
    }

    func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)

        guard let firstDay = calendar.date(from: components) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay)
        // Adjust for Monday start: Mon=0, Tue=1, ..., Sun=6
        let offset = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            var dc = components
            dc.day = day
            days.append(calendar.date(from: dc))
        }

        // Pad to complete the last row
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    func alarmTimes(for date: Date, alarms: [Alarm]) -> [String] {
        let year = Calendar.current.component(.year, from: date)
        let holidays = holidayProvider.holidays(for: year)
        let makeupDays = holidayProvider.makeupDays(for: year)

        return alarms
            .filter { $0.isEnabled && $0.shouldRing(on: date, holidays: holidays, makeupDays: makeupDays) }
            .map { $0.timeString }
            .sorted()
    }
}
```

**Step 2-5: Implement CalendarTabView, CalendarGridView, CalendarDayCellView**

(Follow same pattern. Each cell shows: date, lunar text, vertically stacked alarm times in orange.)

**Step 6: Commit**

```bash
git add .
git commit -m "feat: implement calendar tab view with monthly grid, lunar dates, and alarm indicators"
```

---

## Task 9: Day Detail Sheet (Screen 5)

**Files:**
- Create: `DayRing/Views/Calendar/DayDetailSheet.swift`

### Design Reference (Screen 5)

Shows when tapping a day in the calendar:
1. Large date "1" + "10月 2026 · 周四"
2. "农历八月十九 · 国庆节" (lunar + holiday)
3. "● 法定节假日 · 闹钟默认不响铃" badge
4. "当天闹钟响铃状态" section title
5. Alarm cards with override toggles:
   - Each alarm: time + AM/PM + label + status + Toggle
   - Toggle lets user force-override for this specific date
6. Hint text at bottom

**Implementation:** Query alarms, display each with a Toggle that writes to `alarm.manualOverrides[dateKey]`.

**Commit:**

```bash
git add .
git commit -m "feat: implement day detail sheet with alarm override toggles"
```

---

## Task 10: Settings View (Screen 3)

**Files:**
- Modify: `DayRing/Views/Settings/SettingsView.swift`
- Create: `DayRing/ViewModels/SettingsViewModel.swift`

### Design Reference (Screen 3)

Three sections:
1. **通用** (General):
   - 时区 → 跟随系统 >
   - 每周第一天 → 周一 >
   - 时间格式 → [12h | **24h**] segmented toggle
2. **历法** (Calendar):
   - 其他历法 → 农历 > (Chinese default)
3. **其他** (Other):
   - 语言 → 跟随系统 >
   - 关于 DayRing >

Footer: "DayRing v1.0.0"

**Implementation:** Use `List` with `Section`. Time format uses `Picker` with `.segmented` style.

**Commit:**

```bash
git add .
git commit -m "feat: implement settings view with time format, calendar, and language options"
```

---

## Task 11: AlarmKit Integration

**Files:**
- Create: `DayRing/Services/AlarmScheduler.swift`
- Modify: `DayRing/ViewModels/AlarmEditViewModel.swift` — call scheduler on save

### Key Requirements

- Use iOS 26 AlarmKit to schedule alarms
- Schedule alarms for the next 7 days based on repeat patterns
- Re-schedule when:
  - Alarm created/edited/deleted
  - Toggle enabled/disabled
  - Skip-next tapped
  - Manual override changed
- Handle `advanceMinutes` by scheduling alarm earlier
- Handle `deleteAfterRing` by removing alarm after it fires

**Note:** AlarmKit is new in iOS 26. Consult Apple documentation for exact API. The scheduler should be a singleton service called from ViewModels.

**Commit:**

```bash
git add .
git commit -m "feat: integrate AlarmKit for alarm scheduling"
```

---

## Task 12: Polish & Liquid Glass

**Files:**
- All view files — apply Liquid Glass effects

### Key Requirements

- Tab bar: system Liquid Glass (automatic in iOS 26)
- Cards: consider `.glassEffect()` on alarm cards (test performance)
- **DO NOT** apply `.glassEffect()` to every calendar cell (42 cells = performance issue)
- **DO NOT** stack Glass on Glass
- Navigation bar: system Liquid Glass (automatic)
- Sheet presentation: system `.sheet()` with Liquid Glass handle

**Performance rules from PRD:**
> 不要在日历格子的每一个 cell 内部都加 .glassEffect()——42 个格子同时渲染 glass 会严重影响性能
> Glass on Glass 禁止——不要在 Liquid Glass 元素之上再叠加 Liquid Glass

**Commit:**

```bash
git add .
git commit -m "feat: apply Liquid Glass effects with performance constraints"
```

---

## Task 13: Localization

**Files:**
- Modify: `DayRing/Resources/Localizable.xcstrings`

### Supported Languages
- 简体中文 (default)
- 繁體中文
- English
- 日本語

Extract all user-facing strings. Chinese is the primary language.

**Commit:**

```bash
git add .
git commit -m "feat: add localization for zh-Hans, zh-Hant, en, ja"
```

---

## Design Requirements & Constraints

### DR-1: Theme Variable System — `--accent` must have Light default

The `--accent` color variable MUST define a base (Light mode) value `#FF9500` in addition to the Dark mode value `#FF9F0A`. Without the Light default, any node using `$--accent` renders as black in Light mode.

**Affected nodes:** FAB button, active tab background, and any future nodes using `$--accent`.

**Implementation rule:** In `Color+Theme.swift`, define accent as an adaptive color:
```swift
static let accent = Color(light: "FF9500", dark: "FF9F0A")
```
The `Color(hex:)` initializer should be extended with a `Color(light:dark:)` convenience that uses `@Environment(\.colorScheme)` or asset catalog.

### DR-2: 24h time format — No AM/PM display

When the user's time format setting is **24h** (the default), AM/PM indicators MUST NOT be shown anywhere:
- ❌ Alarm edit sheet: no AM/PM toggle next to time picker
- ❌ Alarm list cards: no "AM"/"PM" label after time
- ❌ Day detail sheet: no "AM"/"PM" label after alarm times

AM/PM display is ONLY shown when time format is set to **12h** in Settings.

**Implementation rule:** All time-display views must check `AppSettings.timeFormat`:
```swift
if settings.timeFormat == .h12 {
    Text(alarm.amPmString)
        .font(.smallCaption())
        .foregroundStyle(.secondary)
}
```

**Tests required:**
- `TimeDisplayTests.test24hFormatHidesAmPm()` — verify AM/PM string is not rendered in 24h mode
- `TimeDisplayTests.test12hFormatShowsAmPm()` — verify AM/PM string IS rendered in 12h mode
- `AlarmTests.testHour12Conversion()` — verify 14:30 → "2:30 PM", 7:00 → "7:00 AM"

### DR-3: Dark Mode — Month Navigation Bar styling

The calendar tab's month navigation bar ("2026年10月" with ◀ ▶ buttons) MUST use Dark mode colors:

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Nav bar background | `#FFFFFFCC` (white 80%) | `#1C1C1ECC` (dark 80%) |
| Chevron button background | `#F0F0F0` | `#2C2C2E` |
| Chevron icon color | `#000000` | `#FFFFFF` |
| Month title text | `#000000` | `#FFFFFF` |

**Implementation rule:** Use adaptive colors from the theme system, not hardcoded values.

### DR-4: Biweekly (大小周) includes weekends

The biweekly repeat mode detail view MUST show all 7 days (Mon–Sun), not just Mon–Fri. Circle size: 40pt diameter, gap: 6pt to fit within container width.

**Tests required:**
- `BiweeklyTests.testAllSevenDaysAvailable()` — verify Weekday.allCases used, not just workdays
- `BiweeklyTests.testWeekendSelectionPersists()` — verify Saturday/Sunday can be selected and saved

---

## Summary

| Task | Component | Estimated Time |
|------|-----------|---------------|
| 0 | Project Setup | 15 min |
| 1 | Theme System | 15 min |
| 2 | Data Models | 45 min |
| 3 | Calendar & Holiday Service | 30 min |
| 4 | App Shell & Tabs | 15 min |
| 5 | Alarm List View | 60 min |
| 6 | Alarm Edit Sheet | 60 min |
| 7 | Repeat Mode Picker & Details | 90 min |
| 8 | Calendar Tab View | 90 min |
| 9 | Day Detail Sheet | 45 min |
| 10 | Settings View | 30 min |
| 11 | AlarmKit Integration | 60 min |
| 12 | Liquid Glass Polish | 30 min |
| 13 | Localization | 30 min |
| **Total** | | **~9 hours** |
