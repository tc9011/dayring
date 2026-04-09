import SwiftUI

struct WeekdaySelectorView: View {
    @Binding var selectedDays: Set<Weekday>

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Weekday.allCases, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(day.shortName)
                        .font(.system(size: 14, weight: selectedDays.contains(day) ? .semibold : .medium))
                        .foregroundStyle(selectedDays.contains(day) ? .white : Color.fgSecondary)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
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
