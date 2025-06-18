# Build Plan: Cross-Platform To-Do List App

This document outlines the step-by-step process for building the cross-platform To-Do List application based on the Product Requirements Document (PRD.md).

## Phase 1: Project Setup & Data Model

### Step 1.1: Create Xcode Project
*   **Action:** Open Xcode and select "Create a new project."
*   **Template:** Choose the "Multiplatform" tab and select the "App" template.
*   **Product Name:** Set the Product Name to `MindThreads`.
*   **Organization Identifier:** Use a reverse domain name identifier (e.g., `com.yourcompany`).
*   **Interface:** Ensure "SwiftUI" is selected.
*   **Language:** Ensure "Swift" is selected.
*   **Storage:** Select "SwiftData" from the storage options.
*   **Include Tests:** (Optional) Decide whether to include Unit Tests and UI Tests.
*   **Location:** Choose a suitable location to save the project.

### Step 1.2: Configure SwiftData & iCloud Synchronization
*   **Initial Setup (Automatic):** Xcode will automatically set up a basic SwiftData stack with `ModelContainer` in the main `App` file. Verify this setup.
*   **Register All Models:** Ensure that both the `Task` and `TaskList` models are registered in the `modelContainer` modifier. For example: `.modelContainer(for: [Task.self, TaskList.self])`.
*   **iCloud Capabilities:**
    *   **Action:** Select the `MindThreads` project in the Xcode navigator, then select each target (iOS, iPadOS, macOS).
    *   **Signing & Capabilities:** Go to the "Signing & Capabilities" tab.
    *   **Add Capability:** Add the "iCloud" capability.
    *   **CloudKit:** Select "CloudKit" under iCloud services.
    *   **Containers:** Ensure a CloudKit container is selected or created for your app (e.g., `iCloud.com.yourcompany.MindThreads`). This will be essential for syncing.
*   **ModelContainer Configuration for iCloud:** Ensure your `ModelContainer` in the main `App` file is configured to use the CloudKit container you just created. This typically involves passing the container identifier to the `modelContainer` modifier.
*   **Implement basic list display and refreshing from SwiftData:** Use a SwiftUI `List` with a `ForEach` to iterate over the fetched tasks.

### Step 1.3: Define SwiftData Models (Task and TaskList)
*   **Create Model Files:** Create new Swift files (e.g., `Task.swift` and `TaskList.swift`) in your project.
*   **Task Model (`Task.swift`):
    *   **Code:** Define the `Task` class as a `@Model`.
    *   **Properties:**
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
*   **TaskList Model (`TaskList.swift`):
    *   **Code:** Define the `TaskList` class as a `@Model`.
    *   **Properties:**
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
*   **ModelContext Usage (Initial Test - Optional but Recommended):
    *   **Action:** Briefly add some sample code to your `ContentView` (or a temporary test view) to:
        *   Fetch all tasks from the `ModelContext`.
        *   Add a new sample `TaskList` and `Task` to the context.
        *   Delete a sample `Task`.
    *   **Purpose:** Verify that SwiftData is correctly initialized and basic CRUD operations work as expected.

## Phase 2: Core UI & Basic Task Management

### Step 2.1: Implement Main Task List View
*   Develop the `ContentView` (or similar main view) to display a list of `Task` items.
    *   **Scope Note:** For this phase, the view will operate on a single, default list. Multi-list management will be introduced in Phase 3.
*   **Empty State:** When no tasks exist, display a prompt encouraging users to start adding items (e.g., "Ready to get organized? Tap + to add your first task!" or similar encouraging message).
*   Design individual task rows with:
    *   A circular checkbox/toggle for `isComplete` status.
    *   The `title` as a text field, supporting long text input.
    *   Visual distinction for completed tasks (e.g., strike-through).
*   **Task Ordering:** New items are created at the bottom of the current list view.
*   **List Indicator:** Display small text under the floating action buttons indicating which list is currently active for task creation (e.g., "Adding to: Main List").

### Step 2.2: Implement "New" Task Button
*   Add the floating "New" button (plus icon) at the bottom of the homescreen.
*   **Manage Keyboard Focus:** Use the `@FocusState` property wrapper to programmatically control which text field is active.
*   Implement its action:
    *   Create a new, empty `Task` item and add it to the first (or default) list.
    *   Automatically bring up the keyboard and focus on the new task's title for immediate input by setting the `@FocusState` variable.

### Step 2.3: Implement Task Editing
*   Enable direct editing of a task's `title` by tapping on it or when a new task is created. This will also be managed using the `@FocusState` property wrapper.

### Step 2.4: Implement Task Deletion
*   Add functionality to delete tasks.
*   **Implementation:** For iOS/iPadOS, use the `.onDelete` modifier on the `ForEach` loop within the `List`. For cross-platform consistency, also implement deletion via a context menu (`.contextMenu`).

### Step 2.5: Implement Keyboard Management
*   **Tapping Outside:** Tapping outside a text field saves the current edit and dismisses the keyboard.
*   **Button Visibility:** When editing a task, the floating action buttons should be hidden under the keyboard (natural behavior due to bottom placement), but if user manages to tap the "New" button while editing, it will create a new task as normal.
*   **Focus Management:** Use `@FocusState` to control which text field is active and manage transitions between editing different tasks.

## Phase 3: Advanced Task Organization & Input

### Step 3.1: Implement Task Indentation and Parent-Child Relationship
*   Design the UI to visually represent task hierarchy (indentation).
    *   **Implementation:** In the task row view, add a `Spacer` with a dynamic `width` or apply leading `padding` based on the task's `indentationLevel` property.
*   Implement the logic to manage `parentTask` relationships within the `Task` model.

