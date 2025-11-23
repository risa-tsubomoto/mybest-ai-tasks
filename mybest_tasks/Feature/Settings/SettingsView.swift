import SwiftUI

/// アプリの設定画面。
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // アプリロゴとバージョン
                    VStack(spacing: 16) {
                        Image("icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("mybest_tasks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.text.opacity(0.6))
                    }
                    .padding(.top, 40)
                    
                    // 設定セクション
                    VStack(spacing: 16) {
                        WorkHoursSettingsCard()
                        
                        DSCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("アプリについて")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                
                                Text("AI駆動の目標管理アプリ。Gemini APIを使用してタスクを自動生成し、マイルストーンで進捗を可視化します。")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                            }
                        }
                        
                        DSCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("開発者")
                                    .font(.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                
                                Text("Built with ❤️ using SwiftUI & Gemini AI")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

/// 曜日を表す列挙型
enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "日曜日"
        case .monday: return "月曜日"
        case .tuesday: return "火曜日"
        case .wednesday: return "水曜日"
        case .thursday: return "木曜日"
        case .friday: return "金曜日"
        case .saturday: return "土曜日"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "日"
        case .monday: return "月"
        case .tuesday: return "火"
        case .wednesday: return "水"
        case .thursday: return "木"
        case .friday: return "金"
        case .saturday: return "土"
        }
    }
}

/// 作業時間設定カード（曜日別）
struct WorkHoursSettingsCard: View {
    @State private var selectedWeekday: Weekday = .monday
    @State private var workHours: [Weekday: (start: Int, end: Int)] = [:]
    
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
                        ForEach(Weekday.allCases) { weekday in
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
            for weekday in Weekday.allCases {
                let start = UserDefaults.standard.object(forKey: "workStartHour_\(weekday.rawValue)") as? Int ?? 9
                let end = UserDefaults.standard.object(forKey: "workEndHour_\(weekday.rawValue)") as? Int ?? 18
                workHours[weekday] = (start, end)
            }
        }
    }
}

/// 曜日ごとの時間設定ビュー
struct WeekdayTimeSettings: View {
    let weekday: Weekday
    @Binding var startHour: Int
    @Binding var endHour: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text(weekday.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("開始時刻")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                    
                    Picker("開始時刻", selection: $startHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                Text("〜")
                    .foregroundColor(DesignSystem.Colors.text.opacity(0.5))
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("終了時刻")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                    
                    Picker("終了時刻", selection: $endHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
            }
            
            if startHour >= endHour {
                Text("⚠️ 終了時刻は開始時刻より後に設定してください")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(DesignSystem.Colors.background.opacity(0.5))
        .cornerRadius(8)
    }
}
