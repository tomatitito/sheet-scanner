# 🚀 Quick Start - Agent Coordination Guide

**Last Updated:** 2025-12-06  
**Status:** Ready for implementation

---

## For Incoming Agents

### 1. Read These First (5 minutes)
1. **AGENTS.md** - Project rules & constraints
2. **FLUTTER_DART_BEST_PRACTICES.md** - Code quality standards
3. **This file** - Quick overview

### 2. Understand the Architecture (10 minutes)
- Read PLAN.md sections 6.1 & 6.2 (Clean Architecture & Dependency Rules)
- Key concept: **Inward dependencies only** (Presentation → Domain ← Data)

### 3. Know Your Role (2 minutes)
- See AGENT_ASSIGNMENTS.md for your specialization
- Review your owned tasks
- Understand your dependencies

### 4. Setup & First Task
```bash
# Get latest code
git pull origin main

# Check your tasks
bd ready --json
bd show <your-task-id> --json

# Start working
bd update <task-id> --status in_progress
git checkout -b feat/<task-id>

# As you code, remember:
# - fvm flutter test        (run tests)
# - fvm dart analyze lib/   (lint check)
# - fvm dart format lib/    (auto-format)
```

---

## Agent Specializations at a Glance

### 🏗️ Core/Lead Agent
- **Phase:** 1 (Foundations) - **START FIRST**
- **Tasks:** Project structure, database, DI, entities, repositories, image storage, app shell
- **Duration:** Weeks 1-2 (11-18 hours)
- **Blocks:** All other phases
- **Validates:** Architecture, code reviews

### 📱 Mobile/OCR Agent
- **Phase:** 2 (Mobile OCR)
- **Tasks:** ML Kit, camera UI, OCR processing, review screen
- **Duration:** Week 2 (9-13 hours)
- **Depends On:** Phase 1 complete
- **Parallel With:** Phase 3

### 🖥️ Desktop/Frontend Agent
- **Phase:** 3 (Desktop Workflow) + All UI screens
- **Tasks:** File picker, desktop layouts, home, browse, search UI, detail view, settings
- **Duration:** Weeks 2-4
- **Depends On:** Phase 1 complete
- **Parallel With:** Phase 2

### 🔍 Search/Data Agent
- **Phase:** 4 (Search & Filtering)
- **Tasks:** FTS5, tag management, SearchCubit, advanced filters
- **Duration:** Week 2-3 (14-20 hours)
- **Depends On:** Phase 1 complete
- **Parallel With:** Phase 2 & 3

### 💾 Backup/Polish Agent
- **Phase:** 5 (Backup & Polish)
- **Tasks:** Export, import, backup UI, bulk operations, edit sheet, finalization
- **Duration:** Weeks 3-4 (17-24 hours)
- **Depends On:** Phase 1 complete + other phases progressing
- **Parallel With:** Phase 2-4

---

## Daily Workflow

### 1. Start of Day
```bash
# Pull latest
git pull --rebase origin main

# Check blockers
bd fetch inbox --urgent
bd list --status in_progress

# Update your status
bd update <task-id> --status in_progress --metadata notes="Working on X"
```

### 2. During Development
```bash
# Commit frequently with beads reference
git commit -m "[bd-XXX] Implement feature Y

- Completed part A
- Completed part B
- TODO: part C

Related: bd-ABC"

# Run quality gates before pushing
fvm flutter test
fvm dart analyze lib/
fvm dart format lib/

# If all green, push
git push origin feat/<task-id>
```

### 3. Ready for Review
```bash
# Create PR with template linking beads issue
git push origin feat/<task-id>
gh pr create --title "[bd-XXX] Implement X" --body "Closes bd-XXX"

# Update beads
bd update <task-id> --status ready_to_close

# Wait for review from Core/Lead agent
# Address feedback
# Merge when approved
```

### 4. Task Complete
```bash
# After merge to main
bd close <task-id> --reason "Merged to main"

# Sync beads
bd sync

# Pick next task
bd ready --json
```

---

## Architecture Quick Reference

### Three Layers (per feature)

```
PRESENTATION (UI, Cubits) → Uses → Entities + UseCases
DOMAIN (Business Logic)    ← Implements interfaces → REPOSITORIES
DATA (Impl, Database)      ← Implements interfaces → REPOSITORIES
```

### Key Files by Feature

```
features/
└── my_feature/
    ├── data/                    ← Implementation (can change)
    │   ├── datasources/         ← DB, API, local storage
    │   ├── models/              ← DTOs, JSON parsing
    │   └── repositories/        ← Repository implementations
    │
    ├── domain/                  ← Core logic (stable, no changes)
    │   ├── entities/            ← Pure Dart classes
    │   ├── repositories/        ← Abstract interfaces (abstract class)
    │   └── usecases/            ← Business operations
    │
    └── presentation/            ← UI (frequent changes)
        ├── cubit/               ← State management
        ├── pages/               ← Full-screen widgets
        └── widgets/             ← Reusable components
```

### Import Rules (CRITICAL!)

✅ **ALLOWED:**
```dart
// Feature can use core utilities
import 'package:sheet_scanner/core/error/failures.dart';

// Feature can use other features' domain
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

// Within feature: all imports ok
import '../domain/usecases/add_sheet.dart';
import '../data/repositories/sheet_music_repo_impl.dart';
```

