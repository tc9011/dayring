import SwiftUI
import SwiftData

struct AlarmEditSheet: View {
    let alarm: Alarm?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.localeManager) private var locale
    @Query private var allSettings: [AppSettings]
    @State private var viewModel = AlarmEditViewModel()

    private var settings: AppSettings {
        allSettings.first ?? AppSettings()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TimePickerView(
                        hour: $viewModel.hour,
                        minute: $viewModel.minute,
                        is24HourFormat: settings.timeFormat == .h24
                    )

                    VStack(spacing: 0) {
                        HStack {
                            Text(locale.localizedString("标签"))
                                .font(.bodyText())
                            Spacer()
                            TextField(locale.localizedString("无"), text: $viewModel.label)
                                .font(.bodyText())
                                .foregroundStyle(Color.fgSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        sectionDivider()
                        NavigationLink {
                            RepeatModePicker(repeatMode: $viewModel.repeatMode)
                        } label: {
                            settingsRowChevron(locale.localizedString("重复"), value: viewModel.repeatMode.displayName)
                        }
                        sectionDivider()
                        ringtoneRow
                        sectionDivider()
                        snoozeRow
                        sectionDivider()
                        advanceRow
                        sectionDivider()
                        if viewModel.repeatMode.isNone {
                            HStack {
                                Text(locale.localizedString("响铃后删除"))
                                    .font(.bodyText())
                                Spacer()
                                Toggle("", isOn: $viewModel.deleteAfterRing)
                                    .labelsHidden()
                                    .tint(Color.iosGreen)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(locale.localizedString("智能日历"))
                        .font(.caption())
                        .foregroundStyle(Color.fgSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        HStack {
                            Text(locale.localizedString("节假日跳过"))
                                .font(.bodyText())
                            Spacer()
                            Toggle("", isOn: $viewModel.skipHolidays)
                                .labelsHidden()
                                .tint(Color.iosGreen)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        sectionDivider()

                        HStack {
                            Text(locale.localizedString("补班日响铃"))
                                .font(.bodyText())
                            Spacer()
                            Toggle("", isOn: $viewModel.ringOnMakeupDays)
                                .labelsHidden()
                                .tint(Color.iosGreen)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        sectionDivider()

                        HStack {
                            Text(locale.localizedString("查看日历覆盖"))
                                .font(.bodyText())
                                .foregroundStyle(Color.accent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.fgTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .background(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(locale.localizedString("开启后，节假日自动跳过闹钟，补班日自动恢复响铃。也可以在日历中手动覆盖某天的响铃状态。"))
                        .font(.caption())
                        .foregroundStyle(Color.fgTertiary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.bgPrimary)
            .navigationTitle(alarm == nil ? locale.localizedString("新建闹钟") : locale.localizedString("编辑闹钟"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locale.localizedString("取消")) { dismiss() }
                        .foregroundStyle(Color.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(locale.localizedString("保存")) {
                        let saved = viewModel.save(to: alarm)
                        if alarm == nil {
                            modelContext.insert(saved)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accent)
                }
            }
        }
        .onAppear {
            viewModel.load(from: alarm)
        }
    }

    private var ringtoneRow: some View {
        HStack {
            Text(locale.localizedString("铃声"))
                .font(.bodyText())
            Spacer()
            Picker("", selection: $viewModel.ringtone) {
                ForEach(AlarmEditViewModel.ringtoneOptions, id: \.self) { tone in
                    Text(tone.capitalized).tag(tone)
                }
            }
            .labelsHidden()
            .tint(Color.fgSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var snoozeRow: some View {
        HStack {
            Text(locale.localizedString("稍后提醒"))
                .font(.bodyText())
            Spacer()
            Picker("", selection: $viewModel.snoozeDuration) {
                Text(locale.localizedString("关闭")).tag(0)
                ForEach([1, 3, 5, 10, 15, 30], id: \.self) { min in
                    Text("\(min) " + locale.localizedString("分钟")).tag(min)
                }
            }
            .labelsHidden()
            .tint(Color.fgSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var advanceRow: some View {
        HStack {
            Text(locale.localizedString("提前响铃"))
                .font(.bodyText())
            Spacer()
            Picker("", selection: $viewModel.advanceMinutes) {
                Text(locale.localizedString("不提前")).tag(0)
                ForEach([5, 10, 15, 30, 60], id: \.self) { min in
                    Text("\(min) " + locale.localizedString("分钟")).tag(min)
                }
            }
            .labelsHidden()
            .tint(Color.fgSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func sectionDivider() -> some View {
        Color.bgTertiary
            .frame(height: 0.5)
            .padding(.leading, 16)
    }

    private func settingsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.bodyText())
            Spacer()
            Text(value).font(.bodyText()).foregroundStyle(Color.fgSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsRowChevron(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.bodyText()).foregroundStyle(Color.fgPrimary)
            Spacer()
            Text(value).font(.bodyText()).foregroundStyle(Color.fgSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color.fgTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    AlarmEditSheet(alarm: nil)
        .modelContainer(for: Alarm.self, inMemory: true)
}
