import SwiftUI

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: $hour) {
                ForEach(0..<24, id: \.self) { h in
                    Text(String(format: "%02d", h))
                        .font(.timeLarge())
                        .tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 200)
            .clipped()

            Text(":")
                .font(.timeLarge())
                .foregroundStyle(Color.accent)

            Picker("", selection: $minute) {
                ForEach(0..<60, id: \.self) { m in
                    Text(String(format: "%02d", m))
                        .font(.timeLarge())
                        .tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 200)
            .clipped()
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    TimePickerView(hour: .constant(7), minute: .constant(0))
}
