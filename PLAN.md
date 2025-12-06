# 🎼 Sheet Music Inventory App --- Development Plan (Markdown)

## Table of Contents

1. [Overview](#1-overview)
2. [Goals & Non-Goals](#2-goals--non-goals)
   - [Primary Goals](#21-primary-goals)
   - [Non-Goals (initial release)](#22-non-goals-initial-release)
3. [Target Platforms](#3-target-platforms)
4. [Tech Stack](#4-tech-stack)
   - [Frontend](#41-frontend)
   - [OCR](#42-ocr)
   - [Database](#43-database)
   - [File Storage](#44-file-storage)
   - [Architecture](#45-architecture)
5. [Core Features](#5-core-features)
   - [Add Sheet Music](#51-add-sheet-music)
   - [Edit Sheet Music](#52-edit-sheet-music)
   - [Search & Filtering](#53-search--filtering)
   - [Tags](#54-tags)
   - [Bulk Operations (Desktop)](#55-bulk-operations-desktop)
   - [Backup/Export](#56-backupexport)
6. [Architecture Details](#6-architecture-details)
   - [Project Structure](#61-project-structure)
   - [Layer Hierarchy & The Dependency Rule](#62-layer-hierarchy--the-dependency-rule)
   - [Key Architectural Patterns](#63-key-architectural-patterns)
   - [State Management Flow](#64-state-management-flow)
   - [Platform-Specific Implementations](#65-platform-specific-implementations)
   - [Code Examples](#66-code-examples)
   - [Dependency Injection Setup](#67-dependency-injection-setup-how-data-sources-are-used)
   - [Adaptive UI Example](#68-adaptive-ui-example)
7. [Logging & Observability](#7-logging--observability)
   - [Overview](#71-overview)
   - [Logging Library](#72-logging-library)
   - [Logger Setup](#73-logger-setup)
   - [Log Levels & When to Use Them](#74-log-levels--when-to-use-them)
   - [Logging by Architecture Layer](#75-logging-by-architecture-layer)
   - [Logging Best Practices](#76-logging-best-practices)
   - [Error Logging Pattern](#77-error-logging-pattern)
   - [Production Logging Configuration](#78-production-logging-configuration)
   - [Testing with Logs](#79-testing-with-logs)
   - [Logging Checklist by Feature](#710-logging-checklist-by-feature)
   - [Dependencies](#711-dependencies)
   - [Summary](#712-summary)
8. [Data Model](#8-data-model)
9. [Feature Module Details](#9-feature-module-details)
   - [OCR Module](#91-ocr-module)
   - [Search Module](#92-search-module)
   - [Backup Module](#93-backup-module)
10. [UI Plan & Design Reference](#10-ui-plan--design-reference)
    - [Example App (React Prototype)](#101-example-app-react-prototype)
    - [Mobile UI](#102-mobile-ui)
    - [Desktop UI](#103-desktop-ui)
11. [Milestones](#11-milestones)
    - [Phase 1: Foundations](#phase-1-foundations)
    - [Phase 2: Mobile OCR](#phase-2-mobile-ocr)
    - [Phase 3: Desktop Workflow](#phase-3-desktop-workflow)
    - [Phase 4: Search & Filtering](#phase-4-search--filtering)
    - [Phase 5: Backup & Polish](#phase-5-backup--polish)
12. [Stretch Goals](#12-stretch-goals)
13. [Testing Strategy](#13-testing-strategy)
    - [Unit Tests](#unit-tests)
    - [Widget Tests](#widget-tests)
    - [Integration Tests](#integration-tests)
    - [Golden Tests](#golden-tests)
14. [Deployment](#14-deployment)

---

## 1. Overview

A **local-first**, cross-platform (mobile + desktop) Flutter app that
lets music teachers build a searchable inventory of their sheet music.\
The app supports: - Scanning sheet music **cover pages** on mobile using
OCR.\
- Manual entry or **image upload** on desktop.\
- A fast, powerful **search UI** with filtering by composer, title,
tags, and notes.\
- Local storage with optional export/import and future sync
possibilities.

## 2. Goals & Non-Goals

### 2.1 Primary Goals

-   Fast and **privacy-first** cataloging of sheet music.\
-   Accurate detection of **title** and **composer** via OCR (mobile).\
-   Smooth **desktop use** for searching, editing, and bulk import.\
-   Reliable and portable **local database** with metadata and cover
    images.

### 2.2 Non-Goals (initial release)

-   Cloud sync / multi-device sync.\
-   In-app PDF viewer for sheet music.\
-   Automatic tagging through external metadata APIs.

## 3. Target Platforms

-   **Mobile:** iOS, Android\
-   **Desktop:** macOS, Windows, Linux\
-   **(Optional)** Web: only if OCR-free workflows are acceptable.

## 4. Tech Stack

### 4.1 Frontend

-   Flutter

### 4.2 OCR

-   Mobile: ML Kit
-   Desktop optional: Tesseract

### 4.3 Database

-   Drift + sqlite3_flutter_libs with FTS5

### 4.4 File Storage

-   path_provider

### 4.5 Architecture

-   **Clean Architecture + Feature-First Organization**
-   **Repository Pattern** with platform abstraction
-   **Cubit** for state management (BLoC ecosystem without event overhead)
-   **Use Case Pattern** for business logic
-   **Dependency Injection** via get_it

## 5. Core Features

### 5.1 Add Sheet Music

-   Mobile: camera → OCR → parse → edit
-   Desktop: drag-drop / picker → optional OCR → edit

### 5.2 Edit Sheet Music

-   Title, composer, tags, notes, images

### 5.3 Search & Filtering

-   FTS5 search; filters; sorting

### 5.4 Tags

-   User-defined tags

### 5.5 Bulk Operations (Desktop)

-   Bulk tag, delete, import

### 5.6 Backup/Export

-   JSON export, DB export, image export

## 6. Architecture Details

### 6.1 Project Structure

The `lib` package uses a **hybrid architecture**:
- **Features**: Vertical slices with hexagonal/Clean Architecture
- **Core**: Horizontal shared infrastructure layer

```
lib/
├── core/                          # HORIZONTAL LAYER (Shared Infrastructure)
│   ├── di/                       # Dependency injection setup (get_it)
│   │   └── injection.dart        # Wires ALL features together
│   ├── error/                    # Error handling & exceptions
│   │   ├── failures.dart         # Base failure types (used by all features)
│   │   └── exceptions.dart       # Base exceptions
│   ├── platform/                 # Platform detection utilities
│   │   └── platform_detector.dart # iOS/Android/Desktop detection
│   └── utils/                    # Common helpers
│       ├── either.dart           # Result type (Left/Right)
│       └── validators.dart       # Common validation
│
├── features/                     # VERTICAL SLICES (Hexagonal Architecture)
│   ├── sheet_music/              # Each feature is self-contained
│   │   ├── data/                 # ← Outer layer (implementation)
│   │   │   ├── datasources/     # Local DB, file system
│   │   │   ├── models/          # Data transfer objects
│   │   │   └── repositories/    # Repository implementations
│   │   ├── domain/               # ← Core layer (business logic)
│   │   │   ├── entities/        # Business objects (SheetMusic, Tag)
│   │   │   ├── repositories/    # Repository interfaces
│   │   │   └── usecases/        # Business logic (AddSheetMusic, etc.)
│   │   └── presentation/         # ← Outer layer (UI)
│   │       ├── cubit/           # State management
│   │       ├── pages/           # Screen widgets
│   │       └── widgets/         # Reusable components
│   │
│   ├── ocr/                     # OCR scanning feature (same structure)
│   ├── search/                  # Search & filtering feature (same structure)
│   └── backup/                  # Export/import feature (same structure)
│
└── main.dart                     # App entry point
```

#### Architecture Patterns

**Within Features (Vertical/Hexagonal):**
```
Presentation → Domain ← Data
```
Each feature is a self-contained hexagon with Clean Architecture.

**Across Features (Horizontal/Shared):**
```
All Features → core (shared utilities)
```
Core provides common infrastructure but contains NO business logic.

**Visual Representation:**

```
┌────────────────────────────────────────────────────────────┐
│ lib/                                                        │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ core/ (HORIZONTAL - Shared Infrastructure)           │ │
│  │ - DI setup                                           │ │
│  │ - Error types                                        │ │
│  │ - Platform utils                                     │ │
│  └──────────────────────────────────────────────────────┘ │
│           ↑           ↑           ↑           ↑           │
│           │           │           │           │           │
│  ┌────────────┐  ┌────────┐  ┌────────┐  ┌────────┐      │
│  │sheet_music │  │  ocr   │  │ search │  │ backup │      │
│  │            │  │        │  │        │  │        │      │
│  │ ┌────────┐ │  │┌──────┐│  │┌──────┐│  │┌──────┐│      │
│  │ │Pres.   │ │  ││Pres. ││  ││Pres. ││  ││Pres. ││      │
│  │ └───┬────┘ │  │└──┬───┘│  │└──┬───┘│  │└──┬───┘│      │
│  │     ↓      │  │   ↓    │  │   ↓    │  │   ↓    │      │
│  │ ┌────────┐ │  │┌──────┐│  │┌──────┐│  │┌──────┐│      │
│  │ │Domain  │ │  ││Domain││  ││Domain││  ││Domain││      │
│  │ └───┬────┘ │  │└──┬───┘│  │└──┬───┘│  │└──┬───┘│      │
│  │     ↑      │  │   ↑    │  │   ↑    │  │   ↑    │      │
│  │ ┌────────┐ │  │┌──────┐│  │┌──────┐│  │┌──────┐│      │
│  │ │Data    │ │  ││Data  ││  ││Data  ││  ││Data  ││      │
│  │ └────────┘ │  │└──────┘│  │└──────┘│  │└──────┘│      │
│  │ (Hexagon)  │  │(Hexagon)│  │(Hexagon)│  │(Hexagon)│      │
│  └────────────┘  └────────┘  └────────┘  └────────┘      │
│                                                            │
│  main.dart                                                 │
└────────────────────────────────────────────────────────────┘
```

#### Dependency Rules

**1. Features can depend on `core`:**
```dart
// ✅ ALLOWED
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
```

**2. Features can depend on other features' domain layers only:**
```dart
// ✅ ALLOWED: Use entity from another feature's domain
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

// ❌ NOT ALLOWED: Depend on another feature's data/presentation
import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';  // BAD!
```

**3. Core does NOT depend on features:**
```dart
// ❌ NOT ALLOWED: Core cannot import from features
// core/utils/helpers.dart
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';  // BAD!
```

**4. Within a feature: Domain has NO dependencies:**
```dart
// features/ocr/domain/usecases/scan_image_use_case.dart

// ✅ OK: Depend on core utilities
import 'package:sheet_scanner/core/error/failures.dart';

// ✅ OK: Depend on own domain layer
import '../entities/ocr_result.dart';

// ❌ NOT ALLOWED: Domain depends on data layer
import '../../data/datasources/ml_kit_data_source.dart';  // BAD!

// ❌ NOT ALLOWED: Domain depends on presentation layer
import '../../presentation/cubit/ocr_scan_cubit.dart';  // BAD!
```

### 6.2 Layer Hierarchy & The Dependency Rule

Clean Architecture organizes code into layers with **dependencies pointing inward only**.

#### The Three Layers

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (Outermost)                              │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ UI Widgets, Pages, Cubit/State Management               │ │
│ │ - Depends on: Domain layer                              │ │
│ │ - Knows about: Use Cases, Entities                      │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↓ depends on
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER (Core/Inner Circle)                            │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Business Logic - Pure Dart, NO dependencies             │ │
│ │ - Entities (SheetMusic, Tag)                            │ │
│ │ - Repository Interfaces (abstract classes)              │ │
│ │ - Use Cases (business operations)                       │ │
│ │ - Depends on: NOTHING                                   │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↑ implements interfaces
┌─────────────────────────────────────────────────────────────┐
│ DATA LAYER (Outermost)                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Implementation Details                                  │ │
│ │ - Repository Implementations                            │ │
│ │ - Data Sources (ML Kit, Database, File System)         │ │
│ │ - Models/DTOs                                           │ │
│ │ - Depends on: Domain layer (interfaces only)           │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### The Dependency Rule (CRITICAL)

**Dependencies point INWARD ONLY:**

```
Presentation ──────────┐
                       ↓
                    DOMAIN (center)
                       ↑
Data ──────────────────┘
```

- **Presentation** depends on **Domain** (uses Use Cases)
- **Data** depends on **Domain** (implements Repository interfaces)
- **Domain** depends on **NOTHING** (pure business logic)

#### Why This Hierarchy?

| Layer | Stability | Change Frequency | Dependencies |
|-------|-----------|------------------|--------------|
| **Domain** | Most stable | Rarely changes | NONE |
| **Data** | Moderate | Moderately changes | Domain interfaces |
| **Presentation** | Least stable | Frequently changes | Domain use cases |

**Benefits:**
- **Testability**: Test domain logic without UI or database
- **Flexibility**: Swap implementations (ML Kit ↔ Tesseract) without touching domain
- **Maintainability**: UI changes don't affect business logic

#### Layer Details

**1. DOMAIN LAYER (Core - Innermost)**

Location: `lib/features/*/domain/`

Contains:
- **Entities**: Pure business objects (no annotations, no framework code)
  ```dart
  class SheetMusic {
    final int id;
    final String title;
    final String composer;
    // Pure Dart, no dependencies
  }
  ```

- **Repository Interfaces**: Abstract contracts
  ```dart
  abstract class OCRRepository {
    Future<Either<Failure, OCRResult>> scanImage(File image);
    // Interface only, no implementation
  }
  ```

- **Use Cases**: Business operations
  ```dart
  class ScanImageUseCase {
    final OCRRepository _repository;  // Depends on interface
    
    Future<Either<Failure, OCRResult>> call(File image) {
      // Pure business logic
    }
  }
  ```

Dependencies: **NONE** (pure Dart)

**2. DATA LAYER (Infrastructure - Outer)**

Location: `lib/features/*/data/`

Contains:
- **Repository Implementations**: Concrete implementations of domain interfaces
  ```dart
  class MobileOCRRepository implements OCRRepository {  // ← Implements domain interface
    final MLKitDataSource _mlKit;
    
    @override
    Future<Either<Failure, OCRResult>> scanImage(File image) async {
      final result = await _mlKit.processImage(image);
      return Right(result.toEntity());  // ← Convert to domain entity
    }
  }
  ```

- **Data Sources**: External systems (ML Kit, Drift, File System)
  ```dart
  class MLKitDataSource {
    final TextRecognizer _recognizer = TextRecognizer();  // ML Kit SDK
    
    Future<OCRResultModel> processImage(File image) {
      // Implementation details
    }
  }
  ```

- **Models/DTOs**: Data transfer objects
  ```dart
  class OCRResultModel {
    final String text;
    
    OCRResult toEntity() => OCRResult(text: text);  // ← Convert to domain entity
  }
  ```

Dependencies: Domain interfaces, external SDKs (ML Kit, Drift)

**3. PRESENTATION LAYER (UI - Outer)**

Location: `lib/features/*/presentation/`

Contains:
- **Cubits**: State management
  ```dart
  class OCRScanCubit extends Cubit<OCRScanState> {
    final ScanImageUseCase _scanImageUseCase;  // ← Depends on domain use case
    
    Future<void> scanImage(File image) async {
      final result = await _scanImageUseCase(image);  // ← Calls domain layer
    }
  }
  ```

- **Pages/Widgets**: UI components
- **States**: UI state models (using freezed)

Dependencies: Domain (use cases, entities), Flutter, flutter_bloc

#### The "Onion" Visualization

```
                    ┌──────────────────────┐
                    │   Presentation      │
                    │   (Cubit, UI)        │
                    │                      │
        ┌───────────┴──────────────────────┴───────────┐
        │            Data Layer                        │
        │     (Repositories, Data Sources)             │
        │                                              │
        │       ┌──────────────────────────┐          │
        │       │   DOMAIN (Core)          │          │
        │       │                          │          │
        │       │  - Entities              │          │
        │       │  - Use Cases             │          │
        │       │  - Repository Interfaces │          │
        │       │                          │          │
        │       │  (NO dependencies)       │          │
        │       └──────────────────────────┘          │
        │                                              │
        └──────────────────────────────────────────────┘
```

#### Dependency Flow Example

```dart
// ============================================
// DOMAIN LAYER (center - no dependencies)
// ============================================

// Entity
class SheetMusic {
  final String title;
  final String composer;
}

// Repository Interface
abstract class SheetMusicRepository {
  Future<Either<Failure, SheetMusic>> add(SheetMusic sheet);
}

// Use Case
class AddSheetMusicUseCase {
  final SheetMusicRepository _repository;  // ← Depends on INTERFACE
  
  Future<Either<Failure, SheetMusic>> call(SheetMusic sheet) {
    return _repository.add(sheet);
  }
}

// ============================================
// DATA LAYER (outer - depends on domain)
// ============================================

// Model (DTO)
class SheetMusicModel {
  final String title;
  final String composer;
  
  SheetMusic toEntity() => SheetMusic(  // ← Converts to domain entity
    title: title,
    composer: composer,
  );
  
  factory SheetMusicModel.fromEntity(SheetMusic entity) {
    return SheetMusicModel(
      title: entity.title,
      composer: entity.composer,
    );
  }
}

// Repository Implementation
class SheetMusicRepositoryImpl implements SheetMusicRepository {  // ← Implements domain interface
  final AppDatabase _database;
  
  @override
  Future<Either<Failure, SheetMusic>> add(SheetMusic sheet) async {
    try {
      final model = SheetMusicModel.fromEntity(sheet);  // ← Domain → Data
      final result = await _database.insert(model);
      return Right(result.toEntity());  // ← Data → Domain
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

// ============================================
// PRESENTATION LAYER (outer - depends on domain)
// ============================================

// Cubit
class SheetMusicCubit extends Cubit<SheetMusicState> {
  final AddSheetMusicUseCase _addSheet;  // ← Depends on domain use case
  
  Future<void> addSheet(String title, String composer) async {
    final sheet = SheetMusic(  // ← Creates domain entity
      title: title,
      composer: composer,
    );
    
    final result = await _addSheet(sheet);  // ← Calls domain layer
    
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (newSheet) => emit(state.copyWith(sheets: [...state.sheets, newSheet])),
    );
  }
}
```

### 6.3 Key Architectural Patterns

#### Repository Pattern with Platform Abstraction
- Abstract repository interfaces in domain layer
- Platform-specific implementations in data layer
- Example: `MobileOCRRepository` (ML Kit) vs `DesktopOCRRepository` (Tesseract)

#### Cubit State Management
- Direct method calls (no event classes needed)
- Less boilerplate than full BLoC
- Perfect for forms and direct actions (scan, search, add)
- Examples: `OCRScanCubit`, `SearchCubit`, `SheetMusicCubit`

#### Use Case Pattern
- Each business operation is a separate use case class
- Testable without UI dependencies
- Reusable across mobile and desktop
- Examples: `AddSheetMusicUseCase`, `SearchSheetsUseCase`, `ScanImageUseCase`

#### Adaptive UI
- Shared Cubit logic, different layouts for mobile/desktop
- `LayoutBuilder` to detect screen size
- Platform-specific widgets where needed

### 6.3 State Management Flow

```
UI (BlocBuilder) → Cubit → Use Case → Repository → Data Source
                    ↓
                  State (emitted back to UI)
```

### 6.4 Platform-Specific Implementations

| Component | Mobile | Desktop |
|-----------|--------|---------|
| **OCR** | ML Kit | Tesseract (optional) |
| **Image Input** | Camera | File picker / drag-drop |
| **UI Layout** | Single-column list | Multi-column grid |
| **Bulk Operations** | Swipe actions | Multi-select + toolbar |

### 6.5 Code Examples

#### Repository Pattern with Platform Abstraction

```dart
// Domain layer - platform agnostic
abstract class OCRRepository {
  Future<Either<Failure, OCRResult>> scanImage(File image);
}

// Data layer - platform-specific implementations
class MobileOCRRepository implements OCRRepository {
  final MLKitDataSource _mlKit;
  
  MobileOCRRepository(this._mlKit);
  
  @override
  Future<Either<Failure, OCRResult>> scanImage(File image) async {
    try {
      final result = await _mlKit.processImage(image);
      return Right(result);
    } catch (e) {
      return Left(OCRFailure(e.toString()));
    }
  }
}

class DesktopOCRRepository implements OCRRepository {
  final TesseractDataSource _tesseract;
  
  DesktopOCRRepository(this._tesseract);
  
  @override
  Future<Either<Failure, OCRResult>> scanImage(File image) async {
    try {
      final result = await _tesseract.processImage(image);
      return Right(result);
    } catch (e) {
      return Left(OCRFailure(e.toString()));
    }
  }
}
```

#### OCR Scanning Cubit

```dart
// ocr/presentation/cubit/ocr_scan_state.dart
@freezed
class OCRScanState with _$OCRScanState {
  const factory OCRScanState.initial() = _Initial;
  const factory OCRScanState.scanning() = _Scanning;
  const factory OCRScanState.parsed({
    required String title,
    required String composer,
    required File image,
  }) = _Parsed;
  const factory OCRScanState.error(String message) = _Error;
}

// ocr/presentation/cubit/ocr_scan_cubit.dart
class OCRScanCubit extends Cubit<OCRScanState> {
  OCRScanCubit(this._scanImageUseCase, this._parseTextUseCase) 
    : super(const OCRScanState.initial());
  
  final ScanImageUseCase _scanImageUseCase;
  final ParseTextUseCase _parseTextUseCase;
  
  Future<void> scanImage(File image) async {
    emit(const OCRScanState.scanning());
    
    final result = await _scanImageUseCase(image);
    
    result.fold(
      (failure) => emit(OCRScanState.error(failure.message)),
      (ocrResult) {
        // Parse title and composer from OCR text
        final parsed = _parseTextUseCase(ocrResult.text);
        emit(OCRScanState.parsed(
          title: parsed.title ?? '',
          composer: parsed.composer ?? '',
          image: image,
        ));
      },
    );
  }
  
  void updateTitle(String title) {
    final current = state;
    if (current is _Parsed) {
      emit(current.copyWith(title: title));
    }
  }
  
  void updateComposer(String composer) {
    final current = state;
    if (current is _Parsed) {
      emit(current.copyWith(composer: composer));
    }
  }
}
```

#### OCR UI Usage

```dart
// Mobile OCR review screen
class OCRReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OCRScanCubit, OCRScanState>(
      builder: (context, state) {
        return state.when(
          initial: () => ScanButton(),
          scanning: () => Center(
            child: CircularProgressIndicator(),
          ),
          parsed: (title, composer, image) => EditForm(
            initialTitle: title,
            initialComposer: composer,
            coverImage: image,
            onTitleChanged: (value) => 
              context.read<OCRScanCubit>().updateTitle(value),
            onComposerChanged: (value) =>
              context.read<OCRScanCubit>().updateComposer(value),
            onSave: () => _saveSheetMusic(context, title, composer, image),
          ),
          error: (message) => ErrorWidget(message),
        );
      },
    );
  }
}
```

#### Search Cubit with Filters

```dart
// search/presentation/cubit/search_state.dart
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<SheetMusic> results,
    @Default('') String query,
    @Default([]) List<String> selectedTags,
    @Default(false) bool isLoading,
    String? error,
  }) = _SearchState;
}

// search/presentation/cubit/search_cubit.dart
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchUseCase) : super(const SearchState());
  
  final SearchSheetsUseCase _searchUseCase;
  Timer? _debounce;
  
  void search(String query) {
    // Debounce search input
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
    
    emit(state.copyWith(query: query, isLoading: true));
  }
  
  Future<void> _performSearch(String query) async {
    final result = await _searchUseCase(
      query: query,
      tags: state.selectedTags,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
        isLoading: false,
      )),
      (sheets) => emit(state.copyWith(
        results: sheets,
        isLoading: false,
        error: null,
      )),
    );
  }
  
  void toggleTag(String tag) {
    final tags = state.selectedTags.contains(tag)
      ? state.selectedTags.where((t) => t != tag).toList()
      : [...state.selectedTags, tag];
    
    emit(state.copyWith(selectedTags: tags));
    _performSearch(state.query); // Re-search with new filters
  }
  
  void clearFilters() {
    emit(state.copyWith(selectedTags: []));
    _performSearch(state.query);
  }
  
  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
```

#### Search UI Usage

```dart
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextField(
          onChanged: (query) => context.read<SearchCubit>().search(query),
          decoration: InputDecoration(hintText: 'Search sheets...'),
        ),
        
        // Tag filters
        BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Wrap(
              children: availableTags.map((tag) {
                final isSelected = state.selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => 
                    context.read<SearchCubit>().toggleTag(tag),
                );
              }).toList(),
            );
          },
        ),
        
        // Results
        Expanded(
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return Center(child: Text(state.error!));
              }
              return ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (_, i) => SheetCard(state.results[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

#### Use Case Pattern

```dart
// domain/usecases/add_sheet_music_use_case.dart
class AddSheetMusicUseCase {
  final SheetMusicRepository _repository;
  final ImageStorageRepository _imageStorage;

  AddSheetMusicUseCase(this._repository, this._imageStorage);

  Future<Either<Failure, SheetMusic>> call({
    required String title,
    required String composer,
    List<String> tags = const [],
    String notes = '',
    File? coverImage,
  }) async {
    // Validation
    if (title.trim().isEmpty) {
      return Left(ValidationFailure('Title is required'));
    }
    if (composer.trim().isEmpty) {
      return Left(ValidationFailure('Composer is required'));
    }
    
    // Store image if provided
    String? imagePath;
    if (coverImage != null) {
      final imageResult = await _imageStorage.saveImage(coverImage);
      imagePath = imageResult.fold(
        (failure) => null,
        (path) => path,
      );
    }
    
    // Create entity
    final sheet = SheetMusic(
      id: 0, // Will be set by database
      title: title.trim(),
      composer: composer.trim(),
      tags: tags,
      notes: notes.trim(),
      coverImagePath: imagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save to repository
    return await _repository.add(sheet);
  }
}
```

#### Sheet Music CRUD Cubit

```dart
// sheet_music/presentation/cubit/sheet_music_state.dart
@freezed
class SheetMusicState with _$SheetMusicState {
  const factory SheetMusicState({
    @Default([]) List<SheetMusic> sheets,
    @Default(false) bool isLoading,
    String? error,
  }) = _SheetMusicState;
}

// sheet_music/presentation/cubit/sheet_music_cubit.dart
class SheetMusicCubit extends Cubit<SheetMusicState> {
  SheetMusicCubit(
    this._getSheets,
    this._addSheet,
    this._updateSheet,
    this._deleteSheet,
  ) : super(const SheetMusicState());
  
  final GetSheetsUseCase _getSheets;
  final AddSheetMusicUseCase _addSheet;
  final UpdateSheetMusicUseCase _updateSheet;
  final DeleteSheetMusicUseCase _deleteSheet;
  
  Future<void> loadSheets() async {
    emit(state.copyWith(isLoading: true));
    
    final result = await _getSheets();
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
        isLoading: false,
      )),
      (sheets) => emit(state.copyWith(
        sheets: sheets,
        isLoading: false,
      )),
    );
  }
  
  Future<void> addSheetMusic(SheetMusic sheet) async {
    final result = await _addSheet(
      title: sheet.title,
      composer: sheet.composer,
      tags: sheet.tags,
      notes: sheet.notes,
      coverImage: sheet.coverImagePath != null 
        ? File(sheet.coverImagePath!) 
        : null,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (newSheet) {
        emit(state.copyWith(
          sheets: [...state.sheets, newSheet],
        ));
      },
    );
  }
  
  Future<void> deleteSheetMusic(int id) async {
    final result = await _deleteSheet(id);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        emit(state.copyWith(
          sheets: state.sheets.where((s) => s.id != id).toList(),
        ));
      },
    );
  }
  
  // Desktop bulk operations
  Future<void> bulkDelete(List<int> ids) async {
    for (final id in ids) {
      await _deleteSheet(id);
    }
    emit(state.copyWith(
      sheets: state.sheets.where((s) => !ids.contains(s.id)).toList(),
    ));
  }
}
```

#### Dependency Injection Setup (How Data Sources Are Used)

The data sources flow through the dependency chain:

```
Data Source → Repository → Use Case → Cubit → UI
```

```dart
// core/di/injection.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Platform detection
  final isDesktop = Platform.isWindows || 
                    Platform.isMacOS || 
                    Platform.isLinux;
  
  // ========================================
  // DATA SOURCES (Lowest level - ML models live here)
  // ========================================
  
  getIt.registerLazySingleton(() => AppDatabase());
  
  if (isDesktop) {
    getIt.registerLazySingleton<OCRDataSource>(
      () => TesseractDataSource(),  // ← Desktop OCR data source
    );
  } else {
    getIt.registerLazySingleton<OCRDataSource>(
      () => MLKitDataSource(),  // ← Mobile OCR data source (ML model)
    );
  }
  
  // ========================================
  // REPOSITORIES (Use data sources via constructor injection)
  // ========================================
  
  if (isDesktop) {
    getIt.registerLazySingleton<OCRRepository>(
      () => DesktopOCRRepository(getIt()),  // ← getIt() injects TesseractDataSource
    );
  } else {
    getIt.registerLazySingleton<OCRRepository>(
      () => MobileOCRRepository(getIt()),  // ← getIt() injects MLKitDataSource
    );
  }
  
  getIt.registerLazySingleton<SheetMusicRepository>(
    () => SheetMusicRepositoryImpl(getIt()),  // ← Injects AppDatabase
  );
  
  getIt.registerLazySingleton<ImageStorageRepository>(
    () => ImageStorageRepositoryImpl(),
  );
  
  // ========================================
  // USE CASES (Use repositories via constructor injection)
  // ========================================
  
  getIt.registerFactory(() => ScanImageUseCase(getIt()));  // ← Injects OCRRepository
  getIt.registerFactory(() => ParseTextUseCase());
  getIt.registerFactory(() => SearchSheetsUseCase(getIt()));
  getIt.registerFactory(() => GetSheetsUseCase(getIt()));
  getIt.registerFactory(() => AddSheetMusicUseCase(getIt(), getIt()));
  getIt.registerFactory(() => UpdateSheetMusicUseCase(getIt(), getIt()));
  getIt.registerFactory(() => DeleteSheetMusicUseCase(getIt()));
  
  // ========================================
  // CUBITS (Use use cases via constructor injection)
  // ========================================
  
  getIt.registerFactory(() => OCRScanCubit(
    getIt(),  // ← Injects ScanImageUseCase
    getIt(),  // ← Injects ParseTextUseCase
  ));
  getIt.registerFactory(() => SearchCubit(getIt()));
  getIt.registerFactory(() => SheetMusicCubit(
    getIt(), getIt(), getIt(), getIt(),
  ));
}
```

**Complete Call Stack Example:**

When user taps "Scan" button, this is what happens:

```
1. UI Widget
   ↓ calls
   context.read<OCRScanCubit>().scanImage(imageFile)

2. OCRScanCubit
   ↓ calls
   _scanImageUseCase(imageFile)

3. ScanImageUseCase
   ↓ calls
   _repository.scanImage(imageFile)

4. MobileOCRRepository
   ↓ calls
   _mlKit.processImage(imageFile)  ← Data source used here!

5. MLKitDataSource
   ↓ executes
   _recognizer.processImage(inputImage)  ← ML model runs!

6. Results bubble back up:
   MLKitDataSource → MobileOCRRepository → ScanImageUseCase → OCRScanCubit → UI
```

**Dependency Graph:**

```
MLKitDataSource (created first, singleton)
    ↓ injected into
MobileOCRRepository (created second, singleton)
    ↓ injected into
ScanImageUseCase (created on demand, factory)
    ↓ injected into
OCRScanCubit (created on demand, factory)
    ↓ injected into
UI Widget (created when page opens)
```

#### Adaptive UI Example

```dart
// Shared presentation logic, different layouts
class SheetMusicListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SheetMusicCubit>()..loadSheets(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return DesktopSheetMusicList(); // Multi-column, bulk ops
          }
          return MobileSheetMusicList();    // Single-column, swipe
        },
      ),
    );
  }
}

// Mobile layout
class MobileSheetMusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SheetMusicCubit, SheetMusicState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: state.sheets.length,
          itemBuilder: (context, index) {
            final sheet = state.sheets[index];
            return Dismissible(
              key: Key(sheet.id.toString()),
              onDismissed: (_) => context
                .read<SheetMusicCubit>()
                .deleteSheetMusic(sheet.id),
              child: SheetCard(sheet),
            );
          },
        );
      },
    );
  }
}

// Desktop layout
class DesktopSheetMusicList extends StatefulWidget {
  @override
  State<DesktopSheetMusicList> createState() => _DesktopSheetMusicListState();
}

class _DesktopSheetMusicListState extends State<DesktopSheetMusicList> {
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SheetMusicCubit, SheetMusicState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Bulk operations toolbar
            if (_selectedIds.isNotEmpty)
              Row(
                children: [
                  Text('${_selectedIds.length} selected'),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context
                        .read<SheetMusicCubit>()
                        .bulkDelete(_selectedIds.toList());
                      _selectedIds.clear();
                    },
                  ),
                ],
              ),
            
            // Grid view
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.sheets.length,
                itemBuilder: (context, index) {
                  final sheet = state.sheets[index];
                  final isSelected = _selectedIds.contains(sheet.id);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(sheet.id);
                        } else {
                          _selectedIds.add(sheet.id);
                        }
                      });
                    },
                    child: SheetCard(
                      sheet,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## 7. Logging & Observability

### 7.1 Overview

Logging is a **cross-cutting concern** that provides visibility into application behavior across all layers. This section defines the logging strategy, tools, and best practices for the Sheet Music Inventory App.

**Goals:**
- Debug issues in development efficiently
- Track user flows and errors in production
- Monitor OCR accuracy and performance
- Audit data operations (CRUD, imports, exports)
- Minimize performance overhead

### 7.2 Logging Library

**Primary Tool: `logger` package**

```yaml
# pubspec.yaml
dependencies:
  logger: ^2.0.0
```

**Why `logger`?**
- Colored console output for readability
- Multiple log levels (trace, debug, info, warning, error, fatal)
- Pretty printing of complex objects
- Customizable output (console, file, remote)
- Zero dependencies, works on all platforms
- Performance-friendly (no logging in release builds)

**Alternative Considered:**
- `logging` package: More basic, less features
- Custom solution: Reinventing the wheel

### 7.3 Logger Setup

**Location: `lib/core/utils/app_logger.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance for the entire app
final logger = _createLogger();

Logger _createLogger() {
  return Logger(
    // Only show debug/trace logs in debug mode
    level: kDebugMode ? Level.debug : Level.warning,
    
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,        // Stack trace depth
      errorMethodCount: 8,                    // Stack trace for errors
      lineLength: 120,                        // Console width
      colors: true,                           // Colored output
      printEmojis: true,                      // Emoji indicators
      printTime: true,                        // Timestamps
      noBoxingByDefault: !kDebugMode,         // Simple output in production
    ),
    
    // Output destinations
    output: MultiOutput([
      ConsoleOutput(),
      // Future: Add FileOutput for persistent logs
      // Future: Add crash reporting service (Sentry, Firebase Crashlytics)
    ]),
  );
}
```

**Import Pattern:**

```dart
// Every file that needs logging imports this
import 'package:sheet_scanner/core/utils/app_logger.dart';

// Then use:
logger.d('Debug message');
logger.i('Info message');
logger.e('Error message', error: e, stackTrace: st);
```

### 7.4 Log Levels & When to Use Them

| Level | Method | When to Use | Example |
|-------|--------|-------------|---------|
| **Trace** | `logger.t()` | Very detailed debugging (rarely used) | "Entered _parseTextUseCase.call()" |
| **Debug** | `logger.d()` | Development debugging, detailed info | "OCR confidence: 0.92 for 'Moonlight Sonata'" |
| **Info** | `logger.i()` | Important business events | "Sheet music added: id=123, title='Fur Elise'" |
| **Warning** | `logger.w()` | Unexpected but recoverable | "OCR returned empty text, falling back to manual entry" |
| **Error** | `logger.e()` | Errors requiring attention | "Failed to save image: disk full" |
| **Fatal** | `logger.f()` | Critical app-breaking errors | "Database corrupted, cannot proceed" |

**Log Level Filtering:**

```dart
// Development: See debug and above
kDebugMode ? Level.debug : Level.warning

// Production: Only warnings, errors, and fatal
Level.warning

// Verbose mode (for debugging specific issues)
Level.trace
```

### 7.5 Logging by Architecture Layer

#### 7.5.1 Domain Layer (Business Logic)

**What to Log:**
- Use case execution start/end
- Business rule violations
- Validation failures

**What NOT to Log:**
- Sensitive user data (names, addresses)
- Full entity dumps (log IDs instead)

**Example:**

```dart
// domain/usecases/add_sheet_music_use_case.dart
class AddSheetMusicUseCase {
  Future<Either<Failure, SheetMusic>> call({
    required String title,
    required String composer,
  }) async {
    logger.d('AddSheetMusicUseCase: Starting (title: "$title")');
    
    // Validation
    if (title.trim().isEmpty) {
      logger.w('AddSheetMusicUseCase: Validation failed - empty title');
      return Left(ValidationFailure('Title is required'));
    }
    
    // Save to repository
    final result = await _repository.add(sheet);
    
    return result.fold(
      (failure) {
        logger.e('AddSheetMusicUseCase: Failed to add sheet', 
                 error: failure);
        return Left(failure);
      },
      (savedSheet) {
        logger.i('AddSheetMusicUseCase: Success (id: ${savedSheet.id})');
        return Right(savedSheet);
      },
    );
  }
}
```

**Log Output:**

```
🐛 DEBUG  AddSheetMusicUseCase: Starting (title: "Fur Elise")
💡 INFO   AddSheetMusicUseCase: Success (id: 42)
```

#### 7.5.2 Data Layer (Repository & Data Sources)

**What to Log:**
- Database operations (insert, update, delete, query)
- File I/O operations
- OCR processing (timing, confidence)
- Network requests (if added in future)
- Data source initialization/disposal

**What NOT to Log:**
- Full database query results (log counts instead)
- Binary data (images, files)

**Example:**

```dart
// data/repositories/sheet_music_repository_impl.dart
class SheetMusicRepositoryImpl implements SheetMusicRepository {
  @override
  Future<Either<Failure, SheetMusic>> add(SheetMusic sheet) async {
    logger.d('SheetMusicRepository: Inserting sheet (title: "${sheet.title}")');
    
    try {
      final model = SheetMusicModel.fromEntity(sheet);
      final id = await _localDataSource.insert(model);
      
      logger.i('SheetMusicRepository: Insert success (id: $id)');
      return Right(sheet.copyWith(id: id));
    } catch (e, stackTrace) {
      logger.e('SheetMusicRepository: Insert failed', 
               error: e, 
               stackTrace: stackTrace);
      return Left(DatabaseFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<SheetMusic>>> getAll() async {
    logger.d('SheetMusicRepository: Fetching all sheets');
    
    try {
      final models = await _localDataSource.getAll();
      final sheets = models.map((m) => m.toEntity()).toList();
      
      logger.i('SheetMusicRepository: Fetched ${sheets.length} sheets');
      return Right(sheets);
    } catch (e, stackTrace) {
      logger.e('SheetMusicRepository: Fetch failed', 
               error: e, 
               stackTrace: stackTrace);
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

**OCR Data Source Example:**

```dart
// data/datasources/ml_kit_data_source.dart
class MLKitDataSource {
  Future<OCRResultModel> processImage(File image) async {
    final startTime = DateTime.now();
    logger.d('MLKitDataSource: Starting OCR (path: ${image.path})');
    
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _recognizer.processImage(inputImage);
      
      final duration = DateTime.now().difference(startTime);
      final confidence = _calculateConfidence(recognizedText);
      
      logger.i('MLKitDataSource: OCR complete '
               '(duration: ${duration.inMilliseconds}ms, '
               'confidence: ${confidence.toStringAsFixed(2)}, '
               'blocks: ${recognizedText.blocks.length})');
      
      return OCRResultModel(
        text: recognizedText.text,
        blocks: recognizedText.blocks.map((b) => ...).toList(),
        confidence: confidence,
      );
    } catch (e, stackTrace) {
      logger.e('MLKitDataSource: OCR failed', 
               error: e, 
               stackTrace: stackTrace);
      rethrow;
    }
  }
}
```

**Log Output:**

```
🐛 DEBUG  MLKitDataSource: Starting OCR (path: /data/images/sheet_42.jpg)
💡 INFO   MLKitDataSource: OCR complete (duration: 342ms, confidence: 0.89, blocks: 12)
```

#### 7.5.3 Presentation Layer (Cubit & UI)

**What to Log:**
- User actions (button taps, navigation)
- State transitions
- UI errors (form validation, etc.)
- Performance bottlenecks (slow renders)

**What NOT to Log:**
- Every widget build
- Mouse/touch events (too noisy)
- Styling/layout calculations

**Example:**

```dart
// presentation/cubit/ocr_scan_cubit.dart
class OCRScanCubit extends Cubit<OCRScanState> {
  Future<void> scanImage(File image) async {
    logger.d('OCRScanCubit: User initiated scan');
    emit(const OCRScanState.scanning());
    
    final result = await _scanImageUseCase(image);
    
    result.fold(
      (failure) {
        logger.w('OCRScanCubit: Scan failed - ${failure.message}');
        emit(OCRScanState.error(failure.message));
      },
      (ocrResult) {
        final parsed = _parseTextUseCase(ocrResult.text);
        logger.i('OCRScanCubit: Scan success '
                 '(title: "${parsed.title}", '
                 'composer: "${parsed.composer}", '
                 'confidence: ${parsed.confidence.toStringAsFixed(2)})');
        emit(OCRScanState.parsed(
          title: parsed.title ?? '',
          composer: parsed.composer ?? '',
          image: image,
        ));
      },
    );
  }
  
  void updateTitle(String title) {
    logger.d('OCRScanCubit: User updated title to "$title"');
    final current = state;
    if (current is _Parsed) {
      emit(current.copyWith(title: title));
    }
  }
}
```

**UI Widget Example:**

```dart
// presentation/pages/ocr_review_page.dart
class OCRReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<OCRScanCubit, OCRScanState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            logger.w('OCRReviewPage: Showing error to user - $message');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<OCRScanCubit, OCRScanState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildScanButton(context),
            scanning: () {
              logger.d('OCRReviewPage: Rendering scanning state');
              return Center(child: CircularProgressIndicator());
            },
            parsed: (title, composer, image) => _buildEditForm(
              context, title, composer, image,
            ),
            error: (message) => _buildErrorWidget(message),
          );
        },
      ),
    );
  }
  
  void _onSavePressed(BuildContext context, SheetMusic sheet) {
    logger.i('OCRReviewPage: User saved sheet (title: "${sheet.title}")');
    context.read<SheetMusicCubit>().addSheetMusic(sheet);
    Navigator.pop(context);
  }
}
```

### 7.6 Logging Best Practices

#### DO:
- ✅ Log at appropriate levels (debug for details, info for events)
- ✅ Include context (IDs, filenames, counts, durations)
- ✅ Log errors with stack traces: `logger.e('msg', error: e, stackTrace: st)`
- ✅ Log operation start and completion for long-running tasks
- ✅ Use structured messages: `"Operation: result (detail: value)"`
- ✅ Log business events: "User added sheet", "Export completed"

#### DON'T:
- ❌ Log sensitive data (passwords, tokens, personal info)
- ❌ Log in tight loops (use sampling or aggregate)
- ❌ Log entire objects (use IDs and key fields)
- ❌ Log binary data (images, files)
- ❌ Use logging for user-facing messages (use UI instead)
- ❌ Leave debug logs in production code paths

#### Performance Considerations:

```dart
// ❌ BAD: String interpolation happens even if log level is disabled
logger.d('Processing ${expensiveOperation()} items');

// ✅ GOOD: Use lazy evaluation
logger.d(() => 'Processing ${expensiveOperation()} items');

// ✅ BETTER: Check level first for expensive operations
if (kDebugMode) {
  logger.d('Processing ${expensiveOperation()} items');
}
```

### 7.7 Error Logging Pattern

**Consistent error handling across all layers:**

```dart
try {
  // Operation
  final result = await _repository.someOperation();
  logger.i('SomeClass: Operation success');
  return Right(result);
} catch (e, stackTrace) {
  logger.e('SomeClass: Operation failed', 
           error: e, 
           stackTrace: stackTrace);
  return Left(SomeFailure(e.toString()));
}
```

**For errors that should never happen (assertions):**

```dart
if (critical condition violated) {
  logger.f('CRITICAL: Database schema corrupted!');
  throw StateError('Cannot proceed - data integrity violated');
}
```

### 7.8 Production Logging Configuration

**Disable verbose logs in release builds:**

```dart
// core/utils/app_logger.dart
import 'package:flutter/foundation.dart';

final logger = Logger(
  // Production: Only warnings and errors
  level: kReleaseMode ? Level.warning : Level.debug,
  
  printer: SimplePrinter(
    printTime: true,
    colors: kDebugMode, // No colors in production logs
  ),
  
  output: kReleaseMode 
    ? FileOutput(file: _getLogFile())       // Save to file in production
    : ConsoleOutput(),                      // Console in debug
);
```

**Future: Remote Crash Reporting**

For production apps, integrate with crash reporting services:

```dart
// Add to pubspec.yaml (future enhancement)
dependencies:
  sentry_flutter: ^7.0.0
  # OR
  firebase_crashlytics: ^3.4.0

// core/utils/app_logger.dart
output: MultiOutput([
  ConsoleOutput(),
  if (kReleaseMode) SentryOutput(),  // Send errors to Sentry
]),
```

### 7.9 Viewing Logs on Mobile Devices

Viewing logs on physical mobile devices requires platform-specific tools since you can't see console output directly.

#### iOS (Physical Device)

**Option 1: Xcode Console (Recommended)**
```bash
# 1. Connect iPhone via USB
# 2. Open Xcode
# 3. Window → Devices and Simulators
# 4. Select your device
# 5. Click "Open Console" button
# 6. Run your Flutter app
# 7. Filter logs by typing "flutter" or your app name
```

**Option 2: Console.app (macOS)**
```bash
# 1. Connect iPhone via USB
# 2. Open Console.app (Applications → Utilities → Console)
# 3. Select your iPhone from the sidebar
# 4. Run your Flutter app
# 5. Use search/filter to find your logs
```

**Option 3: Terminal via ios-deploy**
```bash
# Install ios-deploy
brew install ios-deploy

# View logs
ios-deploy --debug --bundle /path/to/Runner.app
```

#### Android (Physical Device)

**Option 1: Android Studio Logcat (Recommended)**
```bash
# 1. Enable Developer Options on Android device
# 2. Enable USB Debugging
# 3. Connect via USB
# 4. Open Android Studio
# 5. View → Tool Windows → Logcat
# 6. Run your Flutter app
# 7. Filter by package name or "flutter"
```

**Option 2: Command Line (adb logcat)**
```bash
# View all logs
adb logcat

# Filter by app package
adb logcat | grep com.yourcompany.sheet_scanner

# Filter by Flutter
adb logcat | grep flutter

# Clear previous logs first
adb logcat -c && adb logcat

# Save logs to file
adb logcat > logs.txt
```

**Option 3: VS Code Flutter Extension**
```bash
# 1. Install Flutter extension in VS Code
# 2. Connect device via USB
# 3. Run app with "Flutter: Run Flutter App"
# 4. Logs appear in Debug Console automatically
# 5. Can filter/search in the console
```

#### Flutter Command Line

Works for both iOS and Android:

```bash
# Run app and see logs in terminal
flutter run

# Run in verbose mode
flutter run -v

# Run and filter logs
flutter run | grep "MyLogTag"
```

#### In-App Log Viewer (Development Only)

For easier debugging on physical devices, add an in-app log viewer:

```dart
// lib/core/utils/app_logger.dart
import 'package:logger/logger.dart';

class InMemoryOutput extends LogOutput {
  static final List<OutputEvent> logs = [];
  static const int maxLogs = 1000;
  
  @override
  void output(OutputEvent event) {
    logs.add(event);
    if (logs.length > maxLogs) {
      logs.removeAt(0); // Keep only recent logs
    }
  }
}

// Update logger setup
Logger _createLogger() {
  return Logger(
    level: kDebugMode ? Level.debug : Level.warning,
    printer: PrettyPrinter(/* ... */),
    output: MultiOutput([
      ConsoleOutput(),
      if (kDebugMode) InMemoryOutput(), // Store logs in memory
    ]),
  );
}
```

**Log Viewer Screen:**

```dart
// lib/core/debug/log_viewer_page.dart (Debug builds only)
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

class LogViewerPage extends StatefulWidget {
  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  String _filter = '';
  
  @override
  Widget build(BuildContext context) {
    final filteredLogs = InMemoryOutput.logs.where((event) {
      final logText = event.lines.join(' ').toLowerCase();
      return logText.contains(_filter.toLowerCase());
    }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs (${filteredLogs.length})'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() => InMemoryOutput.logs.clear());
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _exportLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter logs...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // Show newest logs at top
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final event = filteredLogs[filteredLogs.length - 1 - index];
                return LogEntryWidget(event: event);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportLogs() async {
    final logsText = InMemoryOutput.logs
      .map((e) => e.lines.join('\n'))
      .join('\n---\n');
    
    // Use share_plus package
    await Share.share(logsText, subject: 'App Logs');
  }
}

class LogEntryWidget extends StatelessWidget {
  final OutputEvent event;
  
  const LogEntryWidget({required this.event});
  
  @override
  Widget build(BuildContext context) {
    // Color-code by log level
    final color = _getColorForLevel(event.level);
    
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: SelectableText(
        event.lines.join('\n'),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }
  
  Color _getColorForLevel(Level level) {
    switch (level) {
      case Level.debug: return Colors.blue;
      case Level.info: return Colors.green;
      case Level.warning: return Colors.orange;
      case Level.error: return Colors.red;
      case Level.fatal: return Colors.purple;
      default: return Colors.grey;
    }
  }
}
```

**Add to app (debug only):**

```dart
// lib/main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: kDebugMode 
        ? HomePageWithDebugMenu()  // Has floating button to open log viewer
        : HomePage(),
    );
  }
}

// lib/presentation/pages/home_page.dart
class HomePageWithDebugMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sheet Music')),
      body: HomePage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LogViewerPage()),
          );
        },
        child: Icon(Icons.bug_report),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
```

#### Remote Logging (Production)

For production apps, logs should be sent to remote services:

**Option 1: Sentry**
```dart
// pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0

// main.dart
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kReleaseMode ? 'production' : 'development';
    },
    appRunner: () => runApp(MyApp()),
  );
}

// Custom logger output
class SentryOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (event.level.index >= Level.warning.index) {
      Sentry.captureMessage(
        event.lines.join('\n'),
        level: _convertLevel(event.level),
      );
    }
  }
  
  SentryLevel _convertLevel(Level level) {
    switch (level) {
      case Level.warning: return SentryLevel.warning;
      case Level.error: return SentryLevel.error;
      case Level.fatal: return SentryLevel.fatal;
      default: return SentryLevel.info;
    }
  }
}
```

**Option 2: Firebase Crashlytics**
```dart
// pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.0

// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}

// Custom logger output
class FirebaseOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (event.level.index >= Level.warning.index) {
      FirebaseCrashlytics.instance.log(event.lines.join('\n'));
    }
  }
}
```

#### Summary: When to Use Which Method

| Scenario | Best Method |
|----------|-------------|
| **iOS Simulator** | Xcode console or `flutter run` |
| **iOS Physical Device** | Xcode Console or Console.app |
| **Android Emulator** | Android Studio Logcat or `flutter run` |
| **Android Physical Device** | `adb logcat` or Android Studio Logcat |
| **Quick debugging on device** | In-app log viewer (development) |
| **Production monitoring** | Sentry or Firebase Crashlytics |
| **Sharing logs with team** | In-app export + share |

### 7.10 Testing with Logs

**Capture logs in tests for verification:**

```dart
// test/domain/usecases/add_sheet_music_use_case_test.dart
void main() {
  late AddSheetMusicUseCase useCase;
  late MockRepository mockRepo;
  
  setUp(() {
    // Use a test logger that captures output
    Logger.level = Level.nothing; // Suppress logs in tests
  });
  
  test('should log success when sheet is added', () async {
    // Test implementation
  });
}
```

### 7.11 Logging Checklist by Feature

When implementing each feature module, ensure logging covers:

**OCR Module:**
- [ ] Image file path and size before OCR
- [ ] OCR processing duration and confidence
- [ ] Text parsing success/failure
- [ ] User corrections to OCR results

**Search Module:**
- [ ] Search query and filters
- [ ] Number of results returned
- [ ] Search execution time (if > 100ms)
- [ ] FTS5 query errors

**Sheet Music CRUD:**
- [ ] Create/update/delete operations with IDs
- [ ] Bulk operations (count affected)
- [ ] Database errors with context

**Backup Module:**
- [ ] Export start/completion with file size
- [ ] Import start/completion with counts
- [ ] File I/O errors
- [ ] Compression/decompression progress

**File Storage:**
- [ ] Image save/load operations
- [ ] Disk space warnings
- [ ] File cleanup operations

### 7.12 Dependencies

```yaml
# pubspec.yaml
dependencies:
  logger: ^2.0.0

# Future enhancements:
# sentry_flutter: ^7.0.0        # Crash reporting
# firebase_crashlytics: ^3.4.0   # Alternative crash reporting
```

### 7.13 Summary

**Key Points:**
1. Use `logger` package for all logging
2. Import from `core/utils/app_logger.dart`
3. Log at appropriate levels (debug for details, info for events)
4. Include context (IDs, durations, counts)
5. Never log sensitive data
6. Disable verbose logs in production
7. Log errors with stack traces

**Logging Flow:**

```
Development:
  User Action → Cubit (log action) → Use Case (log start/end) 
  → Repository (log DB operation) → Data Source (log details)
  
Production:
  Only log warnings and errors to file/remote service
```

---

## 8. Data Model

See previous message for full details.

## 9. Feature Module Details

### 9.1 OCR Module

#### Purpose
Extract title and composer information from sheet music cover images using optical character recognition.

#### Architecture

```
features/ocr/
├── data/
│   ├── datasources/
│   │   ├── ocr_data_source.dart          # Abstract interface
│   │   ├── ml_kit_data_source.dart       # Mobile implementation
│   │   └── tesseract_data_source.dart    # Desktop implementation
│   ├── models/
│   │   ├── ocr_result_model.dart         # DTO for OCR results
│   │   └── parsed_sheet_info_model.dart  # DTO for parsed data
│   └── repositories/
│       ├── mobile_ocr_repository.dart
│       └── desktop_ocr_repository.dart
├── domain/
│   ├── entities/
│   │   ├── ocr_result.dart               # Business entity
│   │   └── parsed_sheet_info.dart        # Parsed title/composer
│   ├── repositories/
│   │   └── ocr_repository.dart           # Abstract interface
│   └── usecases/
│       ├── scan_image_use_case.dart      # Perform OCR scan
│       └── parse_text_use_case.dart      # Extract title/composer
└── presentation/
    ├── cubit/
    │   ├── ocr_scan_cubit.dart
    │   └── ocr_scan_state.dart
    ├── pages/
    │   ├── camera_scan_page.dart         # Mobile camera interface
    │   └── ocr_review_page.dart          # Edit OCR results
    └── widgets/
        ├── scan_overlay_widget.dart      # Camera viewfinder overlay
        └── ocr_confidence_indicator.dart # Show OCR confidence
```

#### Data Flow

The OCR module uses a **two-step pipeline**:

```
User Image → ScanImageUseCase → OCRResult (raw text) → ParseTextUseCase → ParsedSheetInfo (title/composer)
```

**Step 1: Image → Raw Text**
- `ScanImageUseCase` validates the image and calls the OCR engine (ML Kit or Tesseract)
- Returns `OCRResult` containing raw text and metadata

**Step 2: Raw Text → Structured Data**
- `ParseTextUseCase` applies heuristics to extract title and composer from raw OCR text
- Returns `ParsedSheetInfo` with structured fields

**Why separate?**
- **Testability**: Can test parsing logic without running OCR
- **Reusability**: Parse text from manual entry, clipboard, or different OCR engines
- **Flexibility**: Desktop can skip OCR entirely and go straight to manual entry

```
┌─────────────┐
│ User Image  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│ ScanImageUseCase        │
│ - Validate image        │
│ - Call ML Kit/Tesseract │
│ - Return OCRResult      │
└──────┬──────────────────┘
       │
       │ OCRResult { 
       │   text: "Moonlight Sonata\nby Beethoven",
       │   blocks: [...],
       │   confidence: 0.95
       │ }
       │
       ▼
┌─────────────────────────┐
│ ParseTextUseCase        │
│ - Extract title         │
│ - Extract composer      │
│ - Calculate confidence  │
└──────┬──────────────────┘
       │
       │ ParsedSheetInfo {
       │   title: "Moonlight Sonata",
       │   composer: "Beethoven",
       │   confidence: 0.9
       │ }
       │
       ▼
┌─────────────────────────┐
│ OCRScanState.parsed     │
│ - User reviews/edits    │
└─────────────────────────┘
```

#### Use Cases

**ScanImageUseCase**
```dart
class ScanImageUseCase {
  final OCRRepository _repository;
  
  Future<Either<Failure, OCRResult>> call(File image) async {
    // Validate image
    if (!await image.exists()) {
      return Left(ValidationFailure('Image file not found'));
    }
    
    // Check file size (max 10MB)
    final fileSize = await image.length();
    if (fileSize > 10 * 1024 * 1024) {
      return Left(ValidationFailure('Image too large (max 10MB)'));
    }
    
    // Perform OCR
    return await _repository.scanImage(image);
  }
}
```

**Output: OCRResult Entity**
```dart
class OCRResult {
  final String text;              // Raw OCR text
  final List<TextBlock> blocks;   // Text regions with bounding boxes
  final double confidence;        // Overall OCR confidence (0.0 - 1.0)
  
  const OCRResult({
    required this.text,
    required this.blocks,
    required this.confidence,
  });
}
```

**ParseTextUseCase**
```dart
class ParseTextUseCase {
  // Input: Raw OCR text from ScanImageUseCase
  // Output: Structured ParsedSheetInfo
  ParsedSheetInfo call(String ocrText) {
    // Parsing heuristics for sheet music covers
    final lines = ocrText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    String? title;
    String? composer;
    
    // Heuristic 1: Title is usually largest text at top
    if (lines.isNotEmpty) {
      title = lines.first.trim();
    }
    
    // Heuristic 2: Composer often has "by", "composed by", or is second line
    for (var line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('by ') || 
          lower.contains('composed') || 
          lower.contains('music by')) {
        composer = line
          .replaceAll(RegExp(r'(by|composed|music)\s*', caseSensitive: false), '')
          .trim();
        break;
      }
    }
    
    // Fallback: second line is composer
    composer ??= lines.length > 1 ? lines[1].trim() : null;
    
    return ParsedSheetInfo(
      title: title,
      composer: composer,
      rawText: ocrText,
      confidence: _calculateConfidence(title, composer),
    );
  }
  
  double _calculateConfidence(String? title, String? composer) {
    if (title == null) return 0.0;
    if (composer == null) return 0.5;
    
    // Higher confidence if both found and reasonable length
    if (title.length > 3 && composer.length > 3) return 0.9;
    return 0.7;
  }
}
```

**Output: ParsedSheetInfo Entity**
```dart
class ParsedSheetInfo {
  final String? title;        // Extracted title
  final String? composer;     // Extracted composer
  final String rawText;       // Original OCR text for reference
  final double confidence;    // Parsing confidence (0.0 - 1.0)
  
  const ParsedSheetInfo({
    this.title,
    this.composer,
    required this.rawText,
    required this.confidence,
  });
}
```

#### Cubit Integration

The cubit orchestrates both use cases:

```dart
class OCRScanCubit extends Cubit<OCRScanState> {
  OCRScanCubit(this._scanImageUseCase, this._parseTextUseCase) 
    : super(const OCRScanState.initial());
  
  final ScanImageUseCase _scanImageUseCase;
  final ParseTextUseCase _parseTextUseCase;
  
  // Mobile: camera capture → OCR → parse
  Future<void> scanImage(File image) async {
    emit(const OCRScanState.scanning());
    
    // Step 1: Run OCR to get raw text
    final scanResult = await _scanImageUseCase(image);
    
    scanResult.fold(
      (failure) => emit(OCRScanState.error(failure.message)),
      (ocrResult) {
        // Step 2: Parse raw text to extract title/composer
        final parsed = _parseTextUseCase(ocrResult.text);
        
        emit(OCRScanState.parsed(
          title: parsed.title ?? '',
          composer: parsed.composer ?? '',
          image: image,
          confidence: parsed.confidence,
          rawText: ocrResult.text,
        ));
      },
    );
  }
  
  // Desktop: upload image → skip OCR → manual entry
  void uploadImageWithoutOCR(File image) {
    emit(OCRScanState.parsed(
      title: '',
      composer: '',
      image: image,
      confidence: 0.0,
      rawText: '',
    ));
  }
  
  // Alternative: paste text from clipboard → parse
  void parseManualText(String text, File image) {
    final parsed = _parseTextUseCase(text);
    
    emit(OCRScanState.parsed(
      title: parsed.title ?? '',
      composer: parsed.composer ?? '',
      image: image,
      confidence: parsed.confidence,
      rawText: text,
    ));
  }
  
  // User edits after reviewing OCR results
  void updateTitle(String title) {
    final current = state;
    if (current is _Parsed) {
      emit(current.copyWith(title: title));
    }
  }
  
  void updateComposer(String composer) {
    final current = state;
    if (current is _Parsed) {
      emit(current.copyWith(composer: composer));
    }
  }
}
```

#### Data Sources (ML Models Live Here)

**ML Kit (Mobile) - On-Device ML Model**

The ML model is encapsulated in the data source layer:

```dart
class MLKitDataSource implements OCRDataSource {
  // This is the ML model ↓
  final TextRecognizer _recognizer = TextRecognizer();
  
  @override
  Future<OCRResultModel> processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    
    // ML inference happens here ↓
    // Under the hood:
    // 1. Text detection (CNN finds text regions)
    // 2. Text recognition (LSTM recognizes characters)
    // 3. Language model post-processing
    final recognizedText = await _recognizer.processImage(inputImage);
    
    return OCRResultModel(
      text: recognizedText.text,
      blocks: recognizedText.blocks.map((b) => TextBlockModel(
        text: b.text,
        boundingBox: b.boundingBox,
        confidence: b.confidence ?? 0.0,
      )).toList(),
    );
  }
  
  @override
  Future<void> dispose() async {
    await _recognizer.close(); // Cleanup ML model
  }
}
```

**How ML Kit Works:**
- **Model Download**: ~10-20MB pre-trained model (downloaded on first use)
- **On-Device**: Runs entirely on device (no internet needed, privacy-first)
- **Platforms**: iOS (CoreML), Android (TensorFlow Lite)
- **Architecture**: CNN for detection + LSTM for recognition
- **Performance**: ~100-500ms per image on modern devices

**Tesseract (Desktop - Optional) - Traditional OCR Engine**

```dart
class TesseractDataSource implements OCRDataSource {
  @override
  Future<OCRResultModel> processImage(File image) async {
    // Optional: only if desktop OCR is needed
    // Tesseract uses traditional CV (not deep learning)
    final result = await FlutterTesseractOcr.extractText(
      image.path,
      language: 'eng',
      args: {
        "psm": "3", // Fully automatic page segmentation
        "preserve_interword_spaces": "1",
      },
    );
    
    return OCRResultModel(
      text: result,
      blocks: [], // Tesseract doesn't provide block info easily
    );
  }
  
  @override
  Future<void> dispose() async {
    // No cleanup needed
  }
}
```

**How Tesseract Works:**
- **Model Type**: Traditional computer vision (edge detection, image processing)
- **Not Deep Learning**: Uses hand-crafted features, not neural networks
- **Language Models**: Pre-trained character recognition models per language
- **Performance**: Slower than ML Kit (~1-3s per image), but works on all platforms
- **Desktop-Only**: Optional feature for desktop users who want OCR

#### States

```dart
@freezed
class OCRScanState with _$OCRScanState {
  const factory OCRScanState.initial() = _Initial;
  const factory OCRScanState.scanning() = _Scanning;
  const factory OCRScanState.parsed({
    required String title,
    required String composer,
    required File image,
    required double confidence,
    required String rawText,
  }) = _Parsed;
  const factory OCRScanState.error(String message) = _Error;
}
```

#### UI Flow

**Mobile:**
1. User taps "Scan" button
2. Camera permission check
3. Camera preview with overlay guide
4. User captures image
5. OCR processing (show loading)
6. Review screen with parsed title/composer
7. User edits if needed
8. Save to database

**Desktop:**
1. User clicks "Upload Image" or drags file
2. File picker dialog
3. Optional: OCR processing (or skip for manual entry)
4. Review screen with parsed/empty fields
5. User enters/edits data
6. Save to database

#### Error Handling

- **Camera permission denied**: Show settings prompt
- **OCR fails**: Allow manual entry with pre-filled empty form
- **Low confidence**: Show warning, allow user to re-scan or edit
- **No text detected**: Fallback to manual entry

#### Dependencies

**Mobile:**
- `google_mlkit_text_recognition: ^0.11.0`
- `camera: ^0.10.0`
- `image_picker: ^1.0.0`

**Desktop (Optional):**
- `flutter_tesseract_ocr: ^0.4.0` (only if desktop OCR needed)
- `file_picker: ^6.0.0`

### 9.2 Search Module

#### Purpose
Fast, full-text search across sheet music with filtering by tags, composer, and advanced sorting.

#### Architecture

```
features/search/
├── data/
│   ├── datasources/
│   │   └── search_local_data_source.dart  # FTS5 queries
│   └── repositories/
│       └── search_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── search_query.dart              # Search parameters
│   │   └── search_result.dart             # Search results
│   ├── repositories/
│   │   └── search_repository.dart
│   └── usecases/
│       ├── search_sheets_use_case.dart
│       ├── get_search_suggestions_use_case.dart
│       └── get_all_tags_use_case.dart
└── presentation/
    ├── cubit/
    │   ├── search_cubit.dart
    │   └── search_state.dart
    ├── pages/
    │   └── search_page.dart
    └── widgets/
        ├── search_bar_widget.dart
        ├── filter_chips_widget.dart
        ├── sort_dropdown_widget.dart
        └── search_results_list.dart
```

#### Use Cases

**SearchSheetsUseCase**
```dart
class SearchSheetsUseCase {
  final SearchRepository _repository;
  
  Future<Either<Failure, List<SheetMusic>>> call({
    String query = '',
    List<String> tags = const [],
    SortOrder sortOrder = SortOrder.titleAsc,
    int limit = 100,
  }) async {
    // Sanitize query for FTS5
    final sanitizedQuery = _sanitizeQuery(query);
    
    return await _repository.search(
      query: sanitizedQuery,
      tags: tags,
      sortOrder: sortOrder,
      limit: limit,
    );
  }
  
  String _sanitizeQuery(String query) {
    // Remove FTS5 special characters that could cause errors
    return query
      .replaceAll(RegExp(r'[^\w\s-]'), ' ')
      .trim();
  }
}
```

**GetSearchSuggestionsUseCase**
```dart
class GetSearchSuggestionsUseCase {
  final SearchRepository _repository;
  
  Future<Either<Failure, List<String>>> call(String query) async {
    if (query.length < 2) return Right([]);
    
    // Get suggestions from composers and titles
    return await _repository.getSuggestions(query);
  }
}
```

**GetAllTagsUseCase**
```dart
class GetAllTagsUseCase {
  final SheetMusicRepository _repository;
  
  Future<Either<Failure, List<TagWithCount>>> call() async {
    // Return all tags with usage counts for filter UI
    return await _repository.getAllTagsWithCounts();
  }
}
```

#### Data Source Implementation

```dart
class SearchLocalDataSource {
  final AppDatabase _database;
  
  Future<List<SheetMusicData>> search({
    required String query,
    required List<String> tags,
    required SortOrder sortOrder,
    int limit = 100,
  }) async {
    // Build FTS5 query
    final ftsQuery = _buildFTS5Query(query);
    
    // Start with base query
    var selectQuery = _database.select(_database.sheetMusic);
    
    // Add FTS5 full-text search if query provided
    if (ftsQuery.isNotEmpty) {
      selectQuery = selectQuery.join([
        innerJoin(
          _database.sheetMusicFts,
          _database.sheetMusicFts.rowid.equalsExp(
            _database.sheetMusic.id
          ),
        ),
      ])..where(_database.sheetMusicFts.text.match(ftsQuery));
    }
    
    // Add tag filtering
    if (tags.isNotEmpty) {
      selectQuery = selectQuery.where((row) {
        // JSON contains check for tags
        return tags.every((tag) => 
          row.tags.contains(tag)
        );
      });
    }
    
    // Add sorting
    switch (sortOrder) {
      case SortOrder.titleAsc:
        selectQuery = selectQuery
          ..orderBy([(_) => OrderingTerm.asc(_database.sheetMusic.title)]);
        break;
      case SortOrder.titleDesc:
        selectQuery = selectQuery
          ..orderBy([(_) => OrderingTerm.desc(_database.sheetMusic.title)]);
        break;
      case SortOrder.composerAsc:
        selectQuery = selectQuery
          ..orderBy([(_) => OrderingTerm.asc(_database.sheetMusic.composer)]);
        break;
      case SortOrder.recentFirst:
        selectQuery = selectQuery
          ..orderBy([(_) => OrderingTerm.desc(_database.sheetMusic.createdAt)]);
        break;
    }
    
    // Apply limit
    selectQuery = selectQuery..limit(limit);
    
    return await selectQuery.get();
  }
  
  String _buildFTS5Query(String query) {
    if (query.isEmpty) return '';
    
    final terms = query.split(' ').where((t) => t.isNotEmpty);
    
    // Build FTS5 query with prefix matching
    return terms.map((term) => '$term*').join(' ');
  }
}
```

#### States

```dart
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<SheetMusic> results,
    @Default('') String query,
    @Default([]) List<String> selectedTags,
    @Default([]) List<TagWithCount> availableTags,
    @Default(SortOrder.titleAsc) SortOrder sortOrder,
    @Default(false) bool isLoading,
    @Default([]) List<String> suggestions,
    String? error,
  }) = _SearchState;
}
```

#### Cubit Implementation

```dart
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._searchUseCase,
    this._getAllTagsUseCase,
    this._getSuggestionsUseCase,
  ) : super(const SearchState());
  
  final SearchSheetsUseCase _searchUseCase;
  final GetAllTagsUseCase _getAllTagsUseCase;
  final GetSearchSuggestionsUseCase _getSuggestionsUseCase;
  
  Timer? _debounce;
  
  Future<void> initialize() async {
    // Load available tags
    final tagsResult = await _getAllTagsUseCase();
    tagsResult.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (tags) => emit(state.copyWith(availableTags: tags)),
    );
    
    // Perform initial search
    _performSearch();
  }
  
  void search(String query) {
    _debounce?.cancel();
    
    emit(state.copyWith(query: query, isLoading: true));
    
    // Get suggestions immediately
    _loadSuggestions(query);
    
    // Debounce actual search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }
  
  Future<void> _performSearch() async {
    emit(state.copyWith(isLoading: true));
    
    final result = await _searchUseCase(
      query: state.query,
      tags: state.selectedTags,
      sortOrder: state.sortOrder,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
        isLoading: false,
      )),
      (sheets) => emit(state.copyWith(
        results: sheets,
        isLoading: false,
        error: null,
      )),
    );
  }
  
  Future<void> _loadSuggestions(String query) async {
    if (query.length < 2) {
      emit(state.copyWith(suggestions: []));
      return;
    }
    
    final result = await _getSuggestionsUseCase(query);
    result.fold(
      (_) => emit(state.copyWith(suggestions: [])),
      (suggestions) => emit(state.copyWith(suggestions: suggestions)),
    );
  }
  
  void toggleTag(String tag) {
    final tags = state.selectedTags.contains(tag)
      ? state.selectedTags.where((t) => t != tag).toList()
      : [...state.selectedTags, tag];
    
    emit(state.copyWith(selectedTags: tags));
    _performSearch();
  }
  
  void setSortOrder(SortOrder order) {
    emit(state.copyWith(sortOrder: order));
    _performSearch();
  }
  
  void clearFilters() {
    emit(state.copyWith(
      selectedTags: [],
      query: '',
      sortOrder: SortOrder.titleAsc,
    ));
    _performSearch();
  }
  
  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
```

#### UI Features

**Search Bar:**
- Real-time search with 300ms debounce
- Auto-complete suggestions dropdown
- Clear button

**Filters:**
- Tag chips (multi-select)
- Sort dropdown (Title A-Z, Z-A, Composer, Recent)
- Clear filters button

**Results:**
- List/Grid adaptive layout
- Highlight search terms in results
- Empty state with suggestions
- Loading skeleton

#### Drift FTS5 Setup

```dart
@DriftDatabase(tables: [SheetMusic, SheetMusicFts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create FTS5 triggers for auto-sync
      await customStatement('''
        CREATE TRIGGER sheet_music_fts_insert AFTER INSERT ON sheet_music
        BEGIN
          INSERT INTO sheet_music_fts(rowid, title, composer, notes)
          VALUES (new.id, new.title, new.composer, new.notes);
        END;
      ''');
      
      await customStatement('''
        CREATE TRIGGER sheet_music_fts_update AFTER UPDATE ON sheet_music
        BEGIN
          UPDATE sheet_music_fts
          SET title = new.title, composer = new.composer, notes = new.notes
          WHERE rowid = new.id;
        END;
      ''');
      
      await customStatement('''
        CREATE TRIGGER sheet_music_fts_delete AFTER DELETE ON sheet_music
        BEGIN
          DELETE FROM sheet_music_fts WHERE rowid = old.id;
        END;
      ''');
    },
  );
}

// FTS5 virtual table
@TableIndex(name: 'sheet_music_fts', columns: {#title, #composer, #notes})
class SheetMusicFts extends Table {
  IntColumn get rowid => integer()();
  TextColumn get title => text()();
  TextColumn get composer => text()();
  TextColumn get notes => text()();
  
  @override
  String get tableName => 'sheet_music_fts';
  
  @override
  bool get withoutRowId => true;
  
  @override
  List<String> get customConstraints => [
    'USING fts5(title, composer, notes, content=sheet_music, content_rowid=id)'
  ];
}
```

### 9.3 Backup Module

#### Purpose
Export and import sheet music database with images for backup, migration, and sharing.

#### Architecture

```
features/backup/
├── data/
│   ├── datasources/
│   │   ├── file_system_data_source.dart   # File I/O operations
│   │   └── compression_data_source.dart   # ZIP compression
│   └── repositories/
│       └── backup_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── backup_metadata.dart           # Backup info
│   │   └── export_format.dart             # JSON/DB/ZIP
│   ├── repositories/
│   │   └── backup_repository.dart
│   └── usecases/
│       ├── export_to_json_use_case.dart
│       ├── export_database_use_case.dart
│       ├── export_with_images_use_case.dart
│       ├── import_from_json_use_case.dart
│       └── import_from_backup_use_case.dart
└── presentation/
    ├── cubit/
    │   ├── backup_cubit.dart
    │   └── backup_state.dart
    ├── pages/
    │   └── backup_settings_page.dart
    └── widgets/
        ├── export_options_widget.dart
        └── import_picker_widget.dart
```

#### Use Cases

**ExportToJSONUseCase**
```dart
class ExportToJSONUseCase {
  final BackupRepository _repository;
  final SheetMusicRepository _sheetMusicRepository;
  
  Future<Either<Failure, File>> call({
    bool includeImages = false,
    String? customPath,
  }) async {
    // Get all sheet music
    final sheetsResult = await _sheetMusicRepository.getAll();
    
    return sheetsResult.fold(
      (failure) => Left(failure),
      (sheets) async {
        // Convert to JSON
        final jsonData = {
          'version': '1.0',
          'exported_at': DateTime.now().toIso8601String(),
          'total_sheets': sheets.length,
          'sheets': sheets.map((s) => s.toJson()).toList(),
        };
        
        // Save to file
        return await _repository.exportToJSON(
          data: jsonData,
          includeImages: includeImages,
          customPath: customPath,
        );
      },
    );
  }
}
```

**ExportWithImagesUseCase**
```dart
class ExportWithImagesUseCase {
  final BackupRepository _repository;
  final SheetMusicRepository _sheetMusicRepository;
  final ImageStorageRepository _imageStorage;
  
  Future<Either<Failure, File>> call({String? customPath}) async {
    // Get all sheets
    final sheetsResult = await _sheetMusicRepository.getAll();
    
    return sheetsResult.fold(
      (failure) => Left(failure),
      (sheets) async {
        // Create temporary directory for export
        final tempDir = await _repository.createTempExportDirectory();
        
        // Copy database
        await _repository.copyDatabaseTo(tempDir);
        
        // Copy all images
        final imagesDir = Directory('${tempDir.path}/images');
        await imagesDir.create();
        
        for (final sheet in sheets) {
          if (sheet.coverImagePath != null) {
            final imageFile = File(sheet.coverImagePath!);
            if (await imageFile.exists()) {
              final fileName = path.basename(sheet.coverImagePath!);
              await imageFile.copy('${imagesDir.path}/$fileName');
            }
          }
        }
        
        // Create metadata
        final metadata = BackupMetadata(
          version: '1.0',
          exportedAt: DateTime.now(),
          totalSheets: sheets.length,
          includesImages: true,
          appVersion: '1.0.0', // From package_info
        );
        
        await File('${tempDir.path}/metadata.json')
          .writeAsString(jsonEncode(metadata.toJson()));
        
        // ZIP everything
        final zipFile = await _repository.compressDirectory(
          tempDir,
          customPath: customPath,
        );
        
        // Cleanup temp directory
        await tempDir.delete(recursive: true);
        
        return Right(zipFile);
      },
    );
  }
}
```

**ImportFromBackupUseCase**
```dart
class ImportFromBackupUseCase {
  final BackupRepository _repository;
  final SheetMusicRepository _sheetMusicRepository;
  final ImageStorageRepository _imageStorage;
  
  Future<Either<Failure, ImportResult>> call({
    required File backupFile,
    ImportMode mode = ImportMode.merge,
  }) async {
    try {
      // Determine file type
      final extension = path.extension(backupFile.path);
      
      if (extension == '.json') {
        return await _importFromJSON(backupFile, mode);
      } else if (extension == '.zip') {
        return await _importFromZIP(backupFile, mode);
      } else if (extension == '.db' || extension == '.sqlite') {
        return await _importFromDatabase(backupFile, mode);
      } else {
        return Left(ValidationFailure('Unsupported file format'));
      }
    } catch (e) {
      return Left(ImportFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, ImportResult>> _importFromJSON(
    File jsonFile,
    ImportMode mode,
  ) async {
    final jsonString = await jsonFile.readAsString();
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    
    // Validate version
    final version = jsonData['version'] as String?;
    if (version == null || version != '1.0') {
      return Left(ValidationFailure('Incompatible backup version'));
    }
    
    // Parse sheets
    final sheets = (jsonData['sheets'] as List)
      .map((json) => SheetMusic.fromJson(json))
      .toList();
    
    // Import based on mode
    int imported = 0;
    int skipped = 0;
    
    for (final sheet in sheets) {
      if (mode == ImportMode.merge) {
        // Check for duplicates
        final existing = await _sheetMusicRepository.findByTitleAndComposer(
          sheet.title,
          sheet.composer,
        );
        
        if (existing != null) {
          skipped++;
          continue;
        }
      }
      
      await _sheetMusicRepository.add(sheet);
      imported++;
    }
    
    return Right(ImportResult(
      totalProcessed: sheets.length,
      imported: imported,
      skipped: skipped,
      failed: 0,
    ));
  }
  
  Future<Either<Failure, ImportResult>> _importFromZIP(
    File zipFile,
    ImportMode mode,
  ) async {
    // Extract to temp directory
    final tempDir = await _repository.extractZIP(zipFile);
    
    // Read metadata
    final metadataFile = File('${tempDir.path}/metadata.json');
    final metadata = BackupMetadata.fromJson(
      jsonDecode(await metadataFile.readAsString()),
    );
    
    // Import database
    final dbFile = File('${tempDir.path}/database.db');
    final dbResult = await _importFromDatabase(dbFile, mode);
    
    return dbResult.fold(
      (failure) => Left(failure),
      (result) async {
        // Import images if present
        final imagesDir = Directory('${tempDir.path}/images');
        if (await imagesDir.exists()) {
          final imageFiles = await imagesDir.list().toList();
          for (final file in imageFiles) {
            if (file is File) {
              await _imageStorage.importImage(file);
            }
          }
        }
        
        // Cleanup
        await tempDir.delete(recursive: true);
        
        return Right(result);
      },
    );
  }
  
  Future<Either<Failure, ImportResult>> _importFromDatabase(
    File dbFile,
    ImportMode mode,
  ) async {
    if (mode == ImportMode.replace) {
      // Replace current database
      await _repository.replaceDatabase(dbFile);
      return Right(ImportResult(
        totalProcessed: -1, // Unknown without querying
        imported: -1,
        skipped: 0,
        failed: 0,
      ));
    } else {
      // Merge: read from backup DB and insert into current
      final backupDb = await _repository.openDatabase(dbFile.path);
      final sheets = await backupDb.select(backupDb.sheetMusic).get();
      
      int imported = 0;
      int skipped = 0;
      
      for (final sheet in sheets) {
        final existing = await _sheetMusicRepository.findByTitleAndComposer(
          sheet.title,
          sheet.composer,
        );
        
        if (existing != null) {
          skipped++;
          continue;
        }
        
        await _sheetMusicRepository.add(sheet.toEntity());
        imported++;
      }
      
      await backupDb.close();
      
      return Right(ImportResult(
        totalProcessed: sheets.length,
        imported: imported,
        skipped: skipped,
        failed: 0,
      ));
    }
  }
}
```

#### States

```dart
@freezed
class BackupState with _$BackupState {
  const factory BackupState.idle() = _Idle;
  
  const factory BackupState.exporting({
    required double progress,
    required String currentOperation,
  }) = _Exporting;
  
  const factory BackupState.exported({
    required File file,
    required String format,
  }) = _Exported;
  
  const factory BackupState.importing({
    required double progress,
    required String currentOperation,
  }) = _Importing;
  
  const factory BackupState.imported({
    required ImportResult result,
  }) = _Imported;
  
  const factory BackupState.error(String message) = _Error;
}
```

#### Cubit Implementation

```dart
class BackupCubit extends Cubit<BackupState> {
  BackupCubit(
    this._exportToJSON,
    this._exportWithImages,
    this._importFromBackup,
  ) : super(const BackupState.idle());
  
  final ExportToJSONUseCase _exportToJSON;
  final ExportWithImagesUseCase _exportWithImages;
  final ImportFromBackupUseCase _importFromBackup;
  
  Future<void> exportJSON({bool includeImages = false}) async {
    emit(const BackupState.exporting(
      progress: 0.0,
      currentOperation: 'Preparing export...',
    ));
    
    final result = await _exportToJSON(includeImages: includeImages);
    
    result.fold(
      (failure) => emit(BackupState.error(failure.message)),
      (file) => emit(BackupState.exported(
        file: file,
        format: 'JSON',
      )),
    );
  }
  
  Future<void> exportComplete({String? customPath}) async {
    emit(const BackupState.exporting(
      progress: 0.0,
      currentOperation: 'Preparing complete backup...',
    ));
    
    final result = await _exportWithImages(customPath: customPath);
    
    result.fold(
      (failure) => emit(BackupState.error(failure.message)),
      (file) => emit(BackupState.exported(
        file: file,
        format: 'ZIP',
      )),
    );
  }
  
  Future<void> importBackup({
    required File file,
    ImportMode mode = ImportMode.merge,
  }) async {
    emit(const BackupState.importing(
      progress: 0.0,
      currentOperation: 'Reading backup file...',
    ));
    
    final result = await _importFromBackup(
      backupFile: file,
      mode: mode,
    );
    
    result.fold(
      (failure) => emit(BackupState.error(failure.message)),
      (importResult) => emit(BackupState.imported(result: importResult)),
    );
  }
  
  void reset() {
    emit(const BackupState.idle());
  }
}
```

#### Export Formats

1. **JSON Only** (`.json`)
   - Lightweight, human-readable
   - Metadata only, no images
   - Good for quick backups

2. **JSON + Images** (`.json` + image files)
   - JSON with image references
   - Images in separate directory
   - Good for selective restore

3. **Complete Backup** (`.zip`)
   - Database file + all images + metadata
   - Full restore capability
   - Recommended for migration

4. **Database Only** (`.db` / `.sqlite`)
   - Raw SQLite database
   - For advanced users
   - Fast restore but no metadata

#### Import Modes

```dart
enum ImportMode {
  merge,    // Skip duplicates, keep existing
  replace,  // Delete all, import from backup
  update,   // Update existing, add new (future)
}
```

#### UI Features

**Export Page:**
- Format selection (JSON, ZIP, Database)
- Include images checkbox
- Custom save location picker
- Progress indicator
- Share exported file (mobile)

**Import Page:**
- File picker
- Import mode selection (Merge/Replace)
- Preview backup metadata before import
- Confirmation dialog
- Progress indicator
- Import summary

#### Dependencies

- `path_provider: ^2.1.0` - File paths
- `path: ^1.8.3` - Path manipulation
- `archive: ^3.4.0` - ZIP compression
- `file_picker: ^6.0.0` - Import file selection
- `share_plus: ^7.0.0` - Share export (mobile)

#### Error Handling

- **Export failures**: Disk space, permissions
- **Import failures**: Corrupt files, version mismatch
- **Validation**: File format, schema compatibility
- **Rollback**: Transaction support for failed imports

## 10. UI Plan & Design Reference

> **📱 Complete Screen Specifications:** See [SCREENS.md](./SCREENS.md) for detailed wireframes, components, and user flows for all 14 screens.

### 10.1 Screen Inventory

The app consists of **14 primary screens** organized into three priority tiers:

**Priority 0 (MVP - Phase 1):**
1. **Home/Dashboard** - Entry point with stats, recent activity, and quick actions
2. **Scan Camera View** (Mobile) - Camera viewfinder with OCR processing
3. **OCR Review/Edit** - Review and correct OCR-detected metadata before saving
4. **Browse/Inventory List** - View all sheets with search and filtering
5. **Sheet Detail View** - Full metadata display with actions (edit, delete, share)
6. **Settings** - App configuration and preferences
7. **Empty States** - Contextual guidance when no data exists

**Priority 1 (Enhanced Features - Phase 2):**
8. **Edit Existing Sheet** - Modify metadata of saved sheets
9. **Advanced Search/Filter** - Complex multi-criteria search builder
10. **Backup/Export** - Data export (JSON/ZIP) and import functionality

**Priority 2 (Desktop & Polish - Phase 3):**
11. **Bulk Operations Mode** (Desktop) - Multi-select with batch actions
12. **Tag Management** - View, rename, merge, and delete tags
13. **Onboarding Flow** - 4-screen first-run experience with permissions

**Priority 3 (Future Enhancements):**
14. **Statistics/Insights** - Library analytics and visualizations

### 10.2 Navigation Architecture

**Mobile (< 600px):**
- Bottom navigation bar with 4 tabs: Home, Scan, Browse, Settings
- Full-screen modals for detail views and forms
- Bottom sheets for action menus

**Tablet (600-900px):**
- Bottom navigation or top tabs
- Hybrid modal approach (80% height bottom sheets)
- 2-column layouts where appropriate

**Desktop (> 900px):**
- Left sidebar navigation with collapsible sections
- Multi-column layouts (content + sidebar)
- Centered modals (max 600px width)
- Context menus and keyboard shortcuts

### 10.3 Key User Flows

**1. Add New Sheet (Mobile):**
```
Home → [Add] → Camera → Capture → OCR Processing →
Review/Edit → Save → Sheet Detail → Browse
```

**2. Add New Sheet (Desktop):**
```
Browse → [+] → File Picker → OCR Processing →
Review/Edit → Save → Browse (updated)
```

**3. Search & Filter:**
```
Browse → Search Bar → Type query → Results update (live) →
Tap sheet → Detail View
```

**4. Export Backup:**
```
Settings → Backup & Export → Choose format →
[Export] → Choose location → Progress → Success
```

See [SCREENS.md](./SCREENS.md) for complete flow diagrams and wireframes.

### 10.4 Example App (React Prototype)

A **React prototype** is available in `example_app/` that demonstrates:
- Responsive landing page layout (mobile and desktop)
- Color scheme and theming (light/dark mode)
- UI component styling
- Adaptive navigation patterns

**Purpose:**
- Visual reference for Flutter implementation
- Color palette and design system
- Layout patterns for responsive design

**Screenshots:**

The `screenshots/` folder contains visual references of the landing page:
- `example_app_mobile.png` - Mobile layout and navigation
- `example_app_desktop.png` - Desktop layout with sidebar

These screenshots show the complete design implementation including:
- Color scheme in action (light/dark mode)
- Component styling and spacing
- Typography hierarchy
- Responsive breakpoints
- Navigation patterns

**Running the Example App:**

```bash
# Navigate to example app
cd example_app

# Install dependencies
npm install

# Start development server
npm run dev

# App will open at http://localhost:5173
```

**Technology Stack:**
- React 18 + Vite
- Tailwind CSS for styling
- Radix UI components (shadcn/ui)
- Lucide React icons

**Color Scheme (from `src/styles/globals.css`):**

Light Mode:
- **Primary**: `oklch(0.42 0.15 25)` - Rich brown/sepia tone
- **Secondary**: `oklch(0.85 0.05 80)` - Soft yellow
- **Accent**: `oklch(0.68 0.14 65)` - Warm orange
- **Background**: `oklch(0.97 0.015 40)` - Warm off-white
- **Card**: `oklch(0.93 0.025 35)` - Light warm gray

Dark Mode:
- **Background**: `oklch(0.20 0.025 20)` - Deep warm black
- **Card**: `oklch(0.25 0.03 22)` - Dark warm gray
- **Foreground**: `oklch(0.95 0.015 40)` - Warm white

**Design System Notes:**
- Uses OKLCH color space for perceptually uniform colors
- Border radius: `0.625rem` (10px)
- Font sizes: Base 16px
- Emphasis on warm, paper-like tones (music sheet aesthetic)

**Flutter Translation:**
- Convert OKLCH colors to Flutter's `Color` class
- Map Radix UI components to Flutter Material/Cupertino equivalents
- Adapt responsive breakpoints to Flutter's `LayoutBuilder`

### 10.5 Component Library

**17 Reusable Components** (see [SCREENS.md](./SCREENS.md) for full specs):

**Core Components:**
- SheetCard (List/Grid/Compact variants)
- SearchBar (with debounce and filters)
- TagChip (Filled/Outlined/Removable)
- OCRConfidenceBadge (High/Medium/Low)
- ActionButton (Primary/Secondary/Destructive)
- EmptyState (contextual guidance)
- SkeletonLoader (Card/List/Grid)
- ProgressIndicator (Circular/Linear/Upload)

**Form Components:**
- FormField (Text/Multiline/Dropdown)
- TagInput (autocomplete + chips)
- ImagePicker (Camera/Gallery/Drag-drop)

**Navigation Components:**
- BottomNavBar (Mobile)
- Sidebar (Desktop)
- Breadcrumbs (Desktop)

**Feedback Components:**
- Toast/Snackbar (Success/Error/Info/Warning)
- ConfirmDialog (with destructive variants)
- LoadingOverlay (full-screen spinner)

### 10.6 Adaptive Layout Guidelines

**Breakpoints:**
```
Mobile:   < 600px  (phone portrait)
Tablet:   600-900px (tablet, phone landscape)
Desktop:  > 900px  (laptop, desktop)
```

**Layout Patterns:**

| Element | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Navigation | Bottom bar | Bottom/Top tabs | Sidebar |
| Content | Single column | 2 columns | Multi-column |
| Modals | Full-screen | Bottom sheet (80%) | Centered modal |
| Images | Full width / 80x80px | 120x180px | 200x280px / 400x600px |
| Grid Columns | 1 column | 2-3 columns | 4-6 columns |

**Responsive Behavior:**
- Search filters: Full-screen modal (mobile) → Bottom sheet (tablet) → Inline sidebar (desktop)
- Detail view: Full-screen page (mobile) → Modal (tablet/desktop)
- Bulk operations: Swipe actions (mobile) → Checkboxes + toolbar (desktop)

### 10.7 Platform-Specific Patterns

**iOS:**
- Bottom sheets for actions
- Swipe-back navigation
- Cupertino widgets
- Haptic feedback

**Android:**
- Material Design 3 components
- FAB for primary actions
- Material ripple effects
- Navigation drawer on tablet

**Desktop:**
- Right-click context menus
- Keyboard shortcuts (Cmd/Ctrl+S, etc.)
- Resizable windows
- Menu bars (macOS)

## 11. Milestones

### Phase 1: Foundations
- Core entities + Drift database setup
- Basic dependency injection
- File storage with path_provider

### Phase 2: Mobile OCR
- ML Kit integration
- OCRScanCubit for scanning flow
- Camera → OCR → parse → edit workflow
- Image storage

### Phase 3: Desktop Workflow
- File picker / drag-drop upload
- Desktop-specific UI layouts
- Optional Tesseract integration

### Phase 4: Search & Filtering
- SearchCubit with FTS5 integration
- Tag filtering
- Debounced search input
- Advanced sorting

### Phase 5: Backup & Polish
- Export/import functionality
- Bulk operations (desktop)
- UI refinement & testing

## 12. Stretch Goals

-   Cloud sync, PDF viewer, metadata APIs

## 13. Testing Strategy

### Unit Tests
- Domain layer: Use cases with mocked repositories
- Data layer: Repository implementations with mocked data sources
- Pure Dart - no Flutter dependencies

### Widget Tests
- Cubit state transitions
- UI components in isolation
- Form validation

### Integration Tests
- End-to-end flows (scan → save → search)
- Database operations
- OCR pipeline

### Golden Tests
- Visual regression testing
- Adaptive UI layouts (mobile vs desktop)

## 14. Deployment

-   Platform-specific packaging
