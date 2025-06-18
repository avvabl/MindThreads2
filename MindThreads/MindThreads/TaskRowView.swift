//
//  TaskRowView.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 18.06.2025.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isTextFieldFocused: Bool
    
    // Binding for shared focus management
    var focusedTaskID: FocusState<UUID?>.Binding?
    
    // Optional deletion callback for context menu
    var onDelete: ((Task) -> Void)?
    
    // Optional callback for creating new task below
    var onCreateTaskBelow: ((Task) -> Void)?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Indentation spacing for hierarchy
            ForEach(0..<task.indentationLevel, id: \.self) { _ in
                Spacer()
                    .frame(width: 20)
            }
            
            // Checkbox button
            Button(action: toggleCompletion) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isComplete ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(task.isComplete ? "Mark as incomplete" : "Mark as complete")
            
            // Title text field
            TextField("New Task", text: $task.title, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isTextFieldFocused)
                .strikethrough(task.isComplete)
                .foregroundColor(task.isComplete ? .secondary : .primary)
                .font(.body)
                .lineLimit(1...3) // Allow up to 3 lines
                .submitLabel(.done) // Show "Done" on return key
                .onSubmit {
                    handleReturnKey()
                }
                .onChange(of: task.title) { _, newValue in
                    // Auto-save changes
                    try? modelContext.save()
                    
                    // If user clears the text completely, we might want to delete the task
                    // But we'll be forgiving and just leave empty tasks for now
                }
                .onChange(of: isTextFieldFocused) { _, isFocused in
                    // Update shared focus state
                    if isFocused {
                        focusedTaskID?.wrappedValue = task.id
                    } else if focusedTaskID?.wrappedValue == task.id {
                        focusedTaskID?.wrappedValue = nil
                    }
                    
                    // When losing focus, trim whitespace
                    if !isFocused {
                        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        try? modelContext.save()
                    }
                }
                .onChange(of: focusedTaskID?.wrappedValue) { _, focusedID in
                    // Update local focus state based on shared state
                    if focusedID == task.id && !isTextFieldFocused {
                        isTextFieldFocused = true
                    } else if focusedID != task.id && isTextFieldFocused {
                        isTextFieldFocused = false
                    }
                }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            // Subtle highlight for focused state
            RoundedRectangle(cornerRadius: 6)
                .fill(isTextFieldFocused ? Color.blue.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap anywhere on the row to focus the text field
            isTextFieldFocused = true
            focusedTaskID?.wrappedValue = task.id
        }
        .contextMenu {
            // Task 2.4.2: Context Menu for Cross-Platform Deletion
            Button(action: {
                deleteTask()
            }) {
                Label("Delete Task", systemImage: "trash")
            }
            .foregroundColor(.red)
            
            Button(action: {
                duplicateTask()
            }) {
                Label("Duplicate Task", systemImage: "doc.on.doc")
            }
            
            Button(action: {
                toggleCompletion()
            }) {
                Label(
                    task.isComplete ? "Mark as Incomplete" : "Mark as Complete",
                    systemImage: task.isComplete ? "circle" : "checkmark.circle"
                )
            }
        }
    }
    
    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            task.isComplete.toggle()
        }
        try? modelContext.save()
    }
    
    // Task 2.5.4: Handle Return Key Behavior
    private func handleReturnKey() {
        // Trim the current task title
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the task has content, create a new task below
        if !task.title.isEmpty {
            if let onCreateTaskBelow = onCreateTaskBelow {
                onCreateTaskBelow(task)
            } else {
                // Fallback: just dismiss keyboard
                isTextFieldFocused = false
                focusedTaskID?.wrappedValue = nil
            }
        } else {
            // If empty task, just dismiss keyboard
            isTextFieldFocused = false
            focusedTaskID?.wrappedValue = nil
        }
        
        try? modelContext.save()
    }
    
    // Task deletion with proper cleanup
    private func deleteTask() {
        // Clear focus if this task is focused
        if focusedTaskID?.wrappedValue == task.id {
            focusedTaskID?.wrappedValue = nil
        }
        
        // Use callback if provided, otherwise delete directly
        if let onDelete = onDelete {
            onDelete(task)
        } else {
            // Fallback: delete directly (with subtasks)
            deleteTaskAndSubtasks(task)
            try? modelContext.save()
        }
    }
    
    // Helper function for hierarchical deletion
    private func deleteTaskAndSubtasks(_ task: Task) {
        let subtasks = task.subtasks ?? []
        for subtask in subtasks {
            deleteTaskAndSubtasks(subtask)
        }
        modelContext.delete(task)
    }
    
    // Duplicate task functionality
    private func duplicateTask() {
        let duplicatedTask = Task(
            title: task.title,
            isComplete: false, // Reset completion status
            indentationLevel: task.indentationLevel
        )
        duplicatedTask.list = task.list
        duplicatedTask.parentTask = task.parentTask
        
        modelContext.insert(duplicatedTask)
        try? modelContext.save()
        
        // Focus on the duplicated task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedTaskID?.wrappedValue = duplicatedTask.id
        }
    }
}

// Extension for strikethrough text
extension View {
    func strikethrough(_ isActive: Bool) -> some View {
        self.overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.primary)
                .opacity(isActive ? 0.6 : 0)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, TaskList.self, configurations: config)
    
    let sampleTask = Task(title: "Sample Task")
    container.mainContext.insert(sampleTask)
    
    return TaskRowView(task: sampleTask)
        .modelContainer(container)
        .padding()
} 