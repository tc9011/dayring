import SwiftUI

struct BiweeklyDetailView: View {
    @Binding var repeatMode: RepeatMode
    @State private var week1Days: Set<Weekday> = Weekday.workdays
    @State private var week2Days: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday]

    var body: some View {
        VStack(spacing: 24) {
            Text("以两周为一个循环，选择每周哪些天响铃。")
                .font(.system(size: 15))
                .foregroundStyle(Color.fgSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            weekBox(title: "第 1 周", days: $week1Days)
            weekBox(title: "第 2 周", days: $week2Days)

            Text("以两周为一个循环，大周和小周可分别选择响铃日。")
                .font(.caption())
                .foregroundStyle(Color.fgTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(20)
        .background(Color.bgPrimary)
        .navigationTitle("大小周")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    repeatMode = .biweekly(week1: week1Days, week2: week2Days)
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
            }
        }
        .onAppear {
            if case .biweekly(let w1, let w2) = repeatMode {
                week1Days = w1
                week2Days = w2
            }
        }
    }

    private func weekBox(title: String, days: Binding<Set<Weekday>>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            HStack(spacing: 6) {
                ForEach(Weekday.allCases, id: \.self) { day in
                    Button {
                        if days.wrappedValue.contains(day) {
                            days.wrappedValue.remove(day)
                        } else {
                            days.wrappedValue.insert(day)
                        }
                    } label: {
                        Text(day.shortName)
                            .font(.system(size: 13, weight: days.wrappedValue.contains(day) ? .semibold : .medium))
                            .foregroundStyle(days.wrappedValue.contains(day) ? .white : Color.fgSecondary)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(
                                days.wrappedValue.contains(day) ? Color.accent : Color.bgTertiary,
                                in: Circle()
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        BiweeklyDetailView(repeatMode: .constant(.biweekly(week1: Weekday.workdays, week2: [.monday, .tuesday, .wednesday, .thursday])))
    }
}
