import SwiftUI
import MyBestAITasksCore
import DesignSystem

struct GoalCardView: View {
    let goal: Goal
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(DesignSystem.Colors.secondary)
                    Text(goal.deadline.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(goal.tasks.count) Tasks")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.text)
                        .padding(6)
                        .background(DesignSystem.Colors.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GoalCardView(goal: Goal(
            title: "SwiftUIをマスターする",
            deadline: Date().addingTimeInterval(7 * 24 * 60 * 60),
            tasks: [
                GoalTask(title: "基礎を学ぶ", estimatedMinutes: 120),
                GoalTask(title: "アプリを作る", estimatedMinutes: 240),
                GoalTask(title: "公開する", estimatedMinutes: 60)
            ]
        ))
        
        GoalCardView(goal: Goal(
            title: "健康的な生活習慣",
            deadline: Date().addingTimeInterval(30 * 24 * 60 * 60),
            tasks: [
                GoalTask(title: "毎朝ジョギング", estimatedMinutes: 30),
                GoalTask(title: "野菜を食べる", estimatedMinutes: 15)
            ]
        ))
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
