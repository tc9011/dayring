import SwiftUI

struct CalendarTabView: View {
    var body: some View {
        NavigationStack {
            Text("日历视图")
                .navigationTitle("日历")
        }
    }
}

#Preview {
    CalendarTabView()
}
