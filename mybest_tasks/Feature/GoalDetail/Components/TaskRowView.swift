import SwiftUI
import MyBestAITasksCore
import DesignSystem

struct TaskRowView: View {
    let task: GoalTask
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // タスク情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .strikethrough(task.status == .completed)
                        .foregroundColor(task.status == .completed ? DesignSystem.Colors.text.opacity(0.5) : DesignSystem.Colors.text)
                
                HStack(spacing: 8) {
                    // 推定時間
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(task.estimatedMinutes) min")
                            .font(.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.text.opacity(0.6))
                    
                    // 予定日（あれば）
                    if let scheduledDate = task.scheduledDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(scheduledDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                        }
                        .foregroundColor(DesignSystem.Colors.text.opacity(0.6))
                    }
                }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    task.status == .completed
                        ? Color.green.opacity(0.3)
                        : DesignSystem.Colors.text.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        TaskRowView(
            task: GoalTask(title: "完了したタスク", estimatedMinutes: 30, status: .completed),
            onToggle: { print("Toggle") }
        )
        
        TaskRowView(
            task: GoalTask(title: "未完了のタスク", estimatedMinutes: 60, status: .pending),
            onToggle: { print("Toggle") }
        )
        
        TaskRowView(
            task: GoalTask(title: "予定日付きタスク", estimatedMinutes: 90, status: .pending, scheduledDate: Date()),
            onToggle: { print("Toggle") }
        )
        
        TaskRowView(
            task: GoalTask(title: "長いタスク名の例：これは非常に長いタスク名でレイアウトをテストするためのものです", estimatedMinutes: 120, status: .pending),
            onToggle: { print("Toggle") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
