//
//  ContentView.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 17.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.creationDate) private var tasks: [Task]
    @Query(sort: \TaskList.name) private var taskLists: [TaskList]
    
    // Focus state management
    @FocusState private var focusedTaskID: UUID?
    
    // Filter tasks for the current main list
    private var mainListTasks: [Task] {
        guard let mainList = taskLists.first(where: { $0.name == "Main" }) else {
            return []
        }
        return tasks.filter { $0.list?.id == mainList.id }
    }
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Main content area
                if mainListTasks.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Ready to get organized?")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Tap + to add your first task!")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                } else {
                    // Task list
                    List {
                        ForEach(mainListTasks, id: \.id) { task in
                            TaskRowView(
                                task: task,
                                focusedTaskID: $focusedTaskID,
                                onDelete: { taskToDelete in
                                    deleteSpecificTask(taskToDelete)
                                },
                                onCreateTaskBelow: { currentTask in
                                    createTaskBelow(currentTask)
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteTask)
                    }
                    .listStyle(PlainListStyle())
                }
                
                // List indicator at bottom
                HStack {
                    Spacer()
                    Text("Adding to: Main")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.bottom, 80) // Space for floating button
            }
            .background(
                // Tap outside to dismiss keyboard
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedTaskID = nil
                    }
            )
            
            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "plus") {
                        addNewTask()
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            createDefaultListIfNeeded()
        }
    }
    
    // Task 2.1.2: Create Default TaskList on App Launch
    private func createDefaultListIfNeeded() {
        if taskLists.isEmpty {
            let mainList = TaskList(name: "Main")
            modelContext.insert(mainList)
            try? modelContext.save()
        }
    }
    
    // Task 2.2.3: Implement Task Creation Logic
    private func addNewTask() {
        guard let currentList = taskLists.first(where: { $0.name == "Main" }) else {
            return
        }
        
        let newTask = Task(title: "")
        newTask.list = currentList
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            // Focus on new task after a brief delay to ensure UI is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedTaskID = newTask.id
            }
        } catch {
            print("Error saving new task: \(error)")
        }
    }
    
    // Task 2.5.5: Create task below current task
    private func createTaskBelow(_ currentTask: Task) {
        guard let currentList = currentTask.list else { return }
        
        let newTask = Task(
            title: "",
            indentationLevel: currentTask.indentationLevel
        )
        newTask.list = currentList
        newTask.parentTask = currentTask.parentTask
        
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            // Focus on the new task after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedTaskID = newTask.id
            }
        } catch {
            print("Error creating task below: \(error)")
        }
    }
    
    // Task 2.4.1: Implement Task Deletion (Swipe-to-delete)
    private func deleteTask(at offsets: IndexSet) {
        withAnimation(.easeInOut(duration: 0.3)) {
            for index in offsets {
                let taskToDelete = mainListTasks[index]
                deleteSpecificTask(taskToDelete)
            }
        }
    }
    
    // Task 2.4.2: Centralized task deletion for both swipe and context menu
    private func deleteSpecificTask(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Clear focus if we're deleting the focused task
            if focusedTaskID == task.id {
                focusedTaskID = nil
            }
            
            // Handle deletion of tasks with subtasks (future-proofing)
            deleteTaskAndSubtasks(task)
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }
    
    // Helper function to handle hierarchical deletion
    private func deleteTaskAndSubtasks(_ task: Task) {
        // Get all subtasks before deleting the parent
        let subtasks = task.subtasks ?? []
        
        // Recursively delete subtasks first
        for subtask in subtasks {
            deleteTaskAndSubtasks(subtask)
        }
        
        // Delete the task itself
        modelContext.delete(task)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, TaskList.self], inMemory: true)
}
