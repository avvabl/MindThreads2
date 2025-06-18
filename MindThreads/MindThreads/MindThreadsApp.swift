//
//  MindThreadsApp.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 17.06.2025.
//

import SwiftUI
import SwiftData

@main
struct MindThreadsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, TaskList.self])
    }
}
