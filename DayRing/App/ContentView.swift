import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @Query private var allSettings: [AppSettings]
    @Environment(\.localeManager) private var locale

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(locale.localizedString("闹钟"), systemImage: "alarm.fill", value: 0) {
                AlarmListView()
            }
            Tab(locale.localizedString("日历"), systemImage: "calendar", value: 1) {
                CalendarTabView()
            }
            Tab(locale.localizedString("设置"), systemImage: "gearshape.fill", value: 2) {
                SettingsView()
            }
        }
        .background {
            Color.bgPrimary.ignoresSafeArea()
        }
        .tint(Color.accent)
        .preferredColorScheme(allSettings.first?.appearanceMode.colorScheme)
    }
}

#Preview {
    ContentView()
}
