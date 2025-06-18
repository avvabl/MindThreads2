# Phase 3: Detailed Task Breakdown - Advanced Task Organization & Input

This document provides a granular, step-by-step breakdown of Phase 3 tasks for the MindThreads project. Each task includes specific actions, expected outcomes, and verification steps.

## Overview
Phase 3 transforms MindThreads from a simple task list into a powerful hierarchical task management system with multiple list support, drag-and-drop reordering, and speech-to-text input capabilities.

---

## Step 3.1: Implement Task Indentation and Parent-Child Relationship

### Task 3.1.1: Add Indentation Controls to TaskRowView
**Action:** Create UI controls for indenting and outdenting tasks
- [ ] Add indentation buttons to TaskRowView (indent right, outdent left arrows)
- [ ] Position buttons to the left of the checkbox, only show when task has content
- [ ] Style as subtle, small buttons that don't interfere with main UI
- [ ] Add proper spacing and visual hierarchy

**Code Structure:**
```swift
// In TaskRowView.swift
HStack {
    // Indentation controls
    if !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        HStack(spacing: 4) {
            Button(action: outdentTask) {
                Image(systemName: "arrow.left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .disabled(task.indentationLevel == 0)
            
            Button(action: indentTask) {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .disabled(task.indentationLevel >= 4) // Max 5 levels (0-4)
        }
        .opacity(isFocused ? 1.0 : 0.3)
    }
    
    // Existing content...
}
```

**Expected Outcome:** Tasks show indent/outdent controls when they have content

### Task 3.1.2: Implement Indentation Logic
**Action:** Create functions to handle task hierarchy changes
- [ ] Implement `indentTask()` function in TaskRowView
- [ ] Implement `outdentTask()` function in TaskRowView
- [ ] Add maximum depth validation (5 levels: 0-4)
- [ ] Add logic to find valid parent tasks for indenting
- [ ] Update `parentTask` relationships when indenting/outdenting

**Code Structure:**
```swift
private func indentTask() {
    guard task.indentationLevel < 4 else { return }
    
    // Find potential parent (previous task at current level or higher)
    if let parentTask = findPotentialParent() {
        task.indentationLevel += 1
        task.parentTask = parentTask
        try? modelContext.save()
    }
}

private func outdentTask() {
    guard task.indentationLevel > 0 else { return }
    
    task.indentationLevel -= 1
    task.parentTask = task.parentTask?.parentTask // Move up one level
    try? modelContext.save()
}
```

**Expected Outcome:** Tasks can be indented/outdented with proper parent-child relationships

### Task 3.1.3: Implement Parent-Child Relationship Logic
**Action:** Create helper functions for managing task hierarchy
- [ ] Implement `findPotentialParent()` function
- [ ] Add validation to prevent circular references
- [ ] Create `updateSubtaskHierarchy()` for cascading changes
- [ ] Add logic to handle subtask management when parent is deleted

**Expected Outcome:** Robust parent-child relationship management with proper validation

### Task 3.1.4: Enhanced Visual Hierarchy Display
**Action:** Improve visual representation of task hierarchy
- [ ] Add connecting lines or visual indicators for parent-child relationships
- [ ] Implement collapsible parent tasks (show/hide subtasks)
- [ ] Add visual styling for different hierarchy levels
- [ ] Create subtle background variations for different indent levels

**Expected Outcome:** Clear visual hierarchy that makes relationships obvious

### Task 3.1.5: Keyboard Shortcuts for Indentation
**Action:** Add keyboard shortcuts for power users
- [ ] Implement Tab key for indenting (when focused on task)
- [ ] Implement Shift+Tab for outdenting
- [ ] Add proper keyboard handling in TaskRowView
- [ ] Ensure shortcuts don't conflict with system behaviors

**Expected Outcome:** Keyboard shortcuts provide efficient hierarchy management

---

## Step 3.2: Implement Task List Management

### Task 3.2.1: Create TaskList Selection UI
**Action:** Build interface for selecting and managing lists
- [ ] Create `TaskListSelectorView.swift` component
- [ ] Design list selection interface for iOS (modal or navigation)
- [ ] Design sidebar interface for iPadOS/macOS
- [ ] Add "New List" creation button and functionality
- [ ] Include list deletion with confirmation

**Code Structure:**
```swift
struct TaskListSelectorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.name) private var taskLists: [TaskList]
    @Binding var selectedList: TaskList?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskLists, id: \.id) { list in
                    TaskListRowView(
                        list: list,
                        isSelected: selectedList?.id == list.id,
                        onSelect: { selectedList = list }
                    )
                }
                .onDelete(perform: deleteList)
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New List") { createNewList() }
                }
            }
        }
    }
}
```

**Expected Outcome:** Users can view, select, and manage their task lists

### Task 3.2.2: Implement List Creation and Editing
**Action:** Add functionality to create and modify task lists
- [ ] Create `NewListView.swift` for list creation
- [ ] Add text field for list name with validation
- [ ] Implement list renaming functionality
- [ ] Add list icons/colors for visual distinction (optional enhancement)
- [ ] Create default list assignment for new tasks

