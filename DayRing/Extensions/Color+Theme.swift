import SwiftUI

extension Color {

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

    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }

    // MARK: - Brand

    static let accent = Color(light: "FF9500", dark: "FF9F0A")
    static let todayBg = Color(light: "20FF9500", dark: "30FF9F0A")

    // MARK: - Backgrounds

    static let bgPrimary = Color(light: "F2F2F7", dark: "000000")
    static let bgSecondary = Color(light: "FFFFFF", dark: "1C1C1E")
    static let bgTertiary = Color(light: "E5E5EA", dark: "2C2C2E")

    // MARK: - Text

    static let fgPrimary = Color(light: "000000", dark: "FFFFFF")
    static let fgSecondary = Color(light: "8E8E93", dark: "98989D")
    static let fgTertiary = Color(light: "C7C7CC", dark: "48484A")

    // MARK: - Semantic

    static let holidayRed = Color(light: "FF3B30", dark: "FF453A")
    static let holidayRedBg = Color(light: "FFEBEE", dark: "3A1215")
    static let makeupPurple = Color(light: "AF52DE", dark: "BF5AF2")
    static let makeupPurpleBg = Color(light: "F3E5F5", dark: "2A1230")
    static let iosGreen = Color(light: "34C759", dark: "30D158")
    static let separator = Color(light: "E5E5EA", dark: "38383A")

    // MARK: - Glass

    static let glassBg = Color(light: "CCFFFFFF", dark: "CC1C1C1E")
    static let glassBorder = Color(light: "66FFFFFF", dark: "1AFFFFFF")

    // MARK: - System Accent (non-adaptive)

    static let iosBlue = Color(hex: "007AFF")
    static let iosIndigo = Color(hex: "5856D6")
    static let iosPink = Color(hex: "FF2D55")
    static let iosTeal = Color(light: "30B0C7", dark: "40C8E0")
    static let iosGray = Color(hex: "8E8E93")
    static let settingsIconBlack = Color(light: "1C1C1E", dark: "48484A")
}
