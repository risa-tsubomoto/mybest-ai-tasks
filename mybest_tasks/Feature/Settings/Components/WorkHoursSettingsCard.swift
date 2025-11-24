import SwiftUI
import DesignSystem
import MyBestAITasksCore

/// 作業時間設定カード（曜日別）
struct WorkHoursSettingsCard: View {
    @State private var selectedWeekday: MyBestAITasksCore.Weekday = .monday
    @State private var workHours: [MyBestAITasksCore.Weekday: (start: Int, end: Int)] = [:]
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("作業時間帯（曜日別）")
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("カレンダーにタスクを登録する時間帯を曜日ごとに設定します")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                
                // 曜日選択ボタン
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MyBestAITasksCore.Weekday.allCases) { weekday in
                            Button {
                                selectedWeekday = weekday
                            } label: {
                                Text(weekday.shortName)
                                    .font(.caption)
                                    .fontWeight(selectedWeekday == weekday ? .bold : .regular)
                                    .foregroundColor(selectedWeekday == weekday ? .white : DesignSystem.Colors.text)
                                    .frame(width: 40, height: 40)
                                    .background(selectedWeekday == weekday ? DesignSystem.Colors.primary : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                // 選択された曜日の時間設定
                WeekdayTimeSettings(
                    weekday: selectedWeekday,
                    startHour: Binding(
                        get: { workHours[selectedWeekday]?.start ?? 9 },
                        set: { newValue in
                            let end = workHours[selectedWeekday]?.end ?? 18
                            workHours[selectedWeekday] = (newValue, end)
                            UserDefaults.standard.set(newValue, forKey: "workStartHour_\(selectedWeekday.rawValue)")
                        }
                    ),
                    endHour: Binding(
                        get: { workHours[selectedWeekday]?.end ?? 18 },
                        set: { newValue in
                            let start = workHours[selectedWeekday]?.start ?? 9
                            workHours[selectedWeekday] = (start, newValue)
                            UserDefaults.standard.set(newValue, forKey: "workEndHour_\(selectedWeekday.rawValue)")
                        }
                    )
                )
            }
        }
        .onAppear {
            // Load saved settings
            for weekday in MyBestAITasksCore.Weekday.allCases {
                let start = UserDefaults.standard.object(forKey: "workStartHour_\(weekday.rawValue)") as? Int ?? 9
                let end = UserDefaults.standard.object(forKey: "workEndHour_\(weekday.rawValue)") as? Int ?? 18
                workHours[weekday] = (start, end)
            }
        }
    }
}
