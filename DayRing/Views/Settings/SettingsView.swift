import SwiftUI
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.dayring.app", category: "Settings")

struct SettingsView: View {
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.localeManager) private var locale
    @State private var viewModel = SettingsViewModel()
    @State private var showingLanguagePicker = false
    @State private var showingTimezonePicker = false
    @State private var showingFirstDayPicker = false
    @State private var showingCalendarPicker = false

    var body: some View {
        if let settings = allSettings.first {
            settingsContent(settings)
        }
    }

    @ViewBuilder
    private func settingsContent(_ settings: AppSettings) -> some View {
        @Bindable var s = settings
        VStack(spacing: 0) {
            headerRow
            ScrollView {
                VStack(spacing: 24) {
                    generalSection(s)
                    calendarSection(s)
                    otherSection(s)
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
            LanguagePickerSheet(settings: s, locale: locale, isPresented: $showingLanguagePicker)
        }
        .sheet(isPresented: $showingTimezonePicker) {
            TimezonePickerSheet(settings: s, locale: locale, isPresented: $showingTimezonePicker)
        }
        .sheet(isPresented: $showingFirstDayPicker) {
            FirstDayPickerSheet(settings: s, locale: locale, isPresented: $showingFirstDayPicker)
        }
        .sheet(isPresented: $showingCalendarPicker) {
            CalendarPickerSheet(settings: s, locale: locale, isPresented: $showingCalendarPicker)
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

    private func generalSection(_ settings: AppSettings) -> some View {
        VStack(spacing: 0) {
            Button {
                showingTimezonePicker = true
            } label: {
                settingsRow(
                    icon: "globe",
                    iconColor: Color.iosBlue,
                    title: locale.localizedString("时区"),
                    value: settings.timezone.displayName
                )
            }

            sectionSeparator

            Button {
                showingFirstDayPicker = true
            } label: {
                settingsRow(
                    icon: "calendar",
                    iconColor: Color.accent,
                    title: locale.localizedString("每周第一天"),
                    value: viewModel.firstDayDisplayName(for: settings)
                )
            }

            sectionSeparator

            timeFormatRow(settings)

            sectionSeparator

            appearanceRow(settings)
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func calendarSection(_ settings: AppSettings) -> some View {
        VStack(spacing: 8) {
            Text(locale.localizedString("历法"))
                .font(.system(size: 13))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Button {
                    showingCalendarPicker = true
                } label: {
                    settingsRow(
                        icon: "book",
                        iconColor: Color.makeupPurple,
                        title: locale.localizedString("其他历法"),
                        value: viewModel.calendarDisplayName(for: settings)
                    )
                }
            }
            .background(Color.bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func otherSection(_ settings: AppSettings) -> some View {
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

    // MARK: - Rows

    private func timeFormatRow(_ settings: AppSettings) -> some View {
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
        .onChange(of: settings.timeFormat) {
            saveSettings("timeFormat")
        }
    }

    private func appearanceRow(_ settings: AppSettings) -> some View {
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
        .onChange(of: settings.appearanceMode) {
            saveSettings("appearanceMode")
        }
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

    private func saveSettings(_ property: String) {
        do {
            try modelContext.save()
            logger.debug("Saved settings change: \(property)")
        } catch {
            logger.error("Failed to save settings (\(property)): \(error.localizedDescription)")
        }
    }

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

// MARK: - Picker Sheet Views (standalone structs with @Bindable)

private func saveSettingsContext(_ context: ModelContext, property: String) {
    do {
        try context.save()
        logger.debug("Saved settings change: \(property)")
    } catch {
        logger.error("Failed to save settings (\(property)): \(error.localizedDescription)")
    }
}

struct LanguagePickerSheet: View {
    @Bindable var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    var locale: LocaleManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLocale.allCases, id: \.self) { appLocale in
                    Button {
                        settings.locale = appLocale
                        saveSettingsContext(modelContext, property: "locale")
                        locale.currentLocale = appLocale
                        isPresented = false
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
                        isPresented = false
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }
}

struct TimezonePickerSheet: View {
    @Bindable var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    var locale: LocaleManager
    @Binding var isPresented: Bool

    private static let commonTimezones: [(id: String, label: String)] = [
        ("Asia/Shanghai", "UTC+8 Shanghai"),
        ("Asia/Tokyo", "UTC+9 Tokyo"),
        ("Asia/Kolkata", "UTC+5:30 Mumbai"),
        ("Asia/Dubai", "UTC+4 Dubai"),
        ("Europe/London", "UTC+0 London"),
        ("Europe/Paris", "UTC+1 Paris"),
        ("Europe/Moscow", "UTC+3 Moscow"),
        ("America/New_York", "UTC-5 New York"),
        ("America/Chicago", "UTC-6 Chicago"),
        ("America/Denver", "UTC-7 Denver"),
        ("America/Los_Angeles", "UTC-8 Los Angeles"),
        ("Pacific/Auckland", "UTC+12 Auckland"),
        ("Australia/Sydney", "UTC+11 Sydney"),
        ("Pacific/Honolulu", "UTC-10 Honolulu"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Button {
                    settings.timezone = .system
                    saveSettingsContext(modelContext, property: "timezone")
                    isPresented = false
                } label: {
                    HStack {
                        Text(locale.localizedString("跟随系统"))
                            .foregroundStyle(Color.fgPrimary)
                        Spacer()
                        if case .system = settings.timezone {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accent)
                                .fontWeight(.semibold)
                        }
                    }
                }

                ForEach(Self.commonTimezones, id: \.id) { tz in
                    Button {
                        settings.timezone = .specific(identifier: tz.id)
                        saveSettingsContext(modelContext, property: "timezone")
                        isPresented = false
                    } label: {
                        HStack {
                            Text(tz.label)
                                .foregroundStyle(Color.fgPrimary)
                            Spacer()
                            if case .specific(let current) = settings.timezone, current == tz.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(locale.localizedString("时区"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locale.localizedString("完成")) {
                        isPresented = false
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }
}

struct FirstDayPickerSheet: View {
    @Bindable var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    var locale: LocaleManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                ForEach(Weekday.allCases, id: \.self) { day in
                    Button {
                        settings.firstDayOfWeek = day
                        saveSettingsContext(modelContext, property: "firstDayOfWeek")
                        isPresented = false
                    } label: {
                        HStack {
                            Text(locale.localizedString("周") + day.shortName)
                                .foregroundStyle(Color.fgPrimary)
                            Spacer()
                            if settings.firstDayOfWeek == day {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(locale.localizedString("每周第一天"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locale.localizedString("完成")) {
                        isPresented = false
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }
}

struct CalendarPickerSheet: View {
    @Bindable var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    var locale: LocaleManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                Button {
                    settings.selectedCalendar = nil
                    saveSettingsContext(modelContext, property: "selectedCalendar")
                    isPresented = false
                } label: {
                    HStack {
                        Text(locale.localizedString("无"))
                            .foregroundStyle(Color.fgPrimary)
                        Spacer()
                        if settings.selectedCalendar == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accent)
                                .fontWeight(.semibold)
                        }
                    }
                }

                ForEach(CalendarType.allCases, id: \.self) { calType in
                    Button {
                        settings.selectedCalendar = calType
                        saveSettingsContext(modelContext, property: "selectedCalendar")
                        isPresented = false
                    } label: {
                        HStack {
                            Text(calType.localizedName)
                                .foregroundStyle(Color.fgPrimary)
                            Spacer()
                            if settings.selectedCalendar == calType {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle(locale.localizedString("历法"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locale.localizedString("完成")) {
                        isPresented = false
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
