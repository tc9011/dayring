import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.localeManager) private var locale
    @State private var viewModel = SettingsViewModel()
    @State private var showingLanguagePicker = false

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
        .onAppear {
            locale.currentLocale = settings.locale
        }
        .sheet(isPresented: $showingLanguagePicker) {
            languagePickerSheet
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text(locale.localizedString("设置"))
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
                title: locale.localizedString("时区"),
                value: viewModel.timezoneDisplayName
            )

            sectionSeparator

            settingsRow(
                icon: "calendar",
                iconColor: Color.accent,
                title: locale.localizedString("每周第一天"),
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
        VStack(spacing: 8) {
            Text(locale.localizedString("历法"))
                .font(.system(size: 13))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingsRow(
                    icon: "book",
                    iconColor: Color.makeupPurple,
                    title: locale.localizedString("其他历法"),
                    value: viewModel.calendarDisplayName
                )
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var otherSection: some View {
        VStack(spacing: 8) {
            Text(locale.localizedString("其他"))
                .font(.system(size: 13))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Button {
                    showingLanguagePicker = true
                } label: {
                    settingsRow(
                        icon: "translate",
                        iconColor: Color.iosGray,
                        title: locale.localizedString("语言"),
                        value: settings.locale.nativeName
                    )
                }

                sectionSeparator

                aboutRow
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Language Picker Sheet

    private var languagePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(AppLocale.allCases, id: \.self) { appLocale in
                    Button {
                        settings.locale = appLocale
                        locale.currentLocale = appLocale
                        showingLanguagePicker = false
                    } label: {
                        HStack {
                            Text(appLocale.nativeName)
                                .foregroundStyle(Color.fgPrimary)
                            Spacer()
                            if settings.locale == appLocale {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(locale.localizedString("语言"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locale.localizedString("完成")) {
                        showingLanguagePicker = false
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }

    // MARK: - Rows

    private var timeFormatRow: some View {
        HStack {
            settingsIcon("clock.fill", color: Color.iosIndigo)
            Text(locale.localizedString("时间格式"))
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
            Text(locale.localizedString("外观"))
                .font(Font.bodyText())
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Picker("", selection: Bindable(settings).appearanceMode) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.localizedName).tag(mode)
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
            Text(locale.localizedString("关于 DayRing"))
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
