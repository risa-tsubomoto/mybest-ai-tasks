import SwiftUI
import SwiftData

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// ViewModel is now in GoalChatViewModel.swift

struct GoalChatView: View {
    @Bindable var goal: Goal
    @StateObject private var viewModel: GoalChatViewModel
    @State private var inputText = ""
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    init(goal: Goal, modelContext: ModelContext, notificationManager: NotificationManaging = NotificationManager()) {
        self.goal = goal
        _viewModel = StateObject(wrappedValue: GoalChatViewModel(goal: goal, modelContext: modelContext, notificationManager: notificationManager))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("メッセージを入力...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading)
                
                Button(action: {
                    let text = inputText
                    inputText = ""
                    Task {
                        await viewModel.sendMessage(text)
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(inputText.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("AI調整")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.removeCalendarEvents()
                    }
                } label: {
                    Image(systemName: "calendar.badge.minus")
                        .foregroundColor(.red)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

#Preview {
    let tasks = [
        GoalTask(title: "タスク1", estimatedMinutes: 60),
        GoalTask(title: "タスク2", estimatedMinutes: 30)
    ]
    let goal = Goal(title: "サンプル目標", deadline: Date(), tasks: tasks)
    let container = try! ModelContainer(for: Goal.self)
    
    NavigationStack {
        GoalChatView(goal: goal, modelContext: container.mainContext)
    }
}
