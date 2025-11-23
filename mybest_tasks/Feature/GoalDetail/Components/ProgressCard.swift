import SwiftUI

/// 目標の進捗を表示するカードコンポーネント。
struct ProgressCard: View {
    let goal: Goal
    
    var body: some View {
        DSCard {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // タスクベース進捗
                VStack(spacing: DesignSystem.Spacing.small) {
                    HStack {
                        Text("進捗")
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.text)
                        Spacer()
                        Text("\(Int(goal.progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    ProgressView(value: goal.progress)
                        .tint(DesignSystem.Colors.primary)
                    
                    let counts = goal.taskCounts
                    Text("\(counts.completed)/\(counts.total) タスク完了")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // マイルストーンベース進捗（オプション）
                if let milestoneProgress = goal.milestoneProgress {
                    Divider()
                    
                    VStack(spacing: DesignSystem.Spacing.small) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundColor(DesignSystem.Colors.secondary)
                            Text("マイルストーン")
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.Colors.text)
                            Spacer()
                            Text("\(Int(milestoneProgress * 100))%")
                                .font(.headline)
                                .foregroundColor(DesignSystem.Colors.secondary)
                        }
                        
                        ProgressView(value: milestoneProgress)
                            .tint(DesignSystem.Colors.secondary)
                        
                        let completed = goal.milestones.filter { $0.isCompleted(tasks: goal.tasks) }.count
                        Text("\(completed)/\(goal.milestones.count) マイルストーン完了")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // マイルストーンなしの目標
        ProgressCard(goal: Goal(
            title: "小さな目標",
            deadline: Date(),
            tasks: [
                GoalTask(title: "タスク1", estimatedMinutes: 30, status: .completed),
                GoalTask(title: "タスク2", estimatedMinutes: 60, status: .pending),
                GoalTask(title: "タスク3", estimatedMinutes: 45, status: .pending)
            ]
        ))
        
        // マイルストーンありの目標
        let tasks = [
            GoalTask(title: "基礎1", estimatedMinutes: 30, status: .completed),
            GoalTask(title: "基礎2", estimatedMinutes: 60, status: .completed),
            GoalTask(title: "応用1", estimatedMinutes: 45, status: .pending),
            GoalTask(title: "応用2", estimatedMinutes: 90, status: .pending),
            GoalTask(title: "実践", estimatedMinutes: 120, status: .pending)
        ]
        
        ProgressCard(goal: Goal(
            title: "大きな目標",
            deadline: Date(),
            tasks: tasks,
            milestones: [
                Milestone(title: "基礎編", taskIds: [tasks[0].id, tasks[1].id], order: 0),
                Milestone(title: "応用編", taskIds: [tasks[2].id, tasks[3].id], order: 1),
                Milestone(title: "実践編", taskIds: [tasks[4].id], order: 2)
            ]
        ))
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
