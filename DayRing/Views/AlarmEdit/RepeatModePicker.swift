import SwiftUI

struct RepeatModePicker: View {
    @Binding var repeatMode: RepeatMode

    var body: some View {
        List {
            Section {
                modeRow(
                    icon: "repeat",
                    iconColor: Color.iosGreen,
                    name: "每天",
                    subtitle: "每天都响铃",
                    isSelected: isDaily,
                    destination: { selectDaily() }
                )

                NavigationLink {
                    WeeklyDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "calendar",
                        iconColor: Color.accent,
                        name: "每周",
                        subtitle: "选择每周哪些天响铃",
                        isSelected: isWeekly
                    )
                }

                NavigationLink {
                    BiweeklyDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "calendar.badge.clock",
                        iconColor: Color.iosIndigo,
                        name: "大小周",
                        subtitle: "两周为一个循环",
                        isSelected: isBiweekly
                    )
                }

                NavigationLink {
                    RotatingDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "arrow.triangle.2.circlepath",
                        iconColor: Color.iosPink,
                        name: "轮休",
                        subtitle: "响铃天数 + 间隔天数循环",
                        isSelected: isRotating
                    )
                }

                NavigationLink {
                    CustomCalendarDetailView(repeatMode: $repeatMode)
                } label: {
                    modeRowContent(
                        icon: "slider.horizontal.3",
                        iconColor: Color.iosBlue,
                        name: "自定义",
                        subtitle: "通过日历自由配置响铃日",
                        isSelected: isCustom
                    )
                }
            }
        }
        .navigationTitle("重复")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Selection state

    private var isDaily: Bool {
        if case .daily = repeatMode { return true }
        return false
    }

    private var isWeekly: Bool {
        if case .weekly = repeatMode { return true }
        return false
    }

    private var isBiweekly: Bool {
        if case .biweekly = repeatMode { return true }
        return false
    }

    private var isRotating: Bool {
        if case .rotating = repeatMode { return true }
        return false
    }

    private var isCustom: Bool {
        if case .custom = repeatMode { return true }
        return false
    }

    private func selectDaily() {
        repeatMode = .daily
    }

    // MARK: - Row views

    private func modeRow(
        icon: String, iconColor: Color, name: String,
        subtitle: String, isSelected: Bool, destination: @escaping () -> Void
    ) -> some View {
        Button(action: destination) {
            modeRowContent(icon: icon, iconColor: iconColor, name: name, subtitle: subtitle, isSelected: isSelected)
        }
    }

    private func modeRowContent(
        icon: String, iconColor: Color, name: String,
        subtitle: String, isSelected: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(iconColor, in: RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.bodyText()).foregroundStyle(Color.fgPrimary)
                Text(subtitle).font(.smallCaption()).foregroundStyle(Color.fgSecondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.accent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RepeatModePicker(repeatMode: .constant(.weekly(days: Weekday.workdays)))
    }
}
