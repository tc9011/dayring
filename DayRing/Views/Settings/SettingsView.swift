import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()

    private var settings: AppSettings {
        if let existing = allSettings.first {
            return existing
        }
        let new = AppSettings()
        modelContext.insert(new)
        return new
    }

    var body: some View {
        NavigationStack {
            List {
                Section("通用") {
                    settingsRow(
                        icon: "globe",
                        iconColor: Color.makeupPurple,
                        title: "时区",
                        value: viewModel.timezoneDisplayName
                    )

                    settingsRow(
                        icon: "calendar",
                        iconColor: Color.accent,
                        title: "每周第一天",
                        value: viewModel.firstDayDisplayName
                    )

                    timeFormatRow
                }

                Section("历法") {
                    settingsRow(
                        icon: "square.grid.2x2",
                        iconColor: Color.iosGreen,
                        title: "其他历法",
                        value: viewModel.calendarDisplayName
                    )
                }

                Section("其他") {
                    settingsRow(
                        icon: "textformat",
                        iconColor: Color.iosIndigo,
                        title: "语言",
                        value: viewModel.languageDisplayName
                    )

                    aboutRow
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("设置")
            .background {
                Color.bgPrimary.ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom) {
                Text(viewModel.appVersion)
                    .font(Font.smallCaption())
                    .foregroundStyle(Color.fgTertiary)
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Rows

    private var timeFormatRow: some View {
        HStack {
            settingsIcon("clock", color: Color.iosBlue)
            Text("时间格式")
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Picker("", selection: Bindable(settings).timeFormat) {
                Text("12h").tag(TimeFormat.h12)
                Text("24h").tag(TimeFormat.h24)
            }
            .pickerStyle(.segmented)
            .frame(width: 100)
        }
    }

    private var aboutRow: some View {
        HStack {
            settingsIcon("info.circle", color: Color.fgSecondary)
            Text("关于 DayRing")
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.fgTertiary)
        }
    }

    // MARK: - Components

    private func settingsIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        value: String
    ) -> some View {
        HStack {
            settingsIcon(icon, color: iconColor)
            Text(title)
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Text(value)
                .font(Font.bodyText())
                .foregroundStyle(Color.fgSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.fgTertiary)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
