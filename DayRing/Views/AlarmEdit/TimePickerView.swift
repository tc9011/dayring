import SwiftUI

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(String(format: "%02d", hour))
                .font(.timeLarge())
                .foregroundStyle(Color.fgPrimary)
            Text(":")
                .font(.timeLarge())
                .foregroundStyle(Color.accent)
            Text(String(format: "%02d", minute))
                .font(.timeLarge())
                .foregroundStyle(Color.fgPrimary)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    TimePickerView(hour: .constant(7), minute: .constant(0))
}
