import SwiftUI

struct CustomCalendarDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var selectedDates: Set<DateComponents> = []
    @State private var displayedMonth = Date()

    var body: some View {
        VStack(spacing: 16) {
            Text("点击日期选择响铃日，长按拖动可批量选择。")
                .font(.system(size: 15))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.accent)
                }
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.accent)
                }
            }

            calendarGrid

            HStack(spacing: 16) {
                legendItem(color: Color.accent, text: "响铃日")
                legendItem(color: Color.bgTertiary, text: "不响铃")
                legendItem(color: .clear, borderColor: Color.accent, text: "今天")
            }

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("自定义日历")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .custom(dates: selectedDates)
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
            }
        }
        .onAppear {
            if case .custom(let dates) = repeatMode {
                selectedDates = dates
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(datesInMonth(), id: \.self) { components in
                if let date = Calendar.current.date(from: components) {
                    let isSelected = selectedDates.contains(components)
                    let isToday = Calendar.current.isDateInToday(date)

                    Button {
                        if isSelected {
                            selectedDates.remove(components)
                        } else {
                            selectedDates.insert(components)
                        }
                    } label: {
                        Text("\(components.day ?? 0)")
                            .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? .white : (isToday ? Color.accent : Color.fgSecondary))
                            .frame(width: 44, height: 44)
                            .background(
                                isSelected ? Color.accent : (isToday ? Color.todayBg : Color.bgTertiary),
                                in: Circle()
                            )
                            .overlay {
                                if isToday && !isSelected {
                                    Circle().stroke(Color.accent, lineWidth: 2)
                                }
                            }
                    }
                }
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    private func changeMonth(_ delta: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
    }

    private func datesInMonth() -> [DateComponents] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        return range.map { day in
            DateComponents(year: components.year, month: components.month, day: day)
        }
    }

    private func legendItem(color: Color, borderColor: Color? = nil, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 22, height: 22)
                .overlay {
                    if let bc = borderColor {
                        Circle().stroke(bc, lineWidth: 2)
                    }
                }
            Text(text).font(.smallCaption()).foregroundStyle(Color.fgSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        CustomCalendarDetailView(repeatMode: .constant(.custom(dates: [])))
    }
}