**Expected Outcome:** Users can create, rename, and customize their task lists

### Task 3.2.3: Add List Selection to ContentView
**Action:** Integrate list management into the main interface
- [ ] Add list selector button to ContentView navigation bar
- [ ] Update ContentView to track currently selected list
- [ ] Modify "Adding to:" indicator to show current list
- [ ] Update task creation to use selected list
- [ ] Add list switching functionality

**Expected Outcome:** Main app interface supports multiple list management

### Task 3.2.4: Implement Collapsible Lists Feature
**Action:** Add ability to collapse/expand lists in sidebar
- [ ] Add collapse/expand state to TaskList model (or view state)
- [ ] Create UI controls for expanding/collapsing
- [ ] Implement persistence of collapse state
- [ ] Add smooth animations for expand/collapse actions

**Expected Outcome:** Users can organize their workspace by collapsing unused lists

### Task 3.2.5: List Deletion with Safety Checks
**Action:** Implement safe list deletion with task handling
- [ ] Add confirmation dialog for list deletion
- [ ] Prevent deletion of lists with tasks (or offer to move tasks)
- [ ] Create "Move tasks to another list" functionality
- [ ] Ensure at least one list always exists (Main list protection)

**Expected Outcome:** Safe list deletion that protects user data

---

## Step 3.3: Implement Drag and Drop Reordering

### Task 3.3.1: Make Tasks Draggable
**Action:** Implement basic drag functionality for tasks
- [ ] Make Task conform to `Transferable` protocol
- [ ] Add `.draggable()` modifier to TaskRowView
- [ ] Implement drag preview with task content
- [ ] Add visual feedback during drag initiation

**Code Structure:**
```swift
// In Task.swift
extension Task: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .task) { task in
            TaskTransfer(id: task.id, title: task.title)
        } importing: { data in
            // This will be handled by drop logic
            Task(title: data.title)
        }
    }
}

// Custom content type
extension UTType {
    static let task = UTType(exportedAs: "com.avvab.MindThreads.task")
}
```

**Expected Outcome:** Tasks can be dragged with proper visual feedback

### Task 3.3.2: Implement Drop Zones Between Tasks
**Action:** Create drop areas between tasks for reordering
- [ ] Add invisible drop zones between each task row
- [ ] Implement visual indicators for valid drop locations
- [ ] Create thick line with dot indicator for drop position
- [ ] Add indentation level indicators during drop

**Expected Outcome:** Clear visual feedback for drop locations with indentation preview

### Task 3.3.3: Implement Drop Logic for Reordering
**Action:** Handle task drops with hierarchy management
- [ ] Implement `.onDrop()` modifier for each drop zone
- [ ] Calculate new position and indentation level from drop location
- [ ] Update task order and parent-child relationships
- [ ] Prevent circular references (parent under its own child)
- [ ] Handle moving parent tasks with their subtasks

**Code Structure:**
```swift
.onDrop(of: [.task], delegate: TaskDropDelegate(
    targetIndex: index,
    tasks: currentListTasks,
    onDrop: handleTaskDrop
))

struct TaskDropDelegate: DropDelegate {
    let targetIndex: Int
    let tasks: [Task]
    let onDrop: (Int, Int, Int) -> Void // sourceIndex, targetIndex, newIndentLevel
    
    func performDrop(info: DropInfo) -> Bool {
        // Calculate drop position and indentation level
        // Handle hierarchy updates
        // Prevent invalid drops
    }
}
```

**Expected Outcome:** Tasks can be reordered with proper hierarchy management

### Task 3.3.4: Add Drag Visual Feedback
**Action:** Enhance drag experience with visual cues
- [ ] Dim the original task during drag
- [ ] Highlight valid drop zones during drag
- [ ] Show indentation level preview during hover
- [ ] Add animated transitions for drag start/end
- [ ] Collapse subtasks under parent during drag (if possible)

**Expected Outcome:** Rich visual feedback makes drag operations intuitive

### Task 3.3.5: Handle Complex Hierarchy Scenarios
**Action:** Manage edge cases in drag and drop
- [ ] Moving parent tasks with subtasks
- [ ] Preventing drops that would create circular references
- [ ] Handling maximum depth violations
- [ ] Updating all affected subtasks when parent moves
- [ ] Maintaining proper sort order after drops

**Expected Outcome:** Robust drag-and-drop that handles all hierarchy scenarios

---

## Step 3.4: Integrate Speech-to-Text

### Task 3.4.1: Add Microphone Permissions
**Action:** Request and handle speech recognition permissions
- [ ] Update `Info.plist` with required permission descriptions:
  - `NSSpeechRecognitionUsageDescription`
  - `NSMicrophoneUsageDescription`
- [ ] Implement permission request flow in app
- [ ] Handle permission denied states gracefully
- [ ] Show permission explanation UI when needed

**Expected Outcome:** App properly requests and handles microphone permissions

