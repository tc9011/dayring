import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Query(sort: \Alarm.hour) private var alarms: [Alarm]
    @State private var viewModel = CalendarViewModel()
    @State private var showingDayDetail = false

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            ScrollView {
                VStack(spacing: 12) {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.bgPrimary.ignoresSafeArea()
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

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text("日历")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.fgPrimary)
            Spacer()
            Button("今天") {
                viewModel.goToToday()
            }
            .font(.system(size: 17))
            .foregroundStyle(Color.accent)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var monthNavigationBar: some View {
        HStack {
            Button {
                viewModel.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fgPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.bgTertiary)
                    .clipShape(Circle())
            }

            Spacer()

            Text(viewModel.monthTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.fgPrimary)

            Spacer()

            Button {
                viewModel.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fgPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.bgTertiary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
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
