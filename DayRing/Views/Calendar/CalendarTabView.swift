import SwiftUI

struct CalendarTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("日历视图")
                    .foregroundStyle(Color.fgSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgPrimary)
            .navigationTitle("日历")
        }
    }
}

#Preview {
    CalendarTabView()
}
