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

                    GroupBox {
                        VStack(spacing: 0) {
                            settingsRow(locale.localizedString("标签"), value: viewModel.label.isEmpty ? locale.localizedString("无") : viewModel.label)
                            Divider()
                            NavigationLink {
                                RepeatModePicker(repeatMode: $viewModel.repeatMode)
                            } label: {
                                settingsRowChevron(locale.localizedString("重复"), value: viewModel.repeatMode.displayName)
                            }
                            Divider()
                            settingsRowChevron(locale.localizedString("铃声"), value: viewModel.ringtone)
                            Divider()
                            settingsRow(locale.localizedString("稍后提醒"), value: viewModel.snoozeDurationText)
                            Divider()
                            settingsRowChevron(locale.localizedString("提前响铃"), value: viewModel.advanceMinutesText)
                            Divider()
                            HStack {
                                Text(locale.localizedString("响铃后删除"))
                                    .font(.bodyText())
                                Spacer()
                                Toggle("", isOn: $viewModel.deleteAfterRing)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .backgroundStyle(Color.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(locale.localizedString("智能日历"))
                        .font(.caption())
                        .foregroundStyle(Color.fgSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    GroupBox {
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

                            Divider()

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

                            Divider()

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
                    }
                    .backgroundStyle(Color.bgSecondary)
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
