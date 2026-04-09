import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("闹钟", systemImage: "alarm.fill", value: 0) {
                NavigationStack {
                    Text("闹钟列表")
                        .navigationTitle("闹钟")
                }
            }
            Tab("日历", systemImage: "calendar", value: 1) {
                NavigationStack {
                    Text("日历视图")
                        .navigationTitle("日历")
                }
            }
            Tab("设置", systemImage: "gearshape.fill", value: 2) {
                NavigationStack {
                    Text("设置")
                        .navigationTitle("设置")
                }
            }
        }
        .tint(.accent)
    }
}

#Preview {
    ContentView()
}
