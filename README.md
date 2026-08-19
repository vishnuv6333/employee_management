Smart Workspace Employee Management App

A modern, feature-rich Flutter application designed for productivity, note management, customizable dashboards, and native device integrations. Built using Clean Architecture principles and the BLoC pattern for clean separation of concerns, scalability, and testability.


TABLE OF CONTENTS

1. Project Overview
2. Folder Structure
3. Architecture Explanation
4. Packages Used
5. Setup Instructions
6. Known Limitations
7. Future Improvements


1. PROJECT OVERVIEW

The Smart Workspace application provides employees and teams with an intuitive, unified workspace:

- Notes and Task Management: Full CRUD operations for workspace notes, supporting rich colors, checklist items, image attachments, reminders, search, and archiving.
- Customizable Dashboard: Interactive dashboard with reorderable metric cards (Quick Notes, Recent Activity, Sync Status, System Info).
- Dynamic Theme System: Customizable light and dark modes with dynamic seed color selection persisted across app restarts.
- Local Notifications: Scheduled daily sync reminders, note-specific alarm notifications with actionable buttons, and progress notifications.
- Offline First and Sync Queue: Automatic detection of network connectivity changes with offline queuing of note operations and simulated background sync.
- Native Platform Channels: MethodChannel bridges for device telemetry (Device Info, Cell Tower location) and native UI components (Date Pickers, Bottom Sheets).


2. FOLDER STRUCTURE

The project follows a Feature-First and Clean Architecture layout:

lib/
  main.dart                       Application entry point and root widget
  core/                           Shared core modules and utilities
    database/                     SQLite database helper and schema migrations
      database_helper.dart
    di/                           Dependency injection container (GetIt)
      injection_container.dart
    native/                       Platform Channel bridge for native calls
      native_bridge.dart
    network/                      Connectivity listener and offline sync manager
      sync_service.dart
    notifications/                Local notifications initialization and scheduling
      notification_service.dart
    routing/                      GoRouter configuration and route constants
      app_router.dart
      app_routes.dart
    theme/                        Light and Dark Material 3 theme generation
      app_theme.dart
    widgets/                      Reusable core UI components
      skeleton_loader.dart
  features/                       Application feature modules
    dashboard/                    Dashboard feature
      domain/
        entities/                 Dashboard card types
      presentation/
        bloc/                     DashboardBloc, events, states
        pages/                    DashboardPage (Reorderable UI)
    notes/                        Notes management feature
      data/
        models/                   NoteModel JSON and DB data mappers
        repositories/             NoteRepositoryImpl (DB and Sync Queue)
      domain/
        entities/                 Note entity model
        repositories/             NoteRepository contract
      presentation/
        bloc/                     NotesBloc, NoteEditorBloc, states, events
        pages/                    NotesPage, NoteEditorPage, ArchivedNotesPage, SearchPage
        widgets/                  NoteCard, Checklist, ImageList, Custom AppBars
    settings/                     Settings and Native Demo feature
      presentation/
        bloc/                     ThemeBloc, states, events
        pages/                    SettingsPage, NativeDemoPage


3. ARCHITECTURE EXPLANATION

The application adheres to Clean Architecture combined with Feature-Driven Development.

Key Architectural Concepts:

Presentation Layer:
- BLoC Pattern (flutter_bloc): Decouples UI logic from business rules using unidirectional data flow (Events to BLoC to States).
- Declarative Navigation (go_router): Centralized routing table handling path navigation, argument passing, and deep linking structure.

Domain Layer:
- Contains pure Dart business entities (Note, DashboardCardType) and abstract repository contracts (NoteRepository). It has zero dependencies on Flutter UI frameworks or third-party storage libraries.

Data Layer:
- Implements repository interfaces (NoteRepositoryImpl), converting raw SQLite database records into domain models.
- Handles offline sync queue operations to track pending changes when connection drops.

Dependency Injection:
- Uses get_it as a Service Locator to manage singletons (DatabaseHelper, SyncService, NotificationService, SharedPreferences) and factory instances (NotesBloc, ThemeBloc, DashboardBloc).

Asynchronous Notification and Permission Management:
- Notification permissions (POST_NOTIFICATIONS and SCHEDULE_EXACT_ALARM) are handled sequentially with proper await calls and exception handling to prevent platform channel race conditions on startup.



5. SETUP INSTRUCTIONS

Prerequisites:
- Flutter SDK (version >= 3.11.5)
- Dart SDK
- Android Studio or Xcode (for Android and iOS device simulators)
- FVM - Flutter Version Manager (Optional)

Step-by-step Installation:

1. Clone the repository:
   git clone https://github.com/your-org/employee_management.git
   cd employee_management

2. Install project dependencies:
   flutter pub get

3. Analyze codebase for linting issues:
   flutter analyze

4. Run the application:
   flutter run


6. KNOWN LIMITATIONS

1. Simulated Backend Sync: The SyncService queues offline operations to SQLite (sync_queue table) and simulates background server sync when network connectivity is restored. Connecting to a live REST/GraphQL endpoint requires configuring remote backend APIs.
2. Swift Package Manager Warning: Certain third-party plugins (open_filex, flutter_local_notifications) currently trigger deprecation warnings regarding legacy CocoaPods vs Swift Package Manager support on newer iOS and macOS builds.
3. Platform Channel Stubs: Custom native MethodChannel methods in NativeBridge require platform-native implementations (MainActivity.kt / AppDelegate.swift) for platform-specific dialogs on non-Android platforms.


7. FUTURE IMPROVEMENTS

- Remote Cloud Synchronization: Integrate Firebase or custom REST API endpoints for seamless multi-device sync.
- Comprehensive Integration Test Suite: Implement end-to-end UI tests using the integration_test package.
- Biometric Note Security: Add Fingerprint or Face ID authentication for locking private notes.
- Rich Text and Markdown Support: Extend note editing to support Markdown syntax and rich formatting.
- Push Notification Integration: Connect Firebase Cloud Messaging (FCM) for real-time team notifications.
