import SwiftUI
import SwiftData
import Combine

struct AlarmListView: View {
    @Query private var alarms: [Alarm]
    @Query private var allSettings: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.localeManager) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = AlarmListViewModel()
    @State private var showingNewAlarm = false
    @State private var editingAlarm: Alarm?
    @State private var refreshTick = Date()

    private var settings: AppSettings? {
        allSettings.first
    }

    private var is24HourFormat: Bool {
        settings?.timeFormat != .h12
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            List {
                if let bannerText = viewModel.nextAlarmText(now: refreshTick) {
                    NextAlarmBanner(text: bannerText)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                }

                ForEach(viewModel.sortedByNextRing(now: refreshTick)) { alarm in
                    AlarmCardView(
                        alarm: alarm,
                        statusText: viewModel.statusInfo(for: alarm, now: refreshTick).text,
                        statusColor: viewModel.statusInfo(for: alarm, now: refreshTick).color,
                        is24HourFormat: is24HourFormat,
                        isSkipActive: viewModel.isSkipActive(alarm),
                        onSkipNext: { viewModel.skipNext(alarm) },
                        onTap: {
                            editingAlarm = alarm
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
            viewModel.disableExpiredNonRepeatingAlarms()
        }
        .onChange(of: alarms) {
            viewModel.alarms = alarms
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                refreshTick = Date()
                viewModel.disableExpiredNonRepeatingAlarms(now: refreshTick)
            }
        }
        .onReceive(Timer.publish(every: 15, on: .main, in: .common).autoconnect()) { tick in
            refreshTick = tick
            viewModel.disableExpiredNonRepeatingAlarms(now: tick)
        }
        .sheet(isPresented: $showingNewAlarm) {
            AlarmEditSheet(alarm: nil)
        }
        .sheet(item: $editingAlarm) { alarm in
            AlarmEditSheet(alarm: alarm)
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text(locale.localizedString("闹钟"))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Button {
                showingNewAlarm = true
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