### Step 3.2: Implement Task List Management
*   **Context:** This step enables the "Task Categorization/Lists" feature from the PRD.
*   **UI for List Selection:**
    *   **iOS:** Modal view or navigation drill-down for list selection
    *   **iPadOS/macOS:** Sidebar for list selection
*   **Create New Lists:** Add UI controls (e.g., a button) allowing users to create new `TaskList` items.
*   **List Management Features:**
    *   **Collapsible Lists:** Allow users to collapse/expand lists in the sidebar/selection view
    *   **Deletable Lists:** Enable list deletion with confirmation dialog (prevent deletion of lists with tasks, or offer to move tasks to another list)
*   **Filter Tasks by List:** Update the main task view to only display tasks that belong to the currently selected `TaskList`.

### Step 3.3: Implement Drag and Drop Reordering
*   Enable drag-and-drop functionality for reordering tasks within the list.
*   **Implementation:** For hierarchical drag-and-drop, the simple `.onMove` modifier will be insufficient.
    *   Make the `Task` model conform to the `Transferable` protocol.
    *   Implement custom drop logic using the `.onDrop` modifier on the task rows to correctly handle changes in hierarchy and `indentationLevel`.
*   **Drag-and-Drop Design Decisions:**
    *   **Drop Zone Strategy:** Drop between tasks (like standard list reordering)
    *   **Indentation Rules:**
        *   Maximum nesting depth: 5 levels
        *   Prevent dragging a parent under its own children (circular reference prevention)
        *   When dragging a parent, collapse its children under it during drag if possible, otherwise prevent the operation
        *   When a parent is moved, all its children move with it; if placed under another parent, it becomes a child and its children become grandchildren
    *   **Visual Cues:** Display a thick line with a dot at the beginning showing the drop position and indentation level
    *   **Touch Interaction:** Long press to initiate drag operation

### Step 3.4: Integrate Speech-to-Text
*   **Request User Permissions:** This is a critical step.
    *   **Action:** In the `Info.plist` file for each target (iOS, iPadOS, macOS), add the following keys with descriptive strings explaining why the app needs access:
        *   `NSSpeechRecognitionUsageDescription`: "This app uses speech recognition to transcribe your voice into new tasks."
        *   `NSMicrophoneUsageDescription`: "This app needs microphone access to create new tasks from your voice."
*   Integrate Apple's `Speech` framework for voice recognition.
*   Implement the floating microphone button's interaction:
    *   On tap and hold: Play chime, turn button red, insert empty `Task` to list.
    *   During hold: Begin real-time transcription (visual feedback may be added later if needed).
    *   On release: Populate task title with transcribed text, play completion chime, finalize task creation.
*   **Error Handling:**
    *   **Speech Recognition Failure:** Display snackbar with error message, then automatically open keyboard for manual text entry on the created task.
    *   **Permission Denied:** Show popup explaining that microphone permission is required for voice input functionality.
    *   **No Speech Detected:** After timeout, open keyboard for manual entry.

## Phase 4: Platform-Specific UI & Enhancements

### Step 4.1: Implement "Done Items" View
*   Add the "Done Items" button at the top of the main list view.
*   **Manage View Presentation:** Use a `@State` variable (e.g., `@State private var isShowingDoneItems = false`) to toggle the presentation of the view.
*   Implement the secondary view for completed tasks:
    *   **iOS:** Present as a sheet using the `.sheet(isPresented: ...)` modifier.
    *   **iPadOS/macOS:** Present as a separate page/view (full screen navigation) rather than a popover.
*   Display a list of completed tasks within this view.

### Step 4.2: Implement Homescreen Widgets
*   Create a new Widget Extension target.
*   **Frameworks:** Use `WidgetKit` for the UI and `AppIntents` to handle user interactions (like marking a task as complete from the widget).
*   Design and implement two separate widget types:
    *   **Widget Type 1 - Task List Widget:**
        *   Display top items from a selected list (defaults to main list)
        *   Allow marking tasks as complete directly from widget
        *   Multiple size variants (small, medium, large)
        *   Configurable list selection in widget settings
    *   **Widget Type 2 - Quick Entry Widget:**
        *   Contains create button and record button
        *   Configurable list selection for where new tasks are added (defaults to main list)
        *   Multiple size variants
        *   Direct shortcuts to app's voice recording and text entry functions

### Step 4.3: Implement Error Handling (Snackbars)
*   Develop a reusable snackbar component for displaying transient, single-line error messages.
    *   **Implementation Strategy:** A robust approach is to create a custom `ViewModifier` or manage the snackbar's presentation in a `ZStack` at the root of the view hierarchy (e.g., in `ContentView`).
*   **Triggering Errors:** Error conditions (e.g., from `catch` blocks in data operations or sync failures) should be captured and published to the UI layer, for example, using an `Observable` object that holds the current error message. The UI will observe this object and trigger the snackbar presentation when an error is published.
*   Integrate snackbars to display error types for critical operations (e.g., iCloud sync failures, data persistence issues).

## Phase 5: Testing & Refinement

### Step 5.1: Cross-Platform UI/UX Refinement
*   Review and adjust UI layouts and interactions to ensure optimal experience across iOS, iPadOS, and macOS.
*   Address any platform-specific UI nuances.

### Step 5.2: Feature Testing
*   Conduct thorough testing of all implemented features (task management, drag-and-drop, speech-to-text, sync, widgets, error handling).

### Step 5.3: Performance & Stability
*   Optimize for performance and ensure app stability.

### Step 5.4: Accessibility Review
*   Verify adherence to Apple's accessibility guidelines.
*   **Action:** Use Apple's **Accessibility Inspector** tool (included with Xcode) to check that all UI elements have correct labels, values, hints, and traits. 