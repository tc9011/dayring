import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \Alarm.hour, order: .forward) private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AlarmListViewModel()
    @State private var showingEditor = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                headerRow
                ScrollView {
                    GlassEffectContainer(spacing: 12) {
                        VStack(spacing: 12) {
                            if let bannerText = viewModel.nextAlarmText() {
                                NextAlarmBanner(text: bannerText)
                            }

                            ForEach(alarms) { alarm in
                                let status = viewModel.statusInfo(for: alarm)
                                AlarmCardView(
                                    alarm: alarm,
                                    statusText: status.text,
                                    statusColor: status.color,
                                    is24HourFormat: true,
                                    onSkipNext: { viewModel.skipNext(alarm) }
                                )
                                .onTapGesture {
                                    editingAlarm = alarm
                                    showingEditor = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }

            Button {
                editingAlarm = nil
                showingEditor = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accent, in: Circle())
                    .shadow(color: Color.accent.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
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
            Text("闹钟")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Button("编辑") { }
                .font(.system(size: 17))
                .foregroundStyle(Color.accent)
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
