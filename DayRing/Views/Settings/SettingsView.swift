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
        VStack(spacing: 0) {
            headerRow
            ScrollView {
                VStack(spacing: 24) {
                    generalSection
                    calendarSection
                    otherSection
                    Text(viewModel.appVersion)
                        .font(Font.smallCaption())
                        .foregroundStyle(Color.fgTertiary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
        .background {
            Color.bgPrimary.ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text("设置")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.fgPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Sections

    private var generalSection: some View {
        VStack(spacing: 0) {
            settingsRow(
                icon: "globe",
                iconColor: Color.iosBlue,
                title: "时区",
                value: viewModel.timezoneDisplayName
            )

            sectionSeparator

            settingsRow(
                icon: "calendar",
                iconColor: Color.accent,
                title: "每周第一天",
                value: viewModel.firstDayDisplayName
            )

            sectionSeparator

            timeFormatRow

            sectionSeparator

            appearanceRow
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var calendarSection: some View {
        VStack(spacing: 0) {
            Text("历法")
                .font(.system(size: 13))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(
                    icon: "book",
                    iconColor: Color.makeupPurple,
                    title: "其他历法",
                    value: viewModel.calendarDisplayName
                )
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var otherSection: some View {
        VStack(spacing: 0) {
            Text("其他")
                .font(.system(size: 13))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(
                    icon: "translate",
                    iconColor: Color.iosGray,
                    title: "语言",
                    value: viewModel.languageDisplayName
                )

                sectionSeparator

                aboutRow
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Rows

    private var timeFormatRow: some View {
        HStack {
            settingsIcon("clock.fill", color: Color.iosIndigo)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var appearanceRow: some View {
        HStack {
            settingsIcon("moon.fill", color: Color.settingsIconBlack)
            Text("外观")
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Picker("", selection: Bindable(settings).appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var aboutRow: some View {
        HStack {
            settingsIcon("info.circle.fill", color: Color.iosTeal)
            Text("关于 DayRing")
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.fgTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Components

    private var sectionSeparator: some View {
        Color.separator
            .frame(height: 1)
            .padding(.leading, 58)
    }

    private func settingsIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(color, in: RoundedRectangle(cornerRadius: 7))
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
