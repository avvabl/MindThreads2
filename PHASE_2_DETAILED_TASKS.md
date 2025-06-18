# Phase 2: Detailed Task Breakdown - Core UI & Basic Task Management

This document provides a granular, step-by-step breakdown of Phase 2 tasks for the MindThreads project. Each task includes specific actions, expected outcomes, and verification steps.

## Overview
Phase 2 transforms the test interface into a functional To-Do app by implementing the main task list UI, floating action buttons, task editing, deletion, and keyboard management. We'll work with a single default list for now.

---

## Step 2.1: Implement Main Task List View

### Task 2.1.1: Remove Test Code and Reset ContentView
**Action:** Clean up the test interface and prepare for production UI
- [ ] Open `ContentView.swift`
- [ ] Remove all debug print statements from `addTestData()` function
- [ ] Remove the test "Add Test Data" button from the UI
- [ ] Remove the debug text showing counts
- [ ] Keep the `@Query` properties for tasks and taskLists (we'll need them)
- [ ] Reset to a clean, minimal UI structure

**Expected Outcome:** Clean ContentView ready for production UI implementation

### Task 2.1.2: Create Default TaskList on App Launch
**Action:** Ensure there's always a "Main" list available
- [ ] Modify `ContentView` to check for existing lists on appear
- [ ] If no lists exist, create a default "Main" TaskList
- [ ] Implement this in a `.onAppear` modifier

**Code Structure:**
```swift
.onAppear {
    createDefaultListIfNeeded()
}

private func createDefaultListIfNeeded() {
    if taskLists.isEmpty {
        let mainList = TaskList(name: "Main")
        modelContext.insert(mainList)
        try? modelContext.save()
    }
}
```

**Expected Outcome:** App always has a "Main" list available for task creation

### Task 2.1.3: Implement Empty State UI
**Action:** Create encouraging empty state when no tasks exist
- [ ] Design empty state view with encouraging message
- [ ] Add an icon (like a checkmark or list icon)
- [ ] Include text like "Ready to get organized? Tap + to add your first task!"
- [ ] Show this when `tasks.isEmpty`

**Expected Outcome:** Users see a welcoming message when they first open the app

### Task 2.1.4: Design Individual Task Row Component
**Action:** Create reusable task row view
- [ ] Create new SwiftUI file: `TaskRowView.swift`
- [ ] Include circular checkbox/toggle for `isComplete` status
- [ ] Add text field for `title` that supports long text
- [ ] Implement visual distinction for completed tasks (strike-through, gray color)
- [ ] Add leading padding based on `indentationLevel` for hierarchy
- [ ] Make the row tappable to focus text field

**Code Structure:**
```swift
struct TaskRowView: View {
    @Bindable var task: Task
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            // Indentation spacing
            ForEach(0..<task.indentationLevel, id: \.self) { _ in
                Spacer().frame(width: 20)
            }
            
            // Checkbox
            Button(action: { task.isComplete.toggle() }) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
            }
            
            // Title text field
            TextField("Task", text: $task.title)
                .focused($isTextFieldFocused)
                .strikethrough(task.isComplete)
            
            Spacer()
        }
    }
}
```

**Expected Outcome:** Reusable task row component with all interactive elements

### Task 2.1.5: Implement Main List View Structure
**Action:** Create the main task list layout
- [ ] Use `List` to display tasks
- [ ] Filter tasks to show only those from the current list (Main for now)
- [ ] Order tasks by creation date
- [ ] Integrate `TaskRowView` for each task
- [ ] Add list header with list name

**Expected Outcome:** Clean list view showing tasks from the Main list

### Task 2.1.6: Add List Indicator Below Screen
**Action:** Show which list is currently active for task creation
- [ ] Add small text at bottom of screen
- [ ] Display "Adding to: [List Name]" 
- [ ] Position it above where floating buttons will be
- [ ] Use secondary color and small font
- [ ] Center the text

**Expected Outcome:** Users can see which list new tasks will be added to

---

## Step 2.2: Implement "New" Task Button

### Task 2.2.1: Create Floating Action Button Style
**Action:** Design the floating action button appearance
- [ ] Create reusable `FloatingActionButton.swift` component
- [ ] Use circular background with system blue color
- [ ] Add drop shadow for floating appearance
- [ ] Include proper sizing (56x56 points recommended)
- [ ] Support custom icon and action

**Code Structure:**
```swift
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}
```

**Expected Outcome:** Reusable floating button component

### Task 2.2.2: Position Floating Buttons at Bottom
**Action:** Place floating buttons in bottom-right corner
- [ ] Use `ZStack` to overlay buttons on main content
- [ ] Position in bottom-trailing with proper padding
- [ ] Account for safe area insets
- [ ] Create space for two buttons (+ and microphone for later)
- [ ] For now, just implement the "+" button

**Expected Outcome:** Plus button floats in bottom-right corner

### Task 2.2.3: Implement Task Creation Logic
**Action:** Create new task functionality
- [ ] Add `@FocusState` to ContentView to manage text field focus
- [ ] Implement `addNewTask()` function
- [ ] Create new task with empty title
- [ ] Assign to current list (Main)
- [ ] Add to bottom of list (sort by creation date)
- [ ] Insert into modelContext and save

**Code Structure:**
```swift
@FocusState private var focusedTaskID: UUID?

private func addNewTask() {
    let currentList = taskLists.first { $0.name == "Main" }
    let newTask = Task(title: "")
    newTask.list = currentList
    modelContext.insert(newTask)
    try? modelContext.save()
    
    // Focus on new task
    focusedTaskID = newTask.id
}
```

**Expected Outcome:** Plus button creates new task and focuses text field

### Task 2.2.4: Connect Focus Management
**Action:** Link focus state to task rows
- [ ] Pass `focusedTaskID` binding to TaskRowView
- [ ] Update TaskRowView to use the shared focus state
- [ ] Ensure keyboard appears when new task is created
- [ ] Test focus management across different tasks

**Expected Outcome:** New tasks automatically get keyboard focus

---

## Step 2.3: Implement Task Editing

### Task 2.3.1: Enable Direct Text Editing
**Action:** Make task titles directly editable
- [ ] Ensure TextField in TaskRowView is properly bound to `task.title`
- [ ] Test that changes are automatically saved (SwiftData should handle this)
- [ ] Verify long text support with text wrapping if needed
- [ ] Test editing existing tasks

**Expected Outcome:** Users can tap any task title and edit it directly

### Task 2.3.2: Implement Multi-line Text Support
**Action:** Handle long task descriptions
- [ ] Consider using TextEditor instead of TextField for multi-line support
- [ ] Or implement dynamic height TextField
- [ ] Test with very long task titles
- [ ] Ensure proper text wrapping and display

**Expected Outcome:** Task titles can handle long text gracefully

### Task 2.3.3: Add Focus State Visual Feedback
**Action:** Show when a task is being edited
- [ ] Add visual indicators for focused text field
- [ ] Consider border highlight or background change
- [ ] Ensure accessibility for focused state
- [ ] Test focus visual feedback

**Expected Outcome:** Clear visual indication when editing a task

---

## Step 2.4: Implement Task Deletion

### Task 2.4.1: Add Swipe-to-Delete for iOS/iPadOS
**Action:** Implement native deletion gesture
- [ ] Add `.onDelete` modifier to ForEach in the List
- [ ] Implement `deleteTask(at offsets:)` function
- [ ] Remove task from modelContext
- [ ] Handle deletion of tasks with subtasks (for future hierarchy)

**Code Structure:**
```swift
.onDelete(perform: deleteTask)

private func deleteTask(at offsets: IndexSet) {
    withAnimation {
        for index in offsets {
            let taskToDelete = currentListTasks[index]
            modelContext.delete(taskToDelete)
        }
        try? modelContext.save()
    }
}
```

**Expected Outcome:** Users can swipe left to delete tasks on iOS

### Task 2.4.2: Add Context Menu for Cross-Platform Deletion
**Action:** Provide deletion option via long press
- [ ] Add `.contextMenu` modifier to TaskRowView
- [ ] Include "Delete" option with trash icon
- [ ] Ensure works on both iOS and macOS
- [ ] Add confirmation if needed

**Expected Outcome:** Long press shows delete option on all platforms

### Task 2.4.3: Handle Edge Cases for Deletion
**Action:** Manage deletion scenarios
- [ ] Test deleting all tasks (should show empty state)
- [ ] Test deleting tasks while editing another task
- [ ] Ensure focus management works correctly after deletion
- [ ] Test rapid deletion scenarios

**Expected Outcome:** Deletion works smoothly in all scenarios

---

## Step 2.5: Implement Keyboard Management

### Task 2.5.1: Implement Tap-Outside-to-Save
**Action:** Save and dismiss keyboard when user taps outside
- [ ] Add invisible background tap gesture to ContentView
- [ ] When tapped, set `focusedTaskID` to nil
- [ ] Ensure this saves current edits
- [ ] Test that it doesn't interfere with other UI interactions

**Code Structure:**
```swift
.background(
    Color.clear
        .contentShape(Rectangle())
        .onTapGesture {
            focusedTaskID = nil // Dismiss keyboard
        }
)
```

**Expected Outcome:** Tapping outside text fields dismisses keyboard and saves

### Task 2.5.2: Manage Button Visibility with Keyboard
**Action:** Handle floating button behavior during editing
- [ ] The floating buttons should naturally be hidden behind keyboard
- [ ] Test that buttons are accessible when keyboard is dismissed
- [ ] Ensure if user somehow taps "+" while editing, it still works
- [ ] No special code needed - let natural keyboard behavior handle this

**Expected Outcome:** Floating buttons behave correctly with keyboard

### Task 2.5.3: Implement Focus Chain Management
**Action:** Handle focus transitions between tasks
- [ ] Test editing one task, then tapping another
- [ ] Ensure smooth focus transitions
- [ ] Verify that changes are saved when focus moves
- [ ] Test creating new task while editing another

**Expected Outcome:** Smooth focus management between multiple tasks

### Task 2.5.4: Add Return Key Behavior
**Action:** Handle return key press in text fields
- [ ] When user presses return, consider dismissing keyboard
- [ ] Or optionally create a new task below
- [ ] Test different return key behaviors
- [ ] Choose most intuitive option

**Expected Outcome:** Return key has intuitive behavior

---

## Phase 2 Completion Checklist

Before moving to Phase 3, verify all items are completed:

### Core UI ✅
- [ ] Test UI removed and replaced with production interface
- [ ] Default "Main" TaskList is created automatically
- [ ] Empty state displays when no tasks exist
- [ ] Main task list displays correctly

### Task Management ✅
- [ ] Individual task rows display properly with checkbox and text field
- [ ] Tasks can be marked complete/incomplete with visual feedback
- [ ] Task titles can be edited directly by tapping
- [ ] New tasks can be created with the floating "+" button
- [ ] New tasks automatically receive keyboard focus

### Deletion ✅
- [ ] Tasks can be deleted via swipe-to-delete (iOS/iPadOS)
- [ ] Tasks can be deleted via context menu (cross-platform)
- [ ] Deletion works smoothly without UI glitches
- [ ] Empty state appears correctly when all tasks are deleted

### Keyboard & Focus Management ✅
- [ ] Keyboard appears when editing tasks
- [ ] Tapping outside dismisses keyboard and saves changes
- [ ] Focus management works correctly between tasks
- [ ] Floating buttons behave properly with keyboard

### Cross-Platform Testing ✅
- [ ] All functionality works on iOS simulator
- [ ] All functionality works on macOS
- [ ] UI adapts appropriately to each platform
- [ ] No platform-specific issues or crashes

### List Functionality ✅
- [ ] "Adding to: Main" indicator displays correctly
- [ ] Tasks are added to the correct list
- [ ] Tasks display in correct order (by creation date)
- [ ] List filtering works correctly

---

## Next Steps
Upon successful completion of Phase 2, proceed to **Phase 3: Advanced Task Organization & Input** where you'll:
- Implement hierarchical task relationships (indentation)
- Add multiple task list management
- Implement drag-and-drop reordering
- Integrate speech-to-text functionality 