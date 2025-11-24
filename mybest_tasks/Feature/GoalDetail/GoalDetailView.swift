import SwiftUI
import MyBestAITasksCore
import DesignSystem

struct GoalDetailView: View {
    let goal: Goal
    @StateObject var viewModel: GoalDetailViewModel
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text("Deadline: \(goal.deadline.formatted(date: .long, time: .omitted))")
                    }
                    .foregroundColor(DesignSystem.Colors.text.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Progress Card
                ProgressCard(goal: goal)
                    .padding(.horizontal)
                
                // Tasks (grouped by milestones if available)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("タスク")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                        .padding(.horizontal)
                    
                    if goal.milestones.isEmpty {
                        // No milestones: show flat task list
                        ForEach(goal.tasks) { task in
                            TaskRowView(task: task, onToggle: {
                                viewModel.toggleTask(task)
                            })
                        }
                    } else {
                        // With milestones: show grouped by milestone
                        ForEach(goal.milestones.sorted(by: { $0.order < $1.order })) { milestone in
                            MilestoneSection(
                                milestone: milestone,
                                tasks: goal.tasks,
                                onToggleTask: { task in
                                    viewModel.toggleTask(task)
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: GoalChatView(goal: goal, modelContext: modelContext)) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                        }
                        
                        Button {
                            viewModel.addToCalendar()
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                        }
                    }
                }
            }
            .alert("カレンダー連携", isPresented: $viewModel.showingCalendarAlert) {
                if viewModel.shouldShowSettingsButton {
                    Button("設定を開く") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("キャンセル", role: .cancel) { }
                } else {
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(viewModel.calendarAlertMessage)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct GoalDetailRoute: View {
    let goal: Goal
    let repository: GoalRepositoryProtocol
    
    var body: some View {
        GoalDetailView(goal: goal, viewModel: GoalDetailViewModel(goal: goal, repository: repository))
    }
}

#Preview {
    let tasks = [
        GoalTask(title: "Read Docs", estimatedMinutes: 60, status: .completed),
        GoalTask(title: "Build App", estimatedMinutes: 120, status: .pending),
        GoalTask(title: "Test App", estimatedMinutes: 90, status: .pending),
        GoalTask(title: "Deploy", estimatedMinutes: 30, status: .pending)
    ]
    
    let milestones = [
        Milestone(title: "学習フェーズ", taskIds: [tasks[0].id], order: 0),
        Milestone(title: "開発フェーズ", taskIds: [tasks[1].id, tasks[2].id], order: 1),
        Milestone(title: "リリースフェーズ", taskIds: [tasks[3].id], order: 2)
    ]
    
    let goal = Goal(title: "Learn SwiftUI", deadline: Date(), tasks: tasks, milestones: milestones)
    let repo = MockGoalRepository(initialGoals: [goal])
    
    NavigationStack {
        GoalDetailView(goal: goal, viewModel: GoalDetailViewModel(goal: goal, repository: repo))
    }
}
