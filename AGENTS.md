# AGENTS.md - DayRing Development Guide

Coding guidelines for AI agents working on the DayRing (该起了) codebase.

## Project Overview

**Type**: Native iOS app  
**Purpose**: Smart calendar alarm clock that integrates Chinese holidays, makeup workdays, and multiple repeat patterns (daily, weekly, biweekly, rotating shifts, custom) with intelligent skip/override logic.  
**Status**: All 14 implementation tasks (Task 0–13) are complete. Alarm edit enhancements (editable label, ringtone, snooze, advance, repeat mode with "no repeat" default, delete-after-ring for non-repeating alarms) are implemented. The app is in QA/polish phase.

**Tech Stack**:

- **Platform**: iOS 26 / iPadOS 26
- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI with Liquid Glass design language
- **Architecture**: MVVM (Model-View-ViewModel)
- **Persistence**: SwiftData (`@Model`)
- **Alarm Scheduling**: AlarmKit (iOS 26)
- **Calendar**: Foundation `Calendar(identifier: .chinese)` for lunar dates
- **i18n**: Runtime locale switching via `LocaleManager` + `.xcstrings` (zh-Hans, en)
- **Testing**: Swift Testing framework (`@Test`, `#expect`, `@Suite`) — 135 tests, 11 suites
- **Fonts**: Inter (system on iOS 26) + Geist Mono (bundled)
- **Project Generation**: XcodeGen (`project.yml` → `DayRing.xcodeproj`)

## MUST FOLLOW

1. **TDD is mandatory.** Every task follows Red-Green-Refactor:
   - **Red** — Write failing tests FIRST that define expected behavior
   - **Green** — Write minimum implementation to make tests pass
   - **Refactor** — Clean up while keeping tests green
   - No implementation code may be written before its corresponding tests exist and fail

2. Before writing any code, read the implementation plan at `docs/plans/2026-04-09-dayring-implementation.md` and the design system at `DESIGN.md`.

3. If a task requires changes to more than 5 files, break it into smaller sub-tasks first.

4. After writing code, run `xcodebuild test` and verify all tests pass before committing.

5. When there's a bug, write a test that reproduces it first, then fix until the test passes.

6. After adding new `.swift` files, run `xcodegen generate` to regenerate the Xcode project before building.

## Build, Lint, and Test Commands

### Development

```bash
# Regenerate Xcode project after adding/removing .swift files
xcodegen generate

# Build for simulator
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty

# Run on simulator
xcodebuild build -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -sdk iphonesimulator
```

### Testing

```bash
# Run all tests
xcodebuild test -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty

# Run specific test suite
xcodebuild test -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing DayRingTests/AlarmTests 2>&1 | xcpretty
```

### Quality Checks

```bash
# Swift format (if configured)
swift format --in-place --recursive DayRing/

# Type checking is enforced by the compiler — strict concurrency enabled
```

## Directory Structure

```
DayRing/
├── App/
│   ├── DayRingApp.swift              # @main entry point
│   └── ContentView.swift             # Root TabView (3 tabs)
├── Models/
│   ├── Alarm.swift                   # SwiftData @Model — core alarm entity
│   ├── RepeatMode.swift              # Enum: none/daily/weekly/biweekly/rotating/custom
│   ├── AppSettings.swift             # App settings model (time format, locale, etc.)
│   └── Weekday.swift                 # Mon=1...Sun=7 with localized short names
├── ViewModels/
│   ├── AlarmListViewModel.swift      # Alarm list logic, next-alarm calculation
│   ├── CalendarViewModel.swift       # Month navigation, day metadata
│   ├── AlarmEditViewModel.swift      # Edit form state, save/load
│   └── SettingsViewModel.swift       # Settings persistence
├── Views/
│   ├── AlarmList/
│   │   ├── AlarmListView.swift       # Screen 1: alarm list + FAB
│   │   ├── AlarmCardView.swift       # Individual alarm card
│   │   └── NextAlarmBanner.swift     # "下一个闹钟将在..." banner
│   ├── Calendar/
│   │   ├── CalendarTabView.swift     # Screen 2: monthly calendar
│   │   ├── CalendarGridView.swift    # 7-column LazyVGrid
│   │   ├── CalendarDayCellView.swift # Individual day cell
│   │   └── DayDetailSheet.swift      # Screen 5: day detail with overrides
│   ├── Settings/
│   │   └── SettingsView.swift        # Screen 3: app settings + language picker
│   ├── AlarmEdit/
│   │   ├── AlarmEditSheet.swift      # Screen 4: alarm editor modal
│   │   ├── TimePickerView.swift      # Large time display/picker
│   │   ├── RepeatModePicker.swift    # Screen 10: 5-mode list
│   │   ├── WeeklyDetailView.swift    # Screen 6: weekday selector
│   │   ├── BiweeklyDetailView.swift  # Screen 7: two-week grid
│   │   ├── RotatingDetailView.swift  # Screen 8: ring/gap cycle
│   │   └── CustomCalendarDetailView.swift  # Screen 9: tap-to-select calendar
│   └── Shared/
│       └── WeekdaySelectorView.swift # Reusable weekday circle row
├── Services/
│   ├── AlarmScheduler.swift          # AlarmKit integration
│   ├── AlarmScheduleCalculator.swift # Next-ring date calculation
│   ├── ChineseCalendarService.swift  # Lunar dates via Foundation
│   ├── HolidayDataProvider.swift     # Holiday/makeup day static data
│   └── LocaleManager.swift           # Runtime i18n via .lproj bundle switching
├── Extensions/
│   ├── Color+Theme.swift             # Adaptive colors with hex init
│   ├── Font+Theme.swift              # Type scale definitions
│   ├── Date+Extensions.swift         # Date formatting helpers
│   └── LocaleManager+Environment.swift # SwiftUI @Environment key for LocaleManager
└── Resources/
    ├── Assets.xcassets                # App icons, color assets
    ├── Fonts/                         # Geist Mono .otf files
    └── Localizable.xcstrings          # i18n strings (zh-Hans, en)

DayRingTests/
├── Theme/
│   └── ColorThemeTests.swift         # Theme system tests
├── Models/
│   ├── AlarmTests.swift              # Alarm model + shouldRing logic tests
│   └── AlarmFullFlowTests.swift      # Full-flow: create → save → shouldRing for all repeat modes
├── Services/
│   ├── AlarmSchedulerTests.swift     # Alarm scheduling tests
│   ├── ChineseCalendarServiceTests.swift  # Lunar date + holiday tests
│   └── LocaleManagerTests.swift      # i18n bundle loading + string lookup tests
└── ViewModels/
    ├── AlarmEditViewModelTests.swift  # Alarm edit form tests
    ├── CalendarViewModelTests.swift   # Calendar navigation tests
    ├── SettingsViewModelTests.swift   # Settings persistence tests
    └── TimeDisplayTests.swift        # 12h/24h format display tests
```

## Code Style Guidelines

### Swift

- **Swift 6** strict concurrency — no `@unchecked Sendable` workarounds
- **Never** use `as Any`, force unwrap (`!`) unless guaranteed safe, or suppress warnings
- **Prefer** `guard let` over `if let` for early returns
- **Use** `#expect()` (Swift Testing) over `XCTAssert` (XCTest)

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Types / Protocols | PascalCase | `AlarmListViewModel`, `RepeatMode` |
| Functions / Properties | camelCase | `shouldRing(on:)`, `timeString` |
| Enum cases | camelCase | `.biweekly`, `.rotating` |
| Constants | camelCase or SCREAMING_SNAKE | `Weekday.workdays` |
| Files | PascalCase matching type | `AlarmCardView.swift` |
| Test suites | PascalCase + "Tests" | `AlarmTests` |

### SwiftUI Patterns

```swift
// View with ViewModel
struct AlarmListView: View {
    @Query(sort: \Alarm.hour) private var alarms: [Alarm]
    @State private var viewModel = AlarmListViewModel()

    var body: some View {
        NavigationStack {
            // ...
        }
    }
}

// Adaptive color usage — always use theme extensions
Text("Title")
    .foregroundStyle(.fgPrimary)    // ✅ Uses Color.fgPrimary (adaptive)
    .foregroundStyle(.black)         // ❌ Hardcoded — breaks dark mode
```

### SwiftData Patterns

```swift
@Model
final class Alarm {
    var id: UUID
    var hour: Int       // 0-23
    var minute: Int     // 0-59
    // ...
}

// Querying in views
@Query(sort: \Alarm.hour, order: .forward) private var alarms: [Alarm]
@Environment(\.modelContext) private var modelContext
```

### Observation Framework

```swift
// Use @Observable (not ObservableObject)
@Observable
final class AlarmListViewModel {
    var alarms: [Alarm] = []
    var showingEditor = false
}

// In views, use @State for owned ViewModels
@State private var viewModel = AlarmListViewModel()
```

### Localization (i18n)

All user-facing strings go through `LocaleManager` for runtime locale switching without app restart.

```swift
// In Views — use @Environment
@Environment(\.localeManager) private var locale

Text(locale.localizedString("闹钟"))    // ✅ Localized at runtime
Text("闹钟")                            // ❌ Hardcoded — won't switch

// In Models / ViewModels — use singleton
LocaleManager.shared.localizedString("设置")
```

Supported locales: `.system` (follows device), `.zhHans`, `.en`.  
String keys are Chinese (the source language). Translations live in `Localizable.xcstrings`.

## Architecture

### MVVM Flow

```
View (SwiftUI)
  ↕ @State / @Binding / @Query
ViewModel (@Observable)
  ↕ method calls
Model (@Model / enum / struct)
  ↕ persistence
SwiftData Container
```

### Three-Tab Structure

| Tab | Icon | View |
|-----|------|------|
| 闹钟 | `alarm.fill` | `AlarmListView` |
| 日历 | `calendar` | `CalendarTabView` |
| 设置 | `gearshape.fill` | `SettingsView` |

### Modal Presentations

- **Alarm Edit**: `.sheet()` from alarm list (new) or card tap (edit)
- **Day Detail**: `.sheet()` from calendar cell tap
- **Repeat Details**: `NavigationLink` push from Repeat Mode Picker

### Alarm Decision Logic

Priority order for `shouldRing(on:)`:
1. Manual override (`manualOverrides[dateKey]`) — highest priority
2. Skip next date (`skipNextDate`)
3. Repeat pattern match
4. Holiday skip (if `skipHolidays` enabled)
5. Makeup day ring (if `ringOnMakeupDays` enabled)

## Testing

### Framework

- **Swift Testing** (`import Testing`) — not XCTest
- **Decorators**: `@Test("description")`, `@Suite("Name")`
- **Assertions**: `#expect(condition)`, `Issue.record("message")`

### Test Organization

```swift
@Suite("Alarm Model Tests")
struct AlarmTests {

    @Test("Default alarm is 07:00 no repeat")
    func defaultAlarm() {
        let alarm = Alarm()
        #expect(alarm.hour == 7)
        #expect(alarm.minute == 0)
    }

    @Test("Holiday skip logic")
    func holidaySkip() {
        let alarm = Alarm(skipHolidays: true)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1))!
        #expect(alarm.shouldRing(on: date, holidays: ["2026-10-01"], makeupDays: []) == false)
    }
}
```

### Required Test Coverage

| Area | Tests Required |
|------|---------------|
| Alarm model | Default init, time formatting, repeat pattern matching, holiday skip, manual override, skip-next |
| Full flow | Create → save → load round-trip → shouldRing for every repeat mode (none, daily, weekly, biweekly, rotating, custom) |
| Theme system | Hex init, adaptive color existence, all tokens defined |
| Chinese calendar | Lunar date strings for known dates |
| Holiday provider | Holiday/makeup day lookup, regular day returns false |
| Time display | 24h hides AM/PM, 12h shows AM/PM, hour12 conversion |
| Biweekly | All 7 days available, weekend selection persists |
| LocaleManager | Bundle loading per locale, string lookup, locale switching, fallback, Codable round-trip |
| Alarm scheduler | Schedule/cancel operations, next-ring calculation |
| Alarm edit VM | Form state, save/load, validation |
| Calendar VM | Month navigation, title formatting |
| Settings VM | Default values, display name generation |

### Running Tests

Always run the full test suite after completing a task:

```bash
xcodebuild test -scheme DayRing -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | xcpretty
```

A task is **not complete** until all tests pass.

## Design Reference

- **Design file**: `/Users/theon/Downloads/untitled.pen` (Pencil format, 20 screens)
- **Design system**: `DESIGN.md` — full token reference, component specs, do's and don'ts
- **Implementation plan**: `docs/plans/2026-04-09-dayring-implementation.md` — 14 tasks with code

### Key Design Rules

1. **Liquid Glass**: System tab/nav bars only. No glass on 42 calendar cells. No glass-on-glass stacking.
2. **Colors**: Always use adaptive `Color(light:dark:)` — never hardcode hex values in views.
3. **Fonts**: `Inter` for UI, `Geist Mono` for time display — never use system default for clocks.
4. **Time Format**: 24h mode (default) shows no AM/PM anywhere. Only 12h mode shows AM/PM.
5. **Biweekly**: Shows Mon–Sun (7 days), not Mon–Fri (5 days).

## Git Conventions

Commit messages follow Conventional Commits:

| Prefix | Usage |
|--------|-------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `test:` | Test additions or fixes |
| `chore:` | Tooling, project setup, dependencies |
| `docs:` | Documentation only |
| `refactor:` | Code change with no behavior change |

## Environment

- **Xcode**: 26.4 (Build 17E192)
- **iOS Deployment Target**: 26.0
- **Swift**: 6
- **Simulator**: iPhone 16 Pro

## Common Tasks

### Adding a new view

1. Create file in appropriate `Views/` subdirectory
2. Write SwiftUI preview for visual verification
3. Wire into navigation (NavigationLink, .sheet, or Tab)
4. Add to implementation plan if not already listed

### Adding a new model property

1. Add property to `@Model` class
2. Update `init()` with default value
3. Write test for the new property
4. Update any ViewModels that need the property
5. Update views to display/edit the property

### Modifying alarm scheduling logic

1. Write failing test in `AlarmTests` that demonstrates expected behavior
2. Modify `shouldRing(on:holidays:makeupDays:)` or `matchesRepeatPattern(_:)`
3. Verify all existing tests still pass
4. Update `AlarmScheduler` if the scheduling trigger changes
