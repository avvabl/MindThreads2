//
//  Task.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 17.06.2025.
//

import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID = UUID()
    var title: String = ""
    var isComplete: Bool = false
    var creationDate: Date = Date()
    var indentationLevel: Int = 0

    // Relationships
    var parentTask: Task?
    @Relationship(inverse: \Task.parentTask) var subtasks: [Task]?
    var list: TaskList?

    init(title: String, isComplete: Bool = false, creationDate: Date = Date(), indentationLevel: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isComplete = isComplete
        self.creationDate = creationDate
        self.indentationLevel = indentationLevel
    }
} 