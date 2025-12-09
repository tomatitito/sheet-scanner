# Sheet Scanner

A Flutter application for organizing and cataloging sheet music collections with OCR text recognition capabilities.

## Features

- 📚 **Library Management**: Browse, add, edit, and delete sheet music entries
- 🏷️ **Tagging System**: Organize sheets with flexible tag management
- 📝 **Notes Support**: Add composer and notes to each entry
- 🔍 **Search & Filtering**: Full-text search and advanced filtering (coming soon)
- 📸 **OCR Recognition**: Text recognition from sheet images (coming soon)
- 💾 **Data Export**: Backup and export library data (coming soon)

## Getting Started

### Prerequisites

This project uses **FVM (Flutter Version Manager)** for Flutter version management. All Flutter and Dart commands should use the `fvm` prefix.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/tomatitito/sheet-scanner.git
   cd sheet-scanner
   ```

2. Get dependencies:
   ```bash
   fvm flutter pub get
   ```

3. Generate code (for freezed models, drift database, etc.):
   ```bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Running the App

### macOS (Desktop - Recommended)
```bash
fvm flutter run -d macos
```

### Web (Chrome)
```bash
fvm flutter run -d chrome
```

### Android (Emulator)
First, start an Android emulator:
```bash
# List available AVDs
$ANDROID_HOME/emulator/emulator -list-avds

# Start an emulator (replace <avd_name> with actual AVD)
$ANDROID_HOME/emulator/emulator -avd <avd_name>
```

Then run the app:
```bash
fvm flutter run -d emulator-5554
```

### iOS (Simulator)
First, open the iOS simulator:
```bash
open -a Simulator
```

Then run the app:
```bash
fvm flutter run -d ios
```

### Physical Device (Android/iOS)
Connect your device via USB, then:
```bash
fvm flutter run
```

## Development

### Code Analysis
```bash
fvm flutter analyze
```

### Run Tests
```bash
fvm flutter test
```

### Format Code
```bash
fvm flutter format lib/
```

### Build Artifacts

Build APK (Android):
```bash
fvm flutter build apk
```

Build iOS app:
```bash
fvm flutter build ios
```

Build macOS app:
```bash
fvm flutter build macos
```

Build Web:
```bash
fvm flutter build web
```

## Project Structure

```
lib/
├── core/
│   ├── database/      # Drift database setup
│   ├── di/            # Dependency injection (GetIt)
│   ├── error/         # Failure types and error handling
│   ├── router/        # GoRouter navigation
│   ├── storage/       # File storage utilities
│   └── utils/         # Helpers (Either type, validators)
├── features/
│   ├── sheet_music/   # Core sheet music feature
│   │   ├── data/      # Data sources & repositories
│   │   ├── domain/    # Entities, repositories, use cases
│   │   └── presentation/ # UI, cubits, pages
│   ├── ocr/           # OCR/text recognition feature
│   ├── search/        # Search & filtering feature
│   └── backup/        # Backup & export feature
└── main.dart          # App entry point
```

## Architecture

This project follows **Clean Architecture** with clear separation of concerns:

- **Domain Layer**: Business logic, entities, and repository interfaces
- **Data Layer**: Repository implementations, data sources, and models
- **Presentation Layer**: UI, state management (Cubit), and pages

State management uses **BLoC/Cubit** pattern with proper error handling via the `Either` type.

## Dependencies

- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **go_router**: Navigation
- **drift**: Type-safe database ORM
- **freezed**: Code generation for immutable models
- **equatable**: Value equality
- **path_provider**: File system paths
- **file_picker**: File selection (desktop/mobile)

## Database

This app uses **Drift** (formerly moor) for local data persistence with SQLite. The database includes:

- Sheet music entries
- Tags
- Composers
- Full-text search (FTS5) support

## Contributing

When contributing code:

1. Run `fvm flutter analyze` to check for lint issues
2. Run `fvm flutter format lib/` to format code
3. Ensure all tests pass with `fvm flutter test`
4. Follow the existing Clean Architecture patterns
5. Create descriptive commit messages

## License

[Add appropriate license information]
