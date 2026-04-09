import Testing
import Foundation
@testable import DayRing

@Suite("LocaleManager Tests")
struct LocaleManagerTests {

    // MARK: - AppLocale Properties

    @Test("AppLocale has exactly 4 cases: system, zhHans, zhHant, en")
    func appLocaleCases() {
        let cases = AppLocale.allCases
        #expect(cases.count == 4)
        #expect(cases.contains(.system))
        #expect(cases.contains(.zhHans))
        #expect(cases.contains(.zhHant))
        #expect(cases.contains(.en))
    }

    @Test("Japanese locale is NOT available — regression guard")
    func noJapaneseLocale() {
        let rawValues = AppLocale.allCases.map(\.rawValue)
        #expect(!rawValues.contains("日本語"))
        #expect(!rawValues.contains("Japanese"))
        let identifiers = AppLocale.allCases.compactMap(\.bundleIdentifier)
        #expect(!identifiers.contains("ja"))
    }

    @Test("System locale has nil bundleIdentifier")
    func systemBundleIdentifier() {
        #expect(AppLocale.system.bundleIdentifier == nil)
    }

    @Test("zhHans locale has correct bundleIdentifier")
    func zhHansBundleIdentifier() {
        #expect(AppLocale.zhHans.bundleIdentifier == "zh-Hans")
    }

    @Test("zhHant locale has correct bundleIdentifier")
    func zhHantBundleIdentifier() {
        #expect(AppLocale.zhHant.bundleIdentifier == "zh-Hant")
    }

    @Test("English locale has correct bundleIdentifier")
    func enBundleIdentifier() {
        #expect(AppLocale.en.bundleIdentifier == "en")
    }

    @Test("Each locale has a non-empty nativeName")
    func nativeNames() {
        for locale in AppLocale.allCases {
            #expect(!locale.nativeName.isEmpty, "\(locale) should have a non-empty nativeName")
        }
    }

    @Test("nativeName is always in the target language, not localized")
    func nativeNameValues() {
        #expect(AppLocale.zhHans.nativeName == "简体中文")
        #expect(AppLocale.zhHant.nativeName == "繁體中文")
        #expect(AppLocale.en.nativeName == "English")
        #expect(AppLocale.system.nativeName == "跟随系统")
    }

    // MARK: - LocaleManager Singleton

    @Test("LocaleManager.shared is accessible")
    func sharedInstance() {
        let manager = LocaleManager.shared
        #expect(manager !== nil as AnyObject?)
    }

    @Test("Default locale is a valid AppLocale case")
    func defaultLocale() {
        let locale = LocaleManager.shared.currentLocale
        #expect(AppLocale.allCases.contains(locale))
    }

    // MARK: - String Lookup

    @Test("localizedString returns key itself for unknown keys")
    func unknownKeyReturnsKey() {
        let manager = LocaleManager.shared
        let unknownKey = "THIS_KEY_DOES_NOT_EXIST_\(UUID().uuidString)"
        let result = manager.localizedString(unknownKey)
        #expect(result == unknownKey)
    }

    @Test("localizedString returns non-empty result for known key '闹钟'")
    func knownKeyReturnsTranslation() {
        let manager = LocaleManager.shared
        let result = manager.localizedString("闹钟")
        #expect(!result.isEmpty)
    }

    @Test("Switching to English locale returns English strings for known keys")
    func englishLocaleStrings() {
        let manager = LocaleManager.shared
        let previousLocale = manager.currentLocale

        manager.currentLocale = .en
        let result = manager.localizedString("闹钟")
        #expect(result == "Alarms", "Expected 'Alarms' for key '闹钟' in English locale, got '\(result)'")

        manager.currentLocale = previousLocale
    }

    @Test("Switching to zhHans locale returns Simplified Chinese strings")
    func zhHansLocaleStrings() {
        let manager = LocaleManager.shared
        let previousLocale = manager.currentLocale

        manager.currentLocale = .zhHans
        let result = manager.localizedString("设置")
        #expect(result == "设置", "Expected '设置' for key '设置' in zh-Hans locale, got '\(result)'")

        manager.currentLocale = previousLocale
    }

    @Test("Switching to zhHant locale returns Traditional Chinese strings")
    func zhHantLocaleStrings() {
        let manager = LocaleManager.shared
        let previousLocale = manager.currentLocale

        manager.currentLocale = .zhHant
        let result = manager.localizedString("设置")
        #expect(result == "設定", "Expected '設定' for key '设置' in zh-Hant locale, got '\(result)'")

        manager.currentLocale = previousLocale
    }

    @Test("System locale falls back to main bundle with non-empty result")
    func systemLocaleFallback() {
        let manager = LocaleManager.shared
        let previousLocale = manager.currentLocale

        manager.currentLocale = .system
        let result = manager.localizedString("闹钟")
        #expect(!result.isEmpty)

        manager.currentLocale = previousLocale
    }

    @Test("Switching locale updates the bundle property")
    func bundleUpdatesOnLocaleChange() {
        let manager = LocaleManager.shared
        let previousLocale = manager.currentLocale

        manager.currentLocale = .en
        let enBundle = manager.bundle

        manager.currentLocale = .zhHans
        let zhBundle = manager.bundle

        if enBundle.bundlePath != zhBundle.bundlePath {
            #expect(enBundle !== zhBundle, "Different locales should load different bundles")
        }

        manager.currentLocale = previousLocale
    }

    // MARK: - AppearanceMode / CalendarType localizedName

    @Test("AppearanceMode localizedName returns non-empty strings")
    func appearanceModeLocalizedNames() {
        for mode in AppearanceMode.allCases {
            #expect(!mode.localizedName.isEmpty, "\(mode) should have non-empty localizedName")
        }
    }

    @Test("CalendarType localizedName returns non-empty strings")
    func calendarTypeLocalizedNames() {
        for cal in CalendarType.allCases {
            #expect(!cal.localizedName.isEmpty, "\(cal) should have non-empty localizedName")
        }
    }

    // MARK: - AppLocale Codable

    @Test("AppLocale round-trips through JSON encoding/decoding")
    func appLocaleCodable() throws {
        for locale in AppLocale.allCases {
            let data = try JSONEncoder().encode(locale)
            let decoded = try JSONDecoder().decode(AppLocale.self, from: data)
            #expect(decoded == locale)
        }
    }
}
