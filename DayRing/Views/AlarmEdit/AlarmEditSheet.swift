import SwiftUI
import SwiftData

struct AlarmEditSheet: View {
    let alarm: Alarm?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AlarmEditViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TimePickerView(hour: $viewModel.hour, minute: $viewModel.minute)

                    GroupBox {
                        VStack(spacing: 0) {
                            settingsRow("标签", value: viewModel.label.isEmpty ? "无" : viewModel.label)
                            Divider()
                            NavigationLink {
                                RepeatModePicker(repeatMode: $viewModel.repeatMode)
                            } label: {
                                settingsRowChevron("重复", value: viewModel.repeatMode.displayName)
                            }
                            Divider()
                            settingsRowChevron("铃声", value: viewModel.ringtone)
                            Divider()
                            settingsRow("稍后提醒", value: viewModel.snoozeDurationText)
                            Divider()
                            settingsRowChevron("提前响铃", value: viewModel.advanceMinutesText)
                            Divider()
                            HStack {
                                Text("响铃后删除")
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

                    Text("智能日历")
                        .font(.caption())
                        .foregroundStyle(Color.fgSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    GroupBox {
                        VStack(spacing: 0) {
                            HStack {
                                Text("节假日跳过")
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
                                Text("补班日响铃")
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
                                Text("查看日历覆盖")
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

                    Text("开启后，节假日自动跳过闹钟，补班日自动恢复响铃。也可以在日历中手动覆盖某天的响铃状态。")
                        .font(.caption())
                        .foregroundStyle(Color.fgTertiary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.bgPrimary)
            .navigationTitle(alarm == nil ? "新建闹钟" : "编辑闹钟")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(Color.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
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

    // MARK: - Row helpers

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
