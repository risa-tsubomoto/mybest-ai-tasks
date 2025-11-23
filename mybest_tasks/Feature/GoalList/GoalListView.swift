import SwiftUI
import SwiftData


struct GoalListView: View {
    @StateObject var viewModel: GoalListViewModel
    @Query private var goals: [Goal]
    @State private var showingGoalInput = false
    @State private var showingSettings = false
    @State private var apiKey: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                if apiKey.isEmpty {
                    ApiKeyInputView(apiKey: $apiKey)
                } else if goals.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(goals) { goal in
                                NavigationLink {
                                    GoalDetailRoute(goal: goal, repository: viewModel.repository)
                                } label: {
                                    GoalCardView(goal: goal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(DesignSystem.Colors.text)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingGoalInput = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    .disabled(apiKey.isEmpty)
                }
            }
            .sheet(isPresented: $showingGoalInput) {
                GoalInputView(viewModel: GoalInputViewModel(
                    createGoalUseCase: CreateGoalUseCase(
                        repository: viewModel.repository,
                        geminiService: GeminiService(apiKey: apiKey),
                        notificationManager: NotificationManager()
                    )
                ))
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                if let key = KeychainHelper.shared.read(for: "geminiApiKey") {
                    self.apiKey = key
                }
            }
        }
    }
}


#Preview {
    GoalListView(viewModel: GoalListViewModel(repository: MockGoalRepository(initialGoals: [
        Goal(title: "Learn SwiftUI", deadline: Date(), tasks: [
            GoalTask(title: "Read Docs", estimatedMinutes: 60, status: .completed),
            GoalTask(title: "Build App", estimatedMinutes: 120)
        ])
    ])))
}
