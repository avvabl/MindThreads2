//
//  TaskList.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 17.06.2025.
//

import Foundation
import SwiftData

@Model
final class TaskList {
    var id: UUID = UUID()
    var name: String = ""

    // Relationship
    @Relationship(inverse: \Task.list) var tasks: [Task]?

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
} 