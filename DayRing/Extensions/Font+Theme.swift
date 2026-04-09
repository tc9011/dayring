import SwiftUI

extension Font {

    static func timeLarge() -> Font { .custom("GeistMono-Light", size: 72) }
    static func timeMedium() -> Font { .custom("GeistMono-Light", size: 42) }
    static func timeCard() -> Font { .custom("GeistMono-Light", size: 36) }
    static func timeSmall() -> Font { .custom("GeistMono-Regular", size: 20) }
    static func timeAlarmIndicator() -> Font { .custom("GeistMono-Medium", size: 7) }

    static func navTitle() -> Font { .system(size: 34, weight: .bold, design: .default) }
    static func sheetTitle() -> Font { .system(size: 17, weight: .semibold) }
    static func bodyText() -> Font { .system(size: 16) }
    static func caption() -> Font { .system(size: 13) }
    static func smallCaption() -> Font { .system(size: 12) }
    static func tinyCaption() -> Font { .system(size: 9) }
}
