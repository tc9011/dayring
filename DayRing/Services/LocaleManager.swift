import Foundation
import Observation

@Observable
final class LocaleManager: @unchecked Sendable {
    static let shared = LocaleManager()

    var currentLocale: AppLocale = .system {
        didSet { updateBundle() }
    }

    private(set) var bundle: Bundle = .main

    private init() {
        updateBundle()
    }

    private func updateBundle() {
        guard let identifier = currentLocale.bundleIdentifier,
              let path = Bundle.main.path(forResource: identifier, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            bundle = .main
            return
        }
        bundle = localizedBundle
    }

    func localizedString(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
