# Code Review Findings - Sheet Scanner Project

**Date**: December 8, 2025  
**Reviewer**: Amp Agent  
**Project Phase**: 1 (Foundations)  
**Status**: 13 Issues Filed in Beads

---

## Executive Summary

Comprehensive review of the Sheet Scanner codebase identified **8 critical/high-priority violations** of Clean Architecture rules and **5 missing implementation areas**. The code structure is sound, but there are dependency violations and missing core layers that must be resolved before feature implementation proceeds.

**Recommendation**: Fix all P1 issues before continuing feature work (6-8 hour task).

---

## Critical Issues (P1)

### 1. Domain Layer Imports dart:io ❌ CRITICAL
**Files**: 
- `lib/features/ocr/domain/repositories/ocr_repository.dart` (line 1)
- `lib/features/backup/domain/repositories/backup_repository.dart` (line 1)

**Problem**: Domain layer must be pure Dart with NO external dependencies. Importing `dart:io` (File class) violates this rule and couples domain to platform specifics.

**Impact**: Domain becomes untestable, couples to file system, violates SOLID SRP.

**Issue**: [sheet-scanner-qts](bv://sheet-scanner-qts)

**Fix**: Move File types to data/presentation layers or use abstract types in domain.

---

### 2. Router Imports Presentation Layer ❌ CRITICAL  
**File**: `lib/core/router/app_router.dart` (line 3)

**Problem**: 
```dart
import 'package:sheet_scanner/features/sheet_music/presentation/pages/home_page.dart';
```

**Impact**: Core layer depends on features, creating a circular dependency and violating clean architecture. Core is supposed to be feature-agnostic.

**Issue**: [sheet-scanner-891](bv://sheet-scanner-891)

**Fix**: Use lazy route builders or define pages through dependency injection.

---

### 3. Incomplete Dependency Injection ❌ CRITICAL
**File**: `lib/core/di/injection.dart`

**Problem**: Only database is registered. Missing:
- Repository implementations
- Cubits for state management  
- Use cases
- Data sources

**Impact**: App will crash at runtime when cubits try to access repositories. DI system is non-functional.

**Issue**: [sheet-scanner-825](bv://sheet-scanner-825)

**Fix**: Register all implementations as features are implemented.

---

### 4. Missing Use Cases Layer ❌ CRITICAL
**Directories**: `lib/features/*/domain/usecases/` (all empty)

**Problem**: Domain layer is incomplete. Use cases are the entry point for business logic. All features lack this layer.

**Impact**: Cannot test domain logic, no clear separation between domain and presentation.

**Issues**:
- [sheet-scanner-s1r](bv://sheet-scanner-s1r) - Missing use cases

**Fix**: Implement use case classes for each domain operation.

---

### 5. Missing Repository Implementations ❌ CRITICAL
**Directories**: `lib/features/*/data/repositories/` (all empty)

**Problem**: Only abstract interfaces exist. Concrete implementations missing.

**Impact**: Features cannot function. Database, file system, and API calls have no implementations.

**Issues**:
- [sheet-scanner-49d](bv://sheet-scanner-49d) - Missing repository implementations
- [sheet-scanner-4zq](bv://sheet-scanner-4zq) - Database not abstracted

**Fix**: Implement all repository interfaces in data layer.

---

### 6. Missing Data Sources ❌ CRITICAL
**Directories**: `lib/features/*/data/datasources/` (all empty)

**Problem**: No local or remote data access implementations.

**Impact**: Repositories have nothing to call. Data layer is non-functional.

**Issue**: [sheet-scanner-6bq](bv://sheet-scanner-6bq)

**Fix**: Implement local datasources for database access.

---

## High Priority Issues (P2)

### 7. Result Classes Not Immutable
**Files**:
- `lib/features/ocr/domain/repositories/ocr_repository.dart` - `OCRResult` class (lines 6-13)
- `lib/features/backup/domain/repositories/backup_repository.dart` - `ExportResult` (lines 6-15), `ImportResult` (lines 19-30)

**Problem**: Domain entities/value objects must be immutable using `@freezed`. These are mutable Dart classes.

**Impact**: Values can be modified, violating immutability principle and causing hard-to-track bugs in state management.

**Issue**: [sheet-scanner-5dd](bv://sheet-scanner-5dd)

**Before**:
```dart
class OCRResult {
  final String text;
  final double confidence;
  
  OCRResult({required this.text, required this.confidence});
}
```

**After**:
```dart
@freezed
class OCRResult with _$OCRResult {
  const factory OCRResult({
    required String text,
    required double confidence,
  }) = _OCRResult;
}
```

---

### 8. PlatformDetector Uses Unsafe Custom kIsWeb
**File**: `lib/core/platform/platform_detector.dart` (line 34)

**Problem**: 
```dart
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
```

This is a fragile custom implementation. Flutter provides a built-in `kIsWeb` constant that should be used.

**Impact**: May not correctly detect web platform in all build configurations.

**Issue**: [sheet-scanner-82b](bv://sheet-scanner-82b)

**Fix**: Use Flutter's built-in `kIsWeb` from `foundation.dart`.

---

### 9. ImageStorage in Core Instead of Feature
**File**: `lib/core/storage/image_storage.dart`

**Problem**: Image storage is specific to sheet_music feature but placed in core. Core should only contain truly shared infrastructure (DI, error handling, platform detection).

**Impact**: Couples core to sheet_music domain concerns, reduces feature independence.

**Issue**: [sheet-scanner-2ln](bv://sheet-scanner-2ln)

**Fix**: Move to `lib/features/sheet_music/data/datasources/image_storage.dart`.

---

## Missing Implementation Areas (P2-P3)

### 10. Missing Presentation Cubits
**Issue**: [sheet-scanner-7a1](bv://sheet-scanner-7a1)

All features lack Cubit implementations for state management:
- `lib/features/sheet_music/presentation/cubits/`
- `lib/features/ocr/presentation/cubits/`
- `lib/features/search/presentation/cubits/`
- `lib/features/backup/presentation/cubits/`

---

### 11. Missing Presentation Widgets  
**Issue**: [sheet-scanner-xod](bv://sheet-scanner-xod)

No UI widgets implemented beyond placeholder HomePage. Need:
- Sheet music list widgets
- Detail views
- Forms for adding/editing
- Search UI
- Settings screens

---

### 12. Missing API Documentation
**Issue**: [sheet-scanner-vhk](bv://sheet-scanner-vhk)

Several public APIs lack dartdoc comments:
- `Validators` class methods
- `ImageStorage` public methods (partially documented)

---

## What's Working Well ✅

1. **Repository Pattern** - Interfaces correctly defined in domain
2. **Failure Handling** - Comprehensive failure types covering all error scenarios
3. **Either Type** - Functional error handling correctly implemented
4. **Entity Design** - SheetMusic, Composer, Tag entities properly use `@freezed`
5. **Directory Structure** - Features organized correctly as vertical slices
6. **Dependency Rules** - Where implemented, feature dependencies are correct (search→sheet_music domain)
7. **Code Quality** - No lint errors, proper formatting, good naming conventions

---

## Dependency Analysis

### ✅ Correct Dependencies
```
features/sheet_music/domain → core ✓
features/search/domain → core ✓
features/search/domain → features/sheet_music/domain ✓
```

### ❌ Violations Found
```
core/router → features/sheet_music/presentation ✗
features/ocr/domain → dart:io ✗
features/backup/domain → dart:io ✗
```

---

## Testing Impact

Current state cannot be tested:
- ❌ No unit tests possible (no use cases, repositories)
- ❌ No widget tests possible (no cubits, UI widgets)
- ❌ No integration tests possible (no data sources)

Must complete implementations before testing.

---

## Recommended Fix Order

**Phase 1 (Blocking, 6-8 hours)**:
1. Fix domain layer dependencies (remove dart:io imports)
2. Fix router circular dependency
3. Fix PlatformDetector kIsWeb
4. Move ImageStorage to feature

**Phase 2 (Implementation, 2-3 days)**:
5. Implement use cases for all features
6. Implement repository implementations
7. Implement data sources (database access)
8. Complete DI registration

**Phase 3 (UI, ongoing)**:
9. Implement Cubits
10. Implement Widgets
11. Add documentation

---

## Filed Beads Issues

| ID | Priority | Title | Type |
|---|---|---|---|
| sheet-scanner-qts | P1 | Domain layer dart:io imports | Bug |
| sheet-scanner-891 | P1 | Router imports presentation | Bug |
| sheet-scanner-825 | P1 | DI setup incomplete | Bug |
| sheet-scanner-s1r | P1 | Missing use cases | Task |
| sheet-scanner-49d | P1 | Missing repository implementations | Task |
| sheet-scanner-4zq | P1 | Database not abstracted | Task |
| sheet-scanner-6bq | P1 | Missing data sources | Task |
| sheet-scanner-5dd | P2 | Result classes not immutable | Bug |
| sheet-scanner-82b | P2 | PlatformDetector kIsWeb unsafe | Bug |
| sheet-scanner-2ln | P2 | ImageStorage in core | Task |
| sheet-scanner-7a1 | P2 | Missing cubits | Task |
| sheet-scanner-xod | P2 | Missing widgets | Task |
| sheet-scanner-vhk | P3 | Missing documentation | Task |

---

## Next Steps

1. Read the generated issue details in Beads
2. Fix P1 issues in dependency order
3. Run `fvm dart analyze` after each fix
4. Run `fvm dart format` before committing
5. Update this review when fixes are complete

---

**Review Complete**: All critical violations identified and filed.
