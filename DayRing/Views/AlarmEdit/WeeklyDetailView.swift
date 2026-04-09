import SwiftUI

struct WeeklyDetailView: View {
    @Binding var repeatMode: RepeatMode
    @Environment(\.localeManager) private var locale
    @State private var selectedDays: Set<Weekday> = Weekday.allDays

    var body: some View {
        VStack(spacing: 20) {
            Text(locale.localizedString("选择每周哪些天响铃"))
                .font(.system(size: 15))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            WeekdaySelectorView(selectedDays: $selectedDays)

            Text(locale.localizedString("默认全选。点击取消选择对应的日期。"))
                .font(.caption())
                .foregroundStyle(Color.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle(locale.localizedString("每周重复"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(locale.localizedString("完成")) {
                    repeatMode = .weekly(days: selectedDays)
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
            }
        }
        .onAppear {
            if case .weekly(let days) = repeatMode {
                selectedDays = days
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyDetailView(repeatMode: .constant(.weekly(days: Weekday.workdays)))
    }
}
