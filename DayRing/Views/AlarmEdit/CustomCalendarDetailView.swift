import SwiftUI
import SwiftData

struct CustomCalendarDetailView: View {
    @Binding var repeatMode: RepeatMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.localeManager) private var locale
    @Query private var allSettings: [AppSettings]
    @State private var selectedDates: Set<DateComponents> = []
    @State private var displayedMonth = Date()

    private var firstDayOfWeek: Weekday {
        allSettings.first?.firstDayOfWeek ?? .monday
    }

    private var gridCells: [CalendarGridCell] {
        CalendarGridHelper.gridCells(for: displayedMonth, firstDayOfWeek: firstDayOfWeek)
    }

    private var gridRows: [[CalendarGridCell]] {
        CalendarGridHelper.gridRows(from: gridCells)
    }

    private var weekdaySymbols: [String] {
        let bundleId = LocaleManager.shared.currentLocale.bundleIdentifier
        let loc = bundleId.map { Locale(identifier: $0) }
        return CalendarGridHelper.weekdaySymbols(locale: loc, firstDayOfWeek: firstDayOfWeek)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(locale.localizedString("点击日期选择响铃日，长按拖动可批量选择。"))
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
                legendItem(color: Color.accent, text: locale.localizedString("响铃日"))
                legendItem(color: Color.bgTertiary, text: locale.localizedString("不响铃"))
                legendItem(color: .clear, borderColor: Color.accent, text: locale.localizedString("今天"))
            }

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle(locale.localizedString("自定义日历"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(locale.localizedString("完成")) {
                    repeatMode = .custom(dates: selectedDates)
                    dismiss()
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
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.fgTertiary)
                        .frame(height: 30)
                }
            }

            ForEach(gridRows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.id) { cell in
                        if let components = cell.dateComponents,
                           let date = Calendar.current.date(from: components) {
                            let isSelected = selectedDates.contains(where: {
                                $0.year == components.year && $0.month == components.month && $0.day == components.day
                            })
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
                        } else {
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                }
            }
        }
    }

    private var monthTitle: String {
        let lm = LocaleManager.shared
        let yearStr = "\(Calendar.current.component(.year, from: displayedMonth))"
        let monthStr = "\(Calendar.current.component(.month, from: displayedMonth))"
        let yearLabel = lm.localizedString("年")
        let monthLabel = lm.localizedString("月")
        return "\(yearStr)\(yearLabel)\(monthStr)\(monthLabel)"
    }

    private func changeMonth(_ delta: Int) {
        displayedMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
    }

    private func legendItem(color: Color, borderColor: Color? = nil, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
                .overlay {
                    if let bc = borderColor {
                        RoundedRectangle(cornerRadius: 3).stroke(bc, lineWidth: 2)
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
