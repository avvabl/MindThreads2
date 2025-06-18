# Phase 1: Detailed Task Breakdown - Project Setup & Data Model

This document provides a granular, step-by-step breakdown of Phase 1 tasks for the MindThreads project. Each task includes specific actions, expected outcomes, and verification steps.

## Overview
Phase 1 establishes the foundation of the MindThreads app by setting up the Xcode project, configuring SwiftData with iCloud synchronization, and defining the core data models.

---

## Step 1.1: Create Xcode Project

### Task 1.1.1: Initialize New Xcode Project
**Action:** Create the base project structure
- [ ] Open Xcode (ensure you have Xcode 15+ for SwiftData support)
- [ ] Select "Create a new Xcode project"
- [ ] Choose "Multiplatform" tab
- [ ] Select "App" template
- [ ] Click "Next"

**Expected Outcome:** Xcode template selection screen is ready

### Task 1.1.2: Configure Project Settings
**Action:** Set up project configuration
- [ ] **Product Name:** `MindThreads`
- [ ] **Organization Identifier:** `com.avvab.MindThreads`
- [ ] **Bundle Identifier:** (auto-generated as `com.avvab.MindThreads`)
- [ ] **Language:** Swift
- [ ] **Interface:** SwiftUI
- [ ] **Use Core Data:** ❌ (Leave unchecked - we're using SwiftData)
- [ ] **Include Tests:** ✅ (Recommended for later phases)
- [ ] Click "Next"

**Expected Outcome:** Project configuration is properly set

### Task 1.1.3: Choose Project Location
**Action:** Save project to workspace
- [ ] Navigate to your desired project location
- [ ] Create folder if needed: `/Users/avvablababidi/Downloads/cursor/MindThreads/`
- [ ] Ensure "Create Git repository" is checked ✅
- [ ] Click "Create"

**Expected Outcome:** Xcode project is created with proper folder structure

### Task 1.1.4: Verify Project Structure
**Action:** Confirm project setup is correct
- [ ] Verify you see three targets in the navigator:
  - `MindThreads (iOS)`
  - `MindThreads (macOS)`
  - `MindThreadsTests`
- [ ] Confirm `MindThreadsApp.swift` exists in Shared folder
- [ ] Confirm `ContentView.swift` exists in Shared folder
- [ ] Verify project builds successfully (⌘+B)

**Expected Outcome:** Project compiles without errors on all platforms

---

## Step 1.2: Configure SwiftData & iCloud Synchronization

### Task 1.2.1: Verify SwiftData Setup
**Action:** Ensure SwiftData is properly integrated
- [ ] Open `MindThreadsApp.swift`
- [ ] Verify `import SwiftData` is present
- [ ] Verify `@main` app struct exists
- [ ] Confirm there's a `.modelContainer()` modifier (may be basic initially)

**Expected Outcome:** SwiftData imports and basic setup are in place

### Task 1.2.2: Add iCloud Capabilities to iOS Target
**Action:** Enable iCloud for iOS
- [ ] Select `MindThreads` project in navigator
- [ ] Select `MindThreads (iOS)` target
- [ ] Go to "Signing & Capabilities" tab
- [ ] Click "+" to add capability
- [ ] Add "iCloud" capability
- [ ] Under iCloud Services, check "CloudKit" ✅
- [ ] Note the Container ID (should be `iCloud.com.avvab.MindThreads`)

**Expected Outcome:** iOS target has iCloud CloudKit capability enabled

### Task 1.2.3: Add iCloud Capabilities to macOS Target
**Action:** Enable iCloud for macOS
- [ ] Select `MindThreads (macOS)` target
- [ ] Go to "Signing & Capabilities" tab
- [ ] Click "+" to add capability
- [ ] Add "iCloud" capability
- [ ] Under iCloud Services, check "CloudKit" ✅
- [ ] Ensure same Container ID: `iCloud.com.avvab.MindThreads`

**Expected Outcome:** macOS target has iCloud CloudKit capability enabled

### Task 1.2.4: Configure Development Team
**Action:** Set up code signing
- [ ] In both iOS and macOS targets
- [ ] Under "Signing & Capabilities"
- [ ] Select your Apple Developer Team from "Team" dropdown
- [ ] Verify "Automatically manage signing" is checked ✅
- [ ] Resolve any signing issues that appear

**Expected Outcome:** Both targets have proper code signing configured

### Task 1.2.5: Update ModelContainer Configuration
**Action:** Prepare for CloudKit integration
- [ ] Open `MindThreadsApp.swift`
- [ ] Locate the `.modelContainer()` modifier
- [ ] Update it to prepare for CloudKit (we'll add models in Step 1.3)
- [ ] For now, ensure it looks like: `.modelContainer(for: [])`

**Expected Outcome:** ModelContainer is ready for model registration

---

## Step 1.3: Define SwiftData Models

### Task 1.3.1: Create Task Model File
**Action:** Set up the Task data model
- [ ] Right-click on project in navigator
- [ ] Select "New File..."
- [ ] Choose "Swift File"
- [ ] Name it `Task.swift`
- [ ] Ensure it's added to both iOS and macOS targets ✅

**Expected Outcome:** Empty `Task.swift` file is created

### Task 1.3.2: Implement Task Model
**Action:** Define the Task SwiftData model
- [ ] Open `Task.swift`
- [ ] Add the complete Task model code:

```swift
import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var isComplete: Bool
    var creationDate: Date
    var indentationLevel: Int

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
```

**Expected Outcome:** Task model is fully implemented with all properties and relationships

### Task 1.3.3: Create TaskList Model File
**Action:** Set up the TaskList data model
- [ ] Right-click on project in navigator
- [ ] Select "New File..."
- [ ] Choose "Swift File"
- [ ] Name it `TaskList.swift`
- [ ] Ensure it's added to both iOS and macOS targets ✅

**Expected Outcome:** Empty `TaskList.swift` file is created

### Task 1.3.4: Implement TaskList Model
**Action:** Define the TaskList SwiftData model
- [ ] Open `TaskList.swift`
- [ ] Add the complete TaskList model code:

```swift
import Foundation
import SwiftData

@Model
final class TaskList {
    @Attribute(.unique) var id: UUID
    var name: String

    // Relationship
    @Relationship(inverse: \Task.list) var tasks: [Task]?

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
```

**Expected Outcome:** TaskList model is fully implemented

### Task 1.3.5: Register Models in ModelContainer
**Action:** Connect models to SwiftData container
- [ ] Open `MindThreadsApp.swift`
- [ ] Import both models (they should be available automatically)
- [ ] Update the `.modelContainer()` modifier:
  ```swift
  .modelContainer(for: [Task.self, TaskList.self])
  ```

**Expected Outcome:** Both models are registered with SwiftData

### Task 1.3.6: Test Basic SwiftData Operations
**Action:** Verify data models work correctly
- [ ] Open `ContentView.swift`
- [ ] Add basic SwiftData testing code temporarily:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @Query private var taskLists: [TaskList]
    
    var body: some View {
        VStack {
            Text("MindThreads")
                .font(.largeTitle)
            
            Text("Tasks: \(tasks.count)")
            Text("Lists: \(taskLists.count)")
            
            Button("Add Test Data") {
                addTestData()
            }
            .padding()
        }
        .padding()
    }
    
    private func addTestData() {
        let mainList = TaskList(name: "Main")
        modelContext.insert(mainList)
        
        let task = Task(title: "Test Task")
        task.list = mainList
        modelContext.insert(task)
        
        try? modelContext.save()
    }
}
```

**Expected Outcome:** Test UI displays and can create sample data

### Task 1.3.7: Test Cross-Platform Compilation
**Action:** Ensure models work on all platforms
- [ ] Select iOS simulator
- [ ] Build and run (⌘+R)
- [ ] Verify app launches without crashes
- [ ] Test "Add Test Data" button
- [ ] Switch to macOS target
- [ ] Build and run (⌘+R)
- [ ] Verify app launches without crashes
- [ ] Test "Add Test Data" button

**Expected Outcome:** App runs successfully on both iOS and macOS with functional data models

### Task 1.3.8: Test iCloud Sync Preparation
**Action:** Prepare for CloudKit synchronization
- [ ] Run app on device (if available) or simulator
- [ ] Add test data using the button
- [ ] Check for any CloudKit-related errors in console
- [ ] Verify data persists between app launches

**Expected Outcome:** Data persists locally, no CloudKit errors in console

---

## Phase 1 Completion Checklist

Before moving to Phase 2, verify all items are completed:

### Project Setup ✅
- [ ] Xcode project created with correct naming and organization ID
- [ ] All three targets (iOS, macOS, Tests) are present and configured
- [ ] Project builds successfully on both platforms

### iCloud Configuration ✅
- [ ] CloudKit capability added to both iOS and macOS targets
- [ ] Container ID is set to `iCloud.com.avvab.MindThreads`
- [ ] Code signing is properly configured for both targets

### Data Models ✅
- [ ] `Task.swift` model is implemented with all required properties
- [ ] `TaskList.swift` model is implemented with all required properties
- [ ] Both models are registered in the ModelContainer
- [ ] Parent-child relationships between tasks are properly defined
- [ ] Task-to-TaskList relationships are properly defined

### Testing ✅
- [ ] App launches successfully on iOS
- [ ] App launches successfully on macOS
- [ ] SwiftData operations (insert, query) work correctly
- [ ] Data persists between app launches
- [ ] No crashes or SwiftData-related errors in console

### Code Quality ✅
- [ ] All code compiles without warnings
- [ ] Models follow SwiftData best practices
- [ ] Proper use of @Model, @Attribute, and @Relationship decorators

---

## Next Steps
Upon successful completion of Phase 1, proceed to **Phase 2: Core UI & Basic Task Management** where you'll:
- Remove test code from ContentView
- Implement the main task list UI
- Add the floating action buttons
- Implement basic task CRUD operations 