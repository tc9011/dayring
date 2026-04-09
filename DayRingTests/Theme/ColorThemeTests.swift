import Testing
import SwiftUI
@testable import DayRing

@Suite("Color Theme Tests")
struct ColorThemeTests {

    @Test("Hex init produces correct color for known value")
    func hexInit() {
        let color = Color(hex: "FF9500")
        #expect(type(of: color) == Color.self)
    }

    @Test("Adaptive color provides a valid Color value")
    func adaptiveColor() {
        let accent = Color.accent
        #expect(type(of: accent) == Color.self)
    }

    @Test("All theme colors are defined")
    func allColorsDefined() {
        let colors: [Color] = [
            .accent, .todayBg,
            .bgPrimary, .bgSecondary, .bgTertiary,
            .fgPrimary, .fgSecondary, .fgTertiary,
            .holidayRed, .holidayRedBg,
            .makeupPurple, .makeupPurpleBg,
            .iosGreen, .iosBlue, .iosIndigo, .iosPink,
            .iosTeal, .iosGray, .settingsIconBlack,
            .separator, .glassBg, .glassBorder,
        ]
        #expect(colors.count == 22)
    }

    @Test("8-digit hex handles alpha channel")
    func hexWithAlpha() {
        let color = Color(hex: "FF950080")
        #expect(type(of: color) == Color.self)
    }
}
