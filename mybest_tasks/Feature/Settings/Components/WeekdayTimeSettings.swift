import SwiftUI
import DesignSystem
import MyBestAITasksCore

/// 曜日ごとの時間設定ビュー
struct WeekdayTimeSettings: View {
    let weekday: MyBestAITasksCore.Weekday
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
