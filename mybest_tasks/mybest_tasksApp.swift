//
//  mybest_tasksApp.swift
//  mybest_tasks
//
//  Created by 坪本梨沙 on 2025/11/21.
//

import SwiftUI
import SwiftData
import MyBestAITasksCore

@main
struct mybest_tasksApp: App {
    let container: ModelContainer
    let notificationManager: NotificationManaging
    
    init() {
        do {
            container = try ModelContainer(for: Goal.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        notificationManager = NotificationManager()
        notificationManager.requestAuthorization()
        
        // Migrate existing goals: populate startDate if nil
        migrateExistingGoals()
    }
    
    /// 既存のゴールの startDate が nil の場合、createdAt で更新する。
    private func migrateExistingGoals() {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Goal>()
        
        do {
            let goals = try context.fetch(descriptor)
            var migratedCount = 0
            
            for goal in goals {
                if goal.startDate == nil {
                    goal.startDate = goal.createdAt
                    migratedCount += 1
                }
            }
            
            if migratedCount > 0 {
                try context.save()
                print("✅ Migrated \(migratedCount) goals with startDate = createdAt")
            }
        } catch {
            print("⚠️ Failed to migrate existing goals: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Composition Root
            // We use the main context from the container for the repository
            let repository = GoalRepository(modelContext: container.mainContext)
            GoalListView(viewModel: GoalListViewModel(repository: repository))
        }
        .modelContainer(container)
    }
}
