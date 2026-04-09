import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.hour, order: .forward) private var alarms: [Alarm]
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.localeManager) private var locale
    @State private var viewModel = AlarmListViewModel()
    @State private var showingEditor = false
    @State private var editingAlarm: Alarm?

    private var settings: AppSettings {
        allSettings.first ?? AppSettings()
    }

    private var is24HourFormat: Bool {
        settings.timeFormat == .h24
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            List {
                if let bannerText = viewModel.nextAlarmText() {
                    NextAlarmBanner(text: bannerText)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                }

                ForEach(alarms) { alarm in
                    let status = viewModel.statusInfo(for: alarm)
                    AlarmCardView(
                        alarm: alarm,
                        statusText: status.text,
                        statusColor: status.color,
                        is24HourFormat: is24HourFormat,
                        onSkipNext: { viewModel.skipNext(alarm) },
                        onTap: {
                            editingAlarm = alarm
                            showingEditor = true
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            modelContext.delete(alarm)
                        } label: {
                            Label(locale.localizedString("删除"), systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background {
            Color.bgPrimary.ignoresSafeArea()
        }
        .onAppear {
            viewModel.alarms = alarms
        }
        .onChange(of: alarms) {
            viewModel.alarms = alarms
        }
        .sheet(isPresented: $showingEditor) {
            AlarmEditSheet(alarm: editingAlarm)
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text(locale.localizedString("闹钟"))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Button {
                editingAlarm = nil
                showingEditor = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

#Preview {
    AlarmListView()
        .modelContainer(for: Alarm.self, inMemory: true)
}
