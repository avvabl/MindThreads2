# Product Requirements Document: Cross-Platform To-Do List App

## 1. Introduction
This document outlines the requirements for a cross-platform To-Do List application built using SwiftUI, targeting iOS, iPadOS, and macOS. The goal is to provide users with a simple, intuitive, and efficient way to manage their daily tasks across all their Apple devices.

## 2. Goals & Objectives
*   **Primary Goal:** Enable users to easily create, track, and manage their To-Do items.
*   **Cross-Platform Compatibility:** Ensure a consistent yet platform-optimized user experience across iOS, iPadOS, and macOS.
*   **User Friendliness:** Provide an intuitive and clean user interface.
*   **Reliable Data Persistence:** Securely store and retrieve user data.

## 3. Target Audience
*   Individuals seeking a simple and effective task management solution.
*   Users within the Apple ecosystem who prefer native applications.

## 4. Core Features

### 4.1 Task Management
*   **Create Task:** Users can add new tasks with a title (a long text field).
*   **View Tasks:** Display a list of tasks, initially ordered by creation date or due date.
*   **Mark Complete/Incomplete:** Users can toggle the completion status of a task. Completed tasks should be visually distinct (e.g., strike-through).
*   **View Completed Tasks:** A dedicated button will allow users to view their marked as complete items. This will open a sheet on iOS and an equivalent popover/separate window on iPadOS and macOS.
*   **Edit Task:** Users can modify the details of an existing task.
*   **Delete Task:** Users can remove tasks.

### 4.2 Task Details
*   **Title:** Long text field for the task content. This is the primary and only editable detail of a task beyond its completion status and relationships. (Required, as seen in UI)

### 4.3 User Interface & Experience (UI/UX)
*   **Consistent Design Language:** Leverage SwiftUI to maintain a cohesive look and feel.
*   **Platform Adaptations:**
    *   **Main List View:** The homescreen across all platforms (iOS, iPadOS, macOS) will display the main task list(s).
    *   **Completed Items View:** A button at the top of the main list view, labeled "Done Items" or similar, will trigger a secondary view for completed items. This will be a sheet on iOS and a pop-up window on iPadOS and macOS.
*   **Accessibility:** Adhere to Apple's accessibility guidelines for voice-over, dynamic type, etc.
*   **Visual Reference:** The attached UI image serves as a primary visual reference for the task list view and core interaction elements.

### 4.4 Task Organization
*   **Task Categorization/Lists:** Users can organize tasks into different named lists.
*   **Indentation and Parent-Child Relationship:** Support for hierarchical task organization, allowing tasks to be nested under parent tasks.
*   **Reorder Tasks:** Users can reorder tasks within a list and within their hierarchical structure using drag-and-drop gestures, maintaining parent-child relationships.

### 4.5 Data Synchronization
*   **iCloud Synchronization:** Tasks and lists will sync across the user's Apple devices via iCloud, ensuring data consistency.

### 4.6 Input Methods
*   **Speech-to-Text Input:** Users can create new tasks by tapping and holding a microphone button. Upon tap and hold, a chime will play, the microphone button will turn red, and an empty new task item will appear in the list. The user's speech will be transcribed in real-time or upon release. On release, the spoken English words will populate the new task item's title, and another chime will play to indicate completion of transcription, at which point the item creation is finished.

### 4.7 Homescreen Widgets
*   **Widgets:** Provide interactive homescreen widgets for quick viewing and management of tasks, allowing users to see upcoming tasks or mark tasks as complete directly from their homescreen.

### 4.8 Floating Action Buttons
*   **Bottom Floating Buttons:** The homescreen will feature two floating buttons at the bottom across all systems:
    *   **Microphone Button:** For Speech-to-Text Input, as detailed above.
    *   **New Button (plus icon):** To add a new item as text. Tapping this button will add a new empty item to the first list and automatically open the keyboard for direct text input.

## 5. Technical Requirements

### 5.1 Technology Stack
*   **Programming Language:** Swift
*   **UI Framework:** SwiftUI
*   **Data Persistence:** SwiftData

### 5.2 Data Model (Conceptual)
A `Task` entity with properties such as:
*   `id`: UUID (Unique identifier)
*   `title`: String (Required, long text field)
*   `isComplete`: Bool (Completion status)
*   `creationDate`: Date
*   `parentTask`: Task? (Optional relationship to a parent task for hierarchy)
*   `indentationLevel`: Int (Depth of indentation in the hierarchy)
*   `list`: TaskList? (Optional relationship to a task list for categorization)

A `TaskList` entity with properties such as:
*   `id`: UUID (Unique identifier)
*   `name`: String (Name of the list)
*   `tasks`: [Task]? (Relationship to tasks belonging to this list)

## 6. Future Enhancements (Out of Scope for initial MVP)
*   Reminders/Notifications
*   Search functionality
*   Sorting and filtering options beyond basic view.
*   Sharing tasks

## 7. Open Questions / Decisions To Be Made
*   Specific UI layout choices for each platform (e.g., how the popover/new window for completed tasks on iPadOS/macOS will be implemented).
*   **Error Handling Strategy:** Errors will be handled through snackbars that display the error type directly to the user in a single line of text. These snackbars will be transient and disappear after a short duration.
*   Detailed interaction design for speech-to-text (e.g., visual feedback during recording). 