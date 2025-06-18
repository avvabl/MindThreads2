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
    
    // Binding for shared focus management from ContentView
    var focusedTaskID: FocusState<UUID?>.Binding
    
    // Callbacks for actions
    var onDelete: ((Task) -> Void)?
    var onCreateTaskBelow: ((Task) -> Void)?
    
    // Computed property to check if this task is focused
    private var isFocused: Bool {
        focusedTaskID.wrappedValue == task.id
    }
    
    // Safe indentation level
    private var safeIndentationLevel: Int {
        max(0, min(5, task.indentationLevel))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Indentation
            ForEach(0..<safeIndentationLevel, id: \.self) { _ in
                Spacer().frame(width: 20)
            }
            
            // Checkbox
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
                .focused(focusedTaskID, equals: task.id) // Direct binding
                .strikethrough(task.isComplete)
                .foregroundColor(task.isComplete ? .secondary : .primary)
                .font(.body)
                .lineLimit(1...3)
                .submitLabel(.done) // Use "Done" which also triggers onSubmit
                .onSubmit(handleReturnKey)
                .onChange(of: task.title) { _, _ in
                    try? modelContext.save()
                }
                .onChange(of: isFocused) { _, isNowFocused in
                    if !isNowFocused {
                        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        try? modelContext.save()
                    }
                }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isFocused ? Color.blue.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            focusedTaskID.wrappedValue = task.id
        }
        .contextMenu {
            contextMenuItems
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        Button(role: .destructive, action: deleteTask) {
            Label("Delete Task", systemImage: "trash")
        }
        
        Button(action: duplicateTask) {
            Label("Duplicate Task", systemImage: "doc.on.doc")
        }
        
        Button(action: toggleCompletion) {
            Label(
                task.isComplete ? "Mark as Incomplete" : "Mark as Complete",
                systemImage: task.isComplete ? "circle" : "checkmark.circle"
            )
        }
    }
    
    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            task.isComplete.toggle()
        }
        try? modelContext.save()
    }
    
    private func handleReturnKey() {
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Use callback to create a new task below
        onCreateTaskBelow?(task)
        
        try? modelContext.save()
    }
    
    private func deleteTask() {
        onDelete?(task)
    }
    
    private func duplicateTask() {
        let duplicatedTask = Task(
            title: task.title,
            isComplete: false,
            indentationLevel: safeIndentationLevel
        )
        duplicatedTask.list = task.list
        duplicatedTask.parentTask = task.parentTask
        
        modelContext.insert(duplicatedTask)
        
        do {
            try modelContext.save()
            // Give SwiftUI a moment to render the new row before focusing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedTaskID.wrappedValue = duplicatedTask.id
            }
        } catch {
            print("Error duplicating task: \(error)")
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

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowPreviewWrapper()
    }
    
    struct TaskRowPreviewWrapper: View {
        @FocusState private var focusedTaskID: UUID?
        private let sampleTask: Task
        private let container: ModelContainer
        
        init() {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: Task.self, TaskList.self, configurations: config)
            let task = Task(title: "Sample Task")
            container.mainContext.insert(task)
            
            self.container = container
            self.sampleTask = task
        }
        
        var body: some View {
            TaskRowView(
                task: sampleTask,
                focusedTaskID: $focusedTaskID
            )
            .modelContainer(container)
            .padding()
        }
    }
} 