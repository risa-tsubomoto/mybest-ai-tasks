import SwiftUI

/// マイルストーンごとにタスクをグループ化して表示するコンポーネント。
struct MilestoneSection: View {
    let milestone: Milestone
    let tasks: [GoalTask]
    let onToggleTask: (GoalTask) -> Void
    @State private var isExpanded: Bool = true
    
    private var milestoneTasks: [GoalTask] {
        tasks.filter { milestone.taskIds.contains($0.id) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // マイルストーンヘッダー（タイムラインのノード）
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(alignment: .top, spacing: 16) {
                    // 左側：タイムラインノード
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "flag.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        // 下に伸びる線（展開時のみ）
                        if isExpanded {
                            Rectangle()
                                .fill(DesignSystem.Colors.primary.opacity(0.2))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 32)
                    
                    // 右側：マイルストーン情報
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(milestone.title)
                                .font(.headline)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Spacer()
                            
                            // 進捗
                            let progress = milestone.progress(tasks: tasks)
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .cornerRadius(8)
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.text.opacity(0.5))
                        }
                        
                        // 期限などのメタデータ
                        if let deadline = milestone.deadline {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text(deadline.formatted(date: .abbreviated, time: .omitted))
                            }
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.text.opacity(0.6))
                        }
                    }
                    .padding(.bottom, isExpanded ? 16 : 0) // 展開時はタスクとの間隔を空ける
                }
            }
            .buttonStyle(.plain)
            
            // タスクリスト（タイムラインのステップ）
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(milestoneTasks.enumerated()), id: \.element.id) { index, task in
                        HStack(alignment: .top, spacing: 16) {
                            // 左側：タイムライン線と接続点
                            VStack(spacing: 0) {
                                // 上からの線
                                Rectangle()
                                    .fill(DesignSystem.Colors.primary.opacity(0.2))
                                    .frame(width: 2)
                                    .frame(height: 24) // タスクの中心まで
                                
                                // タスクのノード（完了/未完了）
                                Circle()
                                    .fill(task.status == .completed ? Color.green : DesignSystem.Colors.cardBackground)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(task.status == .completed ? Color.green : DesignSystem.Colors.text.opacity(0.3), lineWidth: 2)
                                    )
                                
                                // 下への線（最後のタスク以外）
                                if index < milestoneTasks.count - 1 {
                                    Rectangle()
                                        .fill(DesignSystem.Colors.primary.opacity(0.2))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 32)
                            
                            // 右側：タスクカード
                            TaskRowView(task: task, onToggle: { onToggleTask(task) })
                                .padding(.bottom, 12)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let tasks = [
        GoalTask(title: "基礎タスク1", estimatedMinutes: 30, status: .completed),
        GoalTask(title: "基礎タスク2", estimatedMinutes: 60, status: .completed),
        GoalTask(title: "応用タスク1", estimatedMinutes: 45, status: .pending),
        GoalTask(title: "応用タスク2", estimatedMinutes: 90, status: .pending)
    ]
    
    VStack(spacing: 16) {
        MilestoneSection(
            milestone: Milestone(title: "基礎編", taskIds: [tasks[0].id, tasks[1].id], deadline: Date(), order: 0),
            tasks: tasks,
            onToggleTask: { _ in print("Toggle") }
        )
        
        MilestoneSection(
            milestone: Milestone(title: "応用編", taskIds: [tasks[2].id, tasks[3].id], deadline: Date().addingTimeInterval(7 * 24 * 60 * 60), order: 1),
            tasks: tasks,
            onToggleTask: { _ in print("Toggle") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
