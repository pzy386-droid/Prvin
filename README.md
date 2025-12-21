# Prvin - AI-Powered Smart Calendar Application

Prvin is a modern calendar and task management system integrated with artificial intelligence features, providing an intuitive calendar interface, task management capabilities, Pomodoro focus mode, and AI-driven intelligent analysis and recommendation features.

## Features

- 📅 **Smart Calendar** - Month/Week/Day views with color-coded task types
- ✅ **Task Management** - Quick task creation with time, tags, and priority settings
- 🍅 **Pomodoro Timer** - Focus time management with immersive timer interface
- 🤖 **AI Analytics** - Intelligent task categorization, data analysis, and focus time recommendations
- 🔄 **Calendar Sync** - Support for Google Calendar, Outlook, and other external services
- 🎨 **Modern UI** - Card-based design with micro-animations and soft color schemes

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: BLoC Pattern
- **Data Storage**: SQLite + SharedPreferences
- **Network**: Dio + HTTP
- **Animations**: Lottie + Flutter Animations
- **Testing**: Flutter Test + Mockito + Faker

## Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App constants
│   ├── theme/          # Theme configuration
│   ├── error/          # Error handling
│   ├── utils/          # Utility classes
│   └── services/       # Core services
├── features/           # Feature modules
│   ├── calendar/       # Calendar functionality
│   ├── tasks/          # Task management
│   ├── pomodoro/       # Pomodoro timer
│   ├── ai/             # AI analysis
│   └── sync/           # Sync functionality
└── main.dart           # App entry point
```

## Development Progress

- [x] Project initialization and core architecture setup
- [x] Core data model implementation
- [x] Data model property testing
- [x] Event bus and state management
- [x] Local storage service implementation (database, cache, data sources)
- [x] Complete data access layer implementation
- [x] Business logic layer implementation (Repository and UseCase layers)
- [x] Pomodoro timer functionality implementation
- [x] AI analysis engine basic framework implementation
- [ ] UI layer implementation (calendar interface, task management, Pomodoro interface)
- [ ] BLoC layer implementation (connecting UI and business logic)
- [ ] External calendar integration
- [ ] Integration testing

## Current Status

**Completed Feature Modules:**
- ✅ Core Architecture: Dependency injection, event bus, theme system, BLoC state management
- ✅ Data Models: Task, PomodoroSession, CalendarEvent, AnalyticsData
- ✅ Database Layer: SQLite database helper with complete table structure and indexes
- ✅ Cache System: LRU cache manager with TTL expiration support
- ✅ Data Sources: Local data source implementations for tasks, Pomodoro, calendar events, and AI analysis
- ✅ Repository Layer: Task, Pomodoro, and AI analysis repository implementations with encapsulated data access logic
- ✅ Business Logic Layer: TaskManager, PomodoroTimer, AIAnalytics use case implementations
- ✅ Test Coverage: All 50 test cases passing

**Technical Architecture:**
```
UI Layer (To be implemented)
    ↓
Business Logic Layer (UseCases)
    ├── TaskManager ✅
    ├── PomodoroTimer ✅
    └── AIAnalytics ✅
    ↓
Domain Layer
    ├── Entities ✅
    └── Repositories (Interfaces) ✅
    ↓
Data Layer
    ├── Repositories (Implementations) ✅
    ├── DataSources ✅
    ├── Models ✅
    └── Cache ✅
    ↓
Core Layer
    ├── Database ✅
    ├── BLoC ✅
    ├── DI ✅
    └── Theme ✅
```

**Next Steps:**
1. Begin UI layer development (calendar interface, task list, Pomodoro interface)
2. Implement BLoC layer to connect UI and business logic
3. Integrate external calendar services (Google Calendar, Outlook)

## Getting Started

1. Ensure Flutter SDK (3.10+) is installed
2. Clone the project and install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
4. Run tests:
   ```bash
   flutter test
   ```

## Contributing

Issues and Pull Requests are welcome to help improve Prvin!

## License

MIT License
