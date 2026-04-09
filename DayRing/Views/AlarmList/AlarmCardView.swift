import SwiftUI

struct AlarmCardView: View {
    @Bindable var alarm: Alarm
    @Environment(\.localeManager) private var locale
    let statusText: String
    let statusColor: AlarmListViewModel.StatusColor
    let is24HourFormat: Bool
    let onSkipNext: () -> Void
    var onTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: onTap) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(is24HourFormat ? alarm.timeString : "\(String(format: "%02d:%02d", alarm.hour12, alarm.minute))")
                            .font(.timeCard())
                            .foregroundStyle(Color.fgPrimary)
                        if !is24HourFormat {
                            Text(alarm.amPmString)
                                .font(.smallCaption())
                                .fontWeight(.medium)
                                .foregroundStyle(Color.fgSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Toggle("", isOn: $alarm.isEnabled)
                    .labelsHidden()
                    .tint(Color.iosGreen)
            }

            Button(action: onTap) {
                HStack {
                    if !alarm.label.isEmpty {
                        Text("\(alarm.label)  |  \(alarm.repeatModeDisplayName) · \(alarm.repeatDetailText)")
                            .font(.caption())
                            .foregroundStyle(Color.fgSecondary)
                    } else {
                        Text("\(alarm.repeatModeDisplayName) · \(alarm.repeatDetailText)")
                            .font(.caption())
                            .foregroundStyle(Color.fgSecondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            HStack {
                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor.color)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.system(size: 11))
                            .foregroundStyle(statusColor.color)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: onSkipNext) {
                    HStack(spacing: 4) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 10))
                        Text(locale.localizedString("跳过下次"))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.fgSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .glassEffect(.regular, in: Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
    }
}