❌ **FORBIDDEN:**
```dart
// Feature A cannot use Feature B's data/presentation
import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_cubit.dart';

// Core cannot import from features
import 'package:sheet_scanner/features/ocr/domain/entities/ocr_result.dart';

// Circular dependencies
// Feature A → B → A (BAD!)
```

---

## Dependency Injection Usage

### Adding a Service

In `core/di/injection.dart`:

```dart
void setupInjection() {
  // Register datasource
  getIt.registerSingleton<SheetMusicLocalDataSource>(
    SheetMusicLocalDataSourceImpl(database: getIt()),
  );

  // Register repository
  getIt.registerSingleton<SheetMusicRepository>(
    SheetMusicRepositoryImpl(
      localDataSource: getIt<SheetMusicLocalDataSource>(),
    ),
  );

  // Register usecase
  getIt.registerSingleton<AddSheetMusicUseCase>(
    AddSheetMusicUseCase(repository: getIt()),
  );

  // Register cubit
  getIt.registerSingleton<SheetMusicCubit>(
    SheetMusicCubit(
      addUseCase: getIt(),
      getUseCase: getIt(),
    ),
  );
}
```

### Using in Code

```dart
// In cubit or presentation
final useCase = getIt<AddSheetMusicUseCase>();
final result = await useCase(sheet);

// In data layer
class SheetMusicRepositoryImpl implements SheetMusicRepository {
  final SheetMusicLocalDataSource _localDataSource;
  
  SheetMusicRepositoryImpl({required SheetMusicLocalDataSource localDataSource})
    : _localDataSource = localDataSource;
}
```

---

## Error Handling Pattern

All failures use `Either<Failure, Success>`:

```dart
// In domain layer (use case)
Future<Either<Failure, SheetMusic>> addSheetMusic(SheetMusic sheet) async {
  try {
    final result = await _repository.add(sheet);
    return Right(result);
  } catch (e) {
    return Left(AddSheetMusicFailure(message: e.toString()));
  }
}

// In presentation layer (cubit)
Future<void> addSheet() async {
  emit(const SheetMusicState.loading());
  final result = await _addSheetUseCase(sheet);
  
  result.fold(
    (failure) => emit(SheetMusicState.error(failure.message)),
    (sheet) => emit(SheetMusicState.success(sheet)),
  );
}
```

---

## Testing Quick Wins

### Before Committing

```bash
# Run all tests
fvm flutter test

# Check specific feature
fvm flutter test test/features/my_feature/

# Check coverage
fvm flutter test --coverage
lcov --list coverage/lcov.info
```

### Minimum Test Cases per Task

| Layer | Min Tests | Example |
|-------|-----------|---------|
| Domain | UseCase + Failure handling | Test: success path, error path |
| Data | Repository + Mock DataSource | Test: parse, error, fallback |
| Presentation | Cubit state transitions | Test: load, success, error states |

---

## Common Commands Cheat Sheet

```bash
# Start new task
bd update <task-id> --status in_progress
git checkout -b feat/<task-id>

# Before committing
fvm flutter test
fvm dart analyze lib/
fvm dart format lib/

# Commit with beads reference
git commit -m "[bd-XXX] Brief description"

# Ready for review
git push origin feat/<task-id>
bd update <task-id> --status ready_to_close

# Complete task (after merge)
bd close <task-id> --reason "Merged to main"
bd sync

# Check what's ready to work on
bd ready --json

# Message team if blocked
bd send_message -t <agent> -s "Blocked on X"
```

---

## Need Help?

### Check These First
1. **PLAN.md** - Architecture details & patterns
2. **FLUTTER_DART_BEST_PRACTICES.md** - Code standards
3. **AGENT_ASSIGNMENTS.md** - Detailed task specs

### Ask For Help
- **Architectural questions** → Message Core/Lead agent
- **Cross-feature issues** → Use agent mail (cc: relevant agents)
- **Blockers** → Use `urgent` flag in messages
- **Code review feedback** → Respond to PR comments

---

## Phase Timeline

| Phase | Duration | Start | Owner | Status |
|-------|----------|-------|-------|--------|
| 1 (Foundations) | 11-18h | Week 1 | Core/Lead | Not started |
| 2 (Mobile OCR) | 9-13h | Week 2 | Mobile agent | Blocked by Phase 1 |
| 3 (Desktop) | 4-6h | Week 2 | Frontend agent | Blocked by Phase 1 |
| 4 (Search) | 14-20h | Week 2 | Search agent | Blocked by Phase 1 |
| 5 (Backup) | 17-24h | Week 3 | Backup agent | Blocked by Phase 1 |

**Total:** ~55-81 hours across all agents  
**Expected Completion:** 2-3 weeks with 5 parallel agents

---

## Remember

> **"In Clean Architecture, dependencies point inward. Presentation depends on Domain, Data implements Domain."**

> **"Use `Either<Failure, Success>` for all async operations in domain/data layers."**

> **"Keep domain layer pure - no framework code, no external dependencies."**

> **"Run tests + linter before every push. No exceptions."**

---

**Questions? Check AGENT_ASSIGNMENTS.md for your specific role.**
