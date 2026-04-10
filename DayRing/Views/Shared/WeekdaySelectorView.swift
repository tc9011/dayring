import SwiftUI

struct WeekdaySelectorView: View {
    @Binding var selectedDays: Set<Weekday>

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(day.shortName)
                        .font(.system(size: 15, weight: selectedDays.contains(day) ? .semibold : .medium))
                        .foregroundStyle(selectedDays.contains(day) ? .white : Color.fgSecondary)
                        .frame(width: 44, height: 44)
                        .background(
                            selectedDays.contains(day) ? Color.accent : Color.bgTertiary,
                            in: Circle()
                        )
                }
            }
        }
    }
}

#Preview {
    WeekdaySelectorView(selectedDays: .constant(Weekday.workdays))
}
