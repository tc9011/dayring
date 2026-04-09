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
        .background {
            Color.bgPrimary.ignoresSafeArea()
        }
        .tint(Color.accent)
    }
}

#Preview {
    ContentView()
}
