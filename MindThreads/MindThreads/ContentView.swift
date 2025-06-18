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
    
    var body: some View {
        VStack {
            Text("MindThreads")
                .font(.largeTitle)
                .padding()
            
            Text("Tasks: \(tasks.count)")
            Text("Lists: \(taskLists.count)")
            
            Button("Add Test Data") {
                addTestData()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            List {
                Section("Task Lists") {
                    ForEach(taskLists, id: \.id) { list in
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.headline)
                            Text("Tasks: \(list.tasks?.count ?? 0)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("All Tasks") {
                    ForEach(tasks, id: \.id) { task in
                        HStack {
                            Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isComplete ? .green : .gray)
                            Text(task.title)
                            Spacer()
                            Text("Level: \(task.indentationLevel)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func addTestData() {
        print("🔍 Adding test data...")
        
        let mainList = TaskList(name: "Main")
        modelContext.insert(mainList)
        print("✅ Inserted mainList: \(mainList.name)")
        
        let task1 = Task(title: "Test Task 1")
        task1.list = mainList
        modelContext.insert(task1)
        print("✅ Inserted task1: \(task1.title)")
        
        let task2 = Task(title: "Test Subtask", indentationLevel: 1)
        task2.list = mainList
        task2.parentTask = task1
        modelContext.insert(task2)
        print("✅ Inserted task2: \(task2.title)")
        
        let personalList = TaskList(name: "Personal")
        modelContext.insert(personalList)
        print("✅ Inserted personalList: \(personalList.name)")
        
        let task3 = Task(title: "Personal Task", isComplete: true)
        task3.list = personalList
        modelContext.insert(task3)
        print("✅ Inserted task3: \(task3.title)")
        
        do {
            try modelContext.save()
            print("✅ Successfully saved to modelContext")
        } catch {
            print("❌ Error saving: \(error)")
        }
        print("📊 Current counts - Tasks: \(tasks.count), Lists: \(taskLists.count)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, TaskList.self], inMemory: true)
}
