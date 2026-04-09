import SwiftUI

struct NextAlarmBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.accent)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NextAlarmBanner(text: "下一个闹钟将在 7小时32分钟 后响铃")
}
