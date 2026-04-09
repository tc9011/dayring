import SwiftUI

struct TimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    var is24HourFormat: Bool = true

    private var hour12: Int {
        let h = hour % 12
        return h == 0 ? 12 : h
    }

    private var isAM: Bool {
        hour < 12
    }

    private func setHour12(_ h12: Int, am: Bool) {
        var h24: Int
        if h12 == 12 {
            h24 = am ? 0 : 12
        } else {
            h24 = am ? h12 : h12 + 12
        }
        hour = h24
    }

    var body: some View {
        if is24HourFormat {
            picker24h
        } else {
            picker12h
        }
    }

    private var picker24h: some View {
        HStack(spacing: 0) {
            Picker("", selection: $hour) {
                ForEach(0..<24, id: \.self) { h in
                    Text(String(format: "%02d", h))
                        .font(.custom("GeistMono-Regular", size: 28))
                        .tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 200)
            .clipped()

            Text(":")
                .font(.custom("GeistMono-Regular", size: 32))
                .foregroundStyle(Color.accent)

            Picker("", selection: $minute) {
                ForEach(0..<60, id: \.self) { m in
                    Text(String(format: "%02d", m))
                        .font(.custom("GeistMono-Regular", size: 28))
                        .tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 200)
            .clipped()
        }
        .padding(.vertical, 16)
    }

    private var picker12h: some View {
        HStack(spacing: 0) {
            Picker("", selection: Binding(
                get: { hour12 },
                set: { setHour12($0, am: isAM) }
            )) {
                ForEach(1...12, id: \.self) { h in
                    Text(String(format: "%d", h))
                        .font(.custom("GeistMono-Regular", size: 28))
                        .tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 70, height: 200)
            .clipped()

            Text(":")
                .font(.custom("GeistMono-Regular", size: 32))
                .foregroundStyle(Color.accent)

            Picker("", selection: $minute) {
                ForEach(0..<60, id: \.self) { m in
                    Text(String(format: "%02d", m))
                        .font(.custom("GeistMono-Regular", size: 28))
                        .tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 70, height: 200)
            .clipped()

            Picker("", selection: Binding(
                get: { isAM },
                set: { setHour12(hour12, am: $0) }
            )) {
                Text("AM").tag(true)
                Text("PM").tag(false)
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 200)
            .clipped()
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    TimePickerView(hour: .constant(7), minute: .constant(0))
}
