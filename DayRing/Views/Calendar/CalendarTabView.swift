import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Query(sort: \Alarm.hour) private var alarms: [Alarm]
    @State private var viewModel = CalendarViewModel()
    @State private var showingDayDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    monthNavigationBar
                    CalendarGridView(
                        viewModel: viewModel,
                        alarms: alarms,
                        onDateTapped: { date in
                            viewModel.selectedDate = date
                            showingDayDetail = true
                        }
                    )
                    legendRow
                        .padding(.top, 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.bgPrimary.ignoresSafeArea()
            }
            .navigationTitle("日历")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("今天") {
                        viewModel.goToToday()
                    }
                    .foregroundStyle(Color.accent)
                }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = viewModel.selectedDate {
                    DayDetailSheet(
                        date: date,
                        alarms: alarms,
                        is24HourFormat: true
                    )
                }
            }
        }
    }

    private var monthNavigationBar: some View {
        HStack {
            Button {
                viewModel.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fgPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.bgTertiary)
                    .clipShape(Circle())
            }

            Spacer()

            Text(viewModel.monthTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.fgPrimary)

            Spacer()

            Button {
                viewModel.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fgPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.bgTertiary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var legendRow: some View {
        HStack(spacing: 16) {
            legendItem(color: Color.holidayRed, text: "节假日")
            legendItem(color: Color.makeupPurple, text: "补班日")
            legendItem(color: Color.accent, text: "今天")
            legendItem(color: Color.iosBlue, text: "已覆盖")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(Font.smallCaption())
                .foregroundStyle(Color.fgSecondary)
        }
    }
}

#Preview {
    CalendarTabView()
        .modelContainer(for: Alarm.self, inMemory: true)
}
