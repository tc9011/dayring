import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("设置")
                    .foregroundStyle(Color.fgSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.bgPrimary.ignoresSafeArea()
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
}