### Task 3.4.2: Integrate Speech Framework
**Action:** Set up Apple's Speech framework for recognition
- [ ] Import Speech framework
- [ ] Create `SpeechRecognitionManager` class
- [ ] Set up speech recognition session
- [ ] Handle speech recognition authorization states
- [ ] Implement real-time speech recognition

**Code Structure:**
```swift
import Speech

class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var authorizationStatus = SFSpeechRecognizerAuthorizationStatus.notDetermined
    
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func requestAuthorization() { /* ... */ }
    func startRecording() throws { /* ... */ }
    func stopRecording() { /* ... */ }
}
```

**Expected Outcome:** Speech recognition framework is properly integrated

### Task 3.4.3: Implement Microphone Button Functionality
**Action:** Connect the microphone button to speech recognition
- [ ] Enable the microphone FloatingActionButton
- [ ] Implement tap-and-hold gesture for recording
- [ ] Add visual feedback (red color) during recording
- [ ] Play audio chimes for start/stop recording
- [ ] Create new task automatically when recording starts

**Expected Outcome:** Microphone button triggers speech-to-text recording

### Task 3.4.4: Add Recording Visual Feedback
**Action:** Provide clear feedback during speech recording
- [ ] Change microphone button to red during recording
- [ ] Add pulsing animation to indicate active recording
- [ ] Show recording status in UI (optional waveform animation)
- [ ] Display real-time transcription preview (optional)
- [ ] Add recording timer display

**Expected Outcome:** Users have clear visual feedback during recording

### Task 3.4.5: Implement Speech-to-Text Error Handling
**Action:** Handle various speech recognition failure scenarios
- [ ] Network connectivity issues
- [ ] Speech recognition failures
- [ ] No speech detected scenarios
- [ ] Microphone access denied
- [ ] Background app limitations

**Error Handling Flow:**
```swift
private func handleSpeechError(_ error: Error) {
    DispatchQueue.main.async {
        // Show snackbar with error message
        self.showErrorSnackbar(error.localizedDescription)
        
        // Open keyboard for manual entry on the created task
        if let currentTask = self.currentlyCreatedTask {
            self.focusedTaskID = currentTask.id
        }
    }
}
```

**Expected Outcome:** Graceful error handling with automatic fallback to text entry

### Task 3.4.6: Add Audio Feedback (Chimes)
**Action:** Implement audio cues for recording states
- [ ] Add system sound for recording start
- [ ] Add system sound for recording completion
- [ ] Handle silent mode and volume settings
- [ ] Test audio feedback on different devices
- [ ] Add user preference for audio feedback (optional)

**Expected Outcome:** Audio cues provide feedback for recording states

---

## Phase 3 Completion Checklist

Before considering Phase 3 complete, verify all items are tested and working:

### Task Hierarchy ✅
- [ ] Tasks can be indented and outdented with visual controls
- [ ] Parent-child relationships are properly maintained
- [ ] Maximum depth of 5 levels is enforced
- [ ] Visual hierarchy is clear and intuitive
- [ ] Keyboard shortcuts work for indentation (Tab/Shift+Tab)

### Multiple List Management ✅
- [ ] Users can create new task lists
- [ ] List selection works on all platforms (iOS modal, iPad/Mac sidebar)
- [ ] Lists can be renamed and deleted safely
- [ ] Current list is clearly indicated in UI
- [ ] Tasks are properly assigned to selected lists
- [ ] List collapse/expand functionality works

### Drag and Drop Reordering ✅
- [ ] Tasks can be dragged and dropped for reordering
- [ ] Visual feedback shows drop zones and indentation levels
- [ ] Hierarchy is maintained during drag operations
- [ ] Circular references are prevented
- [ ] Parent tasks move with their subtasks
- [ ] Long press initiates drag on touch devices

### Speech-to-Text Integration ✅
- [ ] Microphone permissions are properly requested
- [ ] Tap-and-hold on mic button starts recording
- [ ] Visual feedback shows recording state (red button, animations)
- [ ] Audio chimes play for start/stop recording
- [ ] Speech is accurately transcribed to task titles
- [ ] Error handling works with automatic fallback to text entry
- [ ] Permission denied state is handled gracefully

### Cross-Platform Compatibility ✅
- [ ] All features work on iOS simulator
- [ ] All features work on macOS
- [ ] Drag and drop works properly on both platforms
- [ ] Speech recognition works on supported devices
- [ ] UI adapts appropriately to platform differences

### Performance & Stability ✅
- [ ] App remains responsive during speech recognition
- [ ] Large task hierarchies perform well
- [ ] Drag and drop operations are smooth
- [ ] Memory usage remains stable
- [ ] No crashes during complex operations

---

## Next Steps
Upon successful completion of Phase 3, proceed to **Phase 4: Platform-Specific UI & Enhancements** where you'll:
- Implement "Done Items" view with platform-specific presentation
- Create interactive homescreen widgets
- Add comprehensive error handling with snackbars
- Optimize performance and polish the user experience 