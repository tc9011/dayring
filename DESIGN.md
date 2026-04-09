# DayRing Design System

## Overview

DayRing (该起了) is a warm, functional design system for an iOS smart calendar alarm app. Built on iOS 26's Liquid Glass design language, it pairs a vibrant orange accent with neutral surfaces to create an interface that feels native, calm, and purposeful. The visual language prioritizes clarity over decoration -- time displays use monospace type for precision, calendar cells use subtle color-coding for at-a-glance status, and interactions feel lightweight with minimal shadows and glass-only where the system provides it. Every element serves the alarm-calendar workflow: set it, see it, trust it.

---

## Colors

All colors are adaptive (Light / Dark). Use `Color(light:dark:)` in SwiftUI -- never hardcode hex in views.

### Brand

- **Accent** (#FF9500 / #FF9F0A): Primary orange -- FAB, selected states, active tab, time colon, alarm indicators
- **Today Background** (#FF950020 / #FF9F0A30): Today cell highlight in calendar (20% opacity)

### Surfaces

- **Background** (#F2F2F7 / #000000): App background
- **Background Secondary** (#FFFFFF / #1C1C1E): Cards, grouped sections, sheet backgrounds
- **Background Tertiary** (#E5E5EA / #2C2C2E): Inactive circles, separators, unselected weekday buttons

### Text

- **Foreground Primary** (#000000 / #FFFFFF): Titles, time display, primary labels
- **Foreground Secondary** (#8E8E93 / #98989D): Descriptions, secondary labels, AM/PM
- **Foreground Tertiary** (#C7C7CC / #48484A): Chevrons, hint text, fine print

### Semantic

- **Holiday Red** (#FF3B30 / #FF453A): Holiday text, "休" badge
- **Holiday Red Background** (#FFEBEE / #3A1215): Holiday calendar cell fill
- **Makeup Purple** (#AF52DE / #BF5AF2): Makeup workday text, "班" badge
- **Makeup Purple Background** (#F3E5F5 / #2A1230): Makeup workday calendar cell fill
- **iOS Green** (#34C759 / #30D158): Toggle on state, "next ring" status dot
- **Separator** (#E5E5EA / #38383A): Divider lines in lists and sections

### Glass

- **Glass Background** (#FFFFFFCC / #1C1C1ECC): Glass containers (80% opacity)
- **Glass Border** (#FFFFFF66 / #FFFFFF1A): Glass container borders (40% / 10% opacity)

### System Accent (non-adaptive)

- **iOS Blue** (#007AFF): Custom calendar mode icon
- **iOS Indigo** (#5856D6): Biweekly mode icon
- **iOS Pink** (#FF2D55): Rotating mode icon

---

## Typography

Two font families: **Inter** for all UI text (system font on iOS 26), **Geist Mono** for time display (bundled from vercel.com/font).

- **Time Large**: Geist Mono Light, 72pt -- alarm edit time picker
- **Time Medium**: Geist Mono Light, 42pt -- large preview contexts
- **Time Card**: Geist Mono Light, 36pt -- alarm list card time
- **Time Small**: Geist Mono Regular, 20pt -- stepper values
- **Time Alarm Indicator**: Geist Mono Medium, 7pt -- calendar cell alarm times
- **Nav Title**: Inter Bold, 34pt -- navigation large titles
- **Sheet Title**: Inter Semibold, 17pt -- sheet/inline navigation titles
- **Body**: Inter Regular, 16pt -- settings rows, body text
- **Caption**: Inter Regular, 13pt -- section labels, descriptions
- **Small Caption**: Inter Regular/Medium, 12pt -- AM/PM labels, subtitles
- **Tiny Caption**: Inter Regular, 9pt -- fine print, lunar date text

---

## Spacing

Base unit: **4pt**

- **xs**: 4pt -- tight inner spacing
- **sm**: 8pt -- icon-to-text gaps, calendar grid row gap (2pt exception)
- **md**: 12pt -- card vertical spacing, inter-section gaps
- **lg**: 16pt -- card horizontal padding, section spacing, grid horizontal padding
- **xl**: 20pt -- screen horizontal padding, form content padding
- **xxl**: 24pt -- large section gaps in biweekly/rotating views

---

## Border Radius

- **sm** (7pt): Repeat mode icon backgrounds (30x30pt squares)
- **md** (8pt): Calendar day cells with colored backgrounds
- **lg** (12pt): Settings grouped sections, form group boxes
- **xl** (16pt): Alarm cards, biweekly week boxes, cycle preview cards
- **round** (Capsule): FAB button, weekday selector circles, "跳过下次" pill

---

## Elevation

- **FAB Shadow**: Accent at 30% opacity, 8pt blur radius, 4pt y-offset -- only elevated element in the app
- All other elements are flat. No drop shadows on cards, cells, or sections.

---

## Components

### Alarm Card

Container with Background Secondary fill, 16pt corner radius, 16pt horizontal / 14pt vertical padding. Three rows: time + toggle (top), label + repeat info (mid), status dot + skip button (bottom). Disabled state applies 0.5 opacity to entire card. Status dot is a 6pt circle colored by state: Green (will ring), Accent orange (holiday info), Holiday Red (won't ring), Foreground Secondary (disabled).

### FAB (Floating Action Button)

56x56pt circle, Accent fill, white "plus" SF Symbol at 24pt medium weight. Positioned bottom-right with 20pt edge insets. Only element with a shadow (see Elevation).

### Weekday Selector

Row of 7 circles with equal spacing. Weekly variant: 44pt circles, 8pt gap. Biweekly variant: 40pt circles, 6pt gap (fits Mon-Sun in container). Selected state: Accent fill, white text, semibold. Unselected: Background Tertiary fill, Foreground Secondary text, medium weight.

### Month Navigation Bar

Horizontal bar with Glass Background fill. Left/right chevron buttons are 30x30pt with Background Tertiary fill and 7pt corner radius. Month title is centered, Sheet Title weight.

### Calendar Day Cell

Vertically stacked: day number (16pt), lunar date (Tiny Caption, Foreground Secondary), alarm times (Time Alarm Indicator, Accent colored, one per line). Cell types: Regular (transparent bg), Today (Today Background fill), Holiday (Holiday Red Background fill, red text, "休" badge), Makeup (Makeup Purple Background fill, purple text, "班" badge), Other month (0.3 opacity). Column gap: 3pt. Row gap: 2pt. Background corner radius: 8pt.

### Toggle Row

Standard iOS Toggle with `.tint(.iosGreen)`. Label in Body font, left-aligned. Toggle right-aligned. Used in alarm edit smart calendar section and day detail override cards.

### Repeat Mode Row

30x30pt colored icon with 7pt radius + name (Body) + subtitle (Small Caption) + optional Accent checkmark for current selection. Five modes: Daily (Green), Weekly (Accent), Biweekly (Indigo), Rotating (Pink), Custom (Blue).

### Time Picker

Large Geist Mono Light display showing "HH : MM". Colon rendered in Accent color. In 24h mode (default), no AM/PM indicator. In 12h mode, AM/PM label appears below in Small Caption weight.

### Settings Section

iOS grouped list style with 12pt corner radius. Each row is Body font with Foreground Secondary value text and Foreground Tertiary chevron. Time format uses a segmented Picker with "12h" and "24h" options.

---

## Animations

### Card Toggle

Standard iOS toggle spring animation. No custom timing.

### Sheet Presentation

System `.sheet()` with default iOS 26 Liquid Glass drag handle. No custom transition.

### FAB Press

Default button press scale (system). No custom animation.

---

## Liquid Glass Rules

1. Tab bar and navigation bar use system Liquid Glass automatically in iOS 26.
2. Alarm cards MAY use `.glassEffect()` if performance testing confirms acceptability.
3. Calendar cells (42 per grid) MUST NOT use `.glassEffect()` -- severe render cost.
4. Glass on Glass is forbidden -- never stack a Liquid Glass element on top of another.

---

## Do's and Don'ts

1. Do use adaptive `Color(light:dark:)` for all colors -- never hardcode hex in views.
2. Do use Geist Mono for all time/clock displays -- never use system font for time.
3. Do use Inter (system) for all UI text -- never use Geist Mono for labels or descriptions.
4. Don't show AM/PM in 24h time format mode (the default). Only show AM/PM in 12h mode.
5. Do show all 7 days (Mon-Sun) in biweekly detail -- not just Mon-Fri.
6. Don't apply `.glassEffect()` to calendar grid cells (42 cells = performance problem).
7. Don't stack Glass on Glass -- no Liquid Glass elements on top of other Liquid Glass elements.
8. Do use the status dot color system consistently: Green = will ring, Orange = holiday info, Red = won't ring.
9. Do use 3pt column gap and 2pt row gap in the calendar grid to prevent colored cell backgrounds from merging.
10. Don't use shadows except on the FAB -- all other elements are flat.
11. Do check `AppSettings.timeFormat` before rendering any AM/PM indicator.
12. Do define accent color with BOTH Light (#FF9500) and Dark (#FF9F0A) values -- missing Light default causes black rendering.
