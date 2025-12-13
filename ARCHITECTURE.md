# Sheet Scanner - Clean Architecture Guide

## Project Structure

```
lib/
├── core/                              # HORIZONTAL (Shared Infrastructure)
│   ├── di/
│   │   └── injection.dart            # get_it configuration
│   ├── error/
│   │   ├── failures.dart             # Base failure types
│   │   └── exceptions.dart           # Base exceptions
│   ├── platform/
│   │   └── platform_detector.dart    # iOS/Android/Desktop detection
│   └── utils/
│       ├── either.dart               # Result<L, R> type
│       └── validators.dart           # Common validators
│
├── features/                         # VERTICAL SLICES (Features)
│   ├── sheet_music/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── ocr/                         # Same structure
│   ├── search/                      # Same structure
│   └── backup/                      # Same structure
│
└── main.dart
```

## Dependency Rules (CRITICAL)

**These rules MUST be enforced:**

### 1. Features can depend on `core/`
```dart
import 'package:sheet_scanner/core/error/failures.dart';  // ✅ OK
```

### 2. Features can depend on other features' **domain only**
```dart
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';  // ✅ OK
import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';  // ❌ NO!
```

### 3. Core cannot depend on features
```dart
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';  // ❌ NO!
```

### 4. Domain cannot depend on data or presentation
```dart
// domain/usecases/scan_use_case.dart
import '../../data/datasources/ml_kit.dart';  // ❌ NO!
import '../../presentation/cubit/ocr_cubit.dart';  // ❌ NO!
```

## Layer Responsibilities

### Core Layer

**di/** - Dependency Injection
- Service locator configuration via get_it
- Repository registration
- DataSource registration
- UseCase registration
- Factory setup & lazy singletons

**error/** - Error Handling
- Base `Failure` types for error handling
- Domain-level exceptions
- Error mapping utilities

**platform/** - Platform Detection
- iOS/Android/Desktop runtime detection
- Platform-specific adaptation

**utils/** - Shared Utilities
- Either/Result type for functional error handling
- Common validators
- Type definitions

### Feature Layers

Each feature follows Clean Architecture with three layers:

#### Domain Layer
- **Entities**: Pure Dart classes, immutable, no dependencies
- **Repositories**: Abstract interfaces (contracts)
- **UseCases**: Business logic, no side effects
- **No external dependencies** (pure Dart)

#### Data Layer
- **Repositories**: Implement domain interfaces
- **DataSources**: Abstract local/remote data access
- **Models**: JSON-serializable, convert to entities
- **Error mapping**: External exceptions → domain Failures

#### Presentation Layer
- **Cubits**: State management (not Provider)
- **Pages**: Full-screen routes
- **Widgets**: Reusable, immutable UI components
- **No business logic** (delegate to cubits/usecases)

## Code Review Checklist

### Domain Layer Reviews
- [ ] No external dependencies (pure Dart)
- [ ] Entities are immutable
- [ ] Repository interfaces are abstract
- [ ] Use cases contain only business logic
- [ ] Error types (Failure) are properly defined

### Data Layer Reviews
- [ ] Repositories implement domain interfaces correctly
- [ ] Data sources are properly abstracted
- [ ] Models convert cleanly to entities
- [ ] Database queries are optimized
- [ ] Error handling maps external exceptions to Failures

### Presentation Layer Reviews
- [ ] Cubits manage state correctly
- [ ] Widgets are immutable and composable
- [ ] No business logic in UI code
- [ ] State transitions are complete
- [ ] Error states are handled and displayed

## Testing Requirements

- **Unit Tests**: Domain logic (use cases), data layer (repositories)
- **Widget Tests**: Cubit transitions, UI components
- **Integration Tests**: End-to-end flows (scan → save → search)
- **Lint & Format**: 100% compliance with analysis rules

## Quality Verification

### Pre-Implementation
- [ ] Run `fvm flutter pub get` to sync dependencies
- [ ] Review FLUTTER_DART_BEST_PRACTICES.md for guidelines
- [ ] Check `analysis_options.yaml` for lint rules
- [ ] Plan architecture layers before coding

### Post-Implementation
```bash
# Lint check
fvm dart analyze

# Format code
fvm dart format lib/

# Run tests
fvm flutter test

# Check for issues
fvm flutter analyze --fatal-infos
```

## Key Design Principles

1. **Clean Architecture**: Strict layer separation, no circular dependencies
2. **SOLID Principles**: Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion
3. **Immutability**: All entities and value objects are immutable
4. **Functional Error Handling**: Use Either<Failure, T> instead of exceptions
5. **Dependency Injection**: All dependencies provided via get_it, never instantiated
6. **Repository Pattern**: Single source of truth for data access abstraction
7. **Cubit for State Management**: Type-safe, testable state management
8. **Feature Independence**: Features isolated by domain, minimal coupling
