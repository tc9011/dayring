import SwiftUI

struct RotatingDetailView: View {
    @Binding var repeatMode: RepeatMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.localeManager) private var locale
    @State private var startDate = Date()
    @State private var ringDays = 4
    @State private var gapDays = 2

    var body: some View {
        VStack(spacing: 20) {
            Text(locale.localizedString("设置轮休周期：响铃天数 + 间隔天数为一个循环，间隔期间不响铃。"))
                .font(.system(size: 15))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                DatePicker(locale.localizedString("开始日期"), selection: $startDate, displayedComponents: .date)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                Color.bgTertiary.frame(height: 0.5).padding(.leading, 16)
                stepperRow(locale.localizedString("响铃天数"), value: $ringDays, range: 1...30)
                Color.bgTertiary.frame(height: 0.5).padding(.leading, 16)
                stepperRow(locale.localizedString("间隔天数"), value: $gapDays, range: 1...30)
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            cyclePreview

            let ringLabel = locale.localizedString("响铃")
            let gapLabel = locale.localizedString("间隔")
            let dayLabel = locale.localizedString("天")
            let part1 = ringLabel + " \(ringDays) " + dayLabel
            let part2 = " → " + gapLabel + " \(gapDays) " + dayLabel
            let part3 = " → " + ringLabel + " \(ringDays) " + dayLabel + " → ···"
            Text(part1 + part2 + part3)
                .font(.caption())
                .foregroundStyle(Color.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle(locale.localizedString("轮休"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(locale.localizedString("完成")) {
                    repeatMode = .rotating(startDate: startDate, ringDays: ringDays, gapDays: gapDays)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
            }
        }
        .onAppear {
            if case .rotating(let sd, let rd, let gd) = repeatMode {
                startDate = sd; ringDays = rd; gapDays = gd
            }
        }
    }

    private func stepperRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label).font(.bodyText())
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: range)
                .font(.timeSmall())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var cyclePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(locale.localizedString("循环预览"))
                .font(.system(size: 15, weight: .semibold))

            HStack(spacing: 4) {
                let cycle = ringDays + gapDays
                ForEach(0..<min(cycle + 1, 10), id: \.self) { i in
                    let isRing = i < ringDays || (i >= cycle && i < cycle + ringDays)
                    Text("\(i % cycle + 1)")
                        .font(.system(size: 13, weight: isRing ? .semibold : .medium))
                        .foregroundStyle(isRing ? .white : Color.fgSecondary)
                        .frame(width: 36, height: 36)
                        .background(
                            isRing ? Color.accent : Color.bgTertiary,
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                }
                Text("···")
                    .foregroundStyle(Color.fgTertiary)
            }

            HStack(spacing: 16) {
                legendItem(color: Color.accent, text: locale.localizedString("响铃"))
                legendItem(color: Color.bgTertiary, text: locale.localizedString("间隔（不响铃）"))
            }
        }
        .padding(16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(text).font(.smallCaption()).foregroundStyle(Color.fgSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        RotatingDetailView(repeatMode: .constant(.rotating(startDate: Date(), ringDays: 4, gapDays: 2)))
    }
}
