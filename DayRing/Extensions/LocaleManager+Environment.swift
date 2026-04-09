import SwiftUI

private struct LocaleManagerKey: EnvironmentKey {
    static let defaultValue = LocaleManager.shared
}

extension EnvironmentValues {
    var localeManager: LocaleManager {
        get { self[LocaleManagerKey.self] }
        set { self[LocaleManagerKey.self] = newValue }
    }
}
