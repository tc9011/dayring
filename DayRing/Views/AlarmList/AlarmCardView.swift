import SwiftUI

struct AlarmCardView: View {
    @Bindable var alarm: Alarm
    @Environment(\.localeManager) private var locale
    let statusText: String
    let statusColor: AlarmListViewModel.StatusColor
    let is24HourFormat: Bool
    let isSkipActive: Bool
    let onSkipNext: () -> Void
    var onTap: () -> Void = {}

    private var repeatSummary: String {
        let mode = alarm.repeatModeDisplayName
        let detail = alarm.repeatDetailText
        let repeatPart = (mode == detail) ? mode : "\(mode) · \(detail)"
        if !alarm.label.isEmpty {
            return "\(alarm.label)  |  \(repeatPart)"
        }
        return repeatPart
    }

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
                .buttonStyle(.borderless)
                Spacer()
                Toggle("", isOn: $alarm.isEnabled)
                    .labelsHidden()
                    .tint(Color.iosGreen)
            }

            Button(action: onTap) {
                HStack {
                    Text(repeatSummary)
                        .font(.caption())
                        .foregroundStyle(Color.fgSecondary)
                    Spacer()
                }
            }
            .buttonStyle(.borderless)

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
                .buttonStyle(.borderless)
                Spacer()
                if !alarm.repeatMode.isNone {
                    Button {
                        onSkipNext()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isSkipActive ? "bell.fill" : "forward.fill")
                                .font(.system(size: 10))
                            Text(locale.localizedString(isSkipActive ? "继续响铃" : "跳过下次"))
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(isSkipActive ? Color.accent : Color.fgSecondary)
                        .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .contentShape(Capsule())
                    .background(
                        (isSkipActive ? Color.accent : Color.fgSecondary).opacity(0.12),
                        in: Capsule()
                    )
                }
                .buttonStyle(.borderless)
                .contentShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
        .onChange(of: alarm.isEnabled) { _, isEnabled in
            if isEnabled && alarm.repeatMode.isNone {
                if let scheduled = alarm.scheduledDate,
                   Calendar.current.startOfDay(for: scheduled) < Calendar.current.startOfDay(for: Date()) {
                    alarm.computeScheduledDate()
                }
            }
        }
    }
}
