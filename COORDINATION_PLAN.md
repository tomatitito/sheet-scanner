# 🎼 Sheet Scanner - Coordination & Work Division Plan

**Prepared by:** PurpleHill (Coordinating Agent)  
**Date:** 2025-12-06  
**Status:** Ready for team assignment

---

## Executive Summary

The **Sheet Scanner** project consists of 5 phases with 35 detailed implementation tasks. This document outlines:
1. **Work division strategy** - How to split work across agents
2. **Dependency analysis** - Critical path and blocking tasks
3. **Code review process** - Quality gates and consistency checks
4. **Integration points** - How features interact
5. **Agent role assignments** - Who owns what

---

## Phase Overview

```
Phase 1: Foundations (CRITICAL PATH)
├─ Core entities
├─ Database & Drift setup
├─ DI with get_it
└─ File storage foundation
    ↓ (blocks all other phases)
Phase 2: Mobile OCR
├─ ML Kit integration
├─ Camera UI
├─ OCR processing
└─ Review/edit screen
    ↓ (parallel with desktop)
Phase 3: Desktop Workflow
├─ File picker
├─ Drag-drop
├─ Desktop layouts
└─ Optional Tesseract
    ↓ (parallel with Phase 4)
Phase 4: Search & Filtering
├─ FTS5 integration
├─ Tag management
├─ SearchCubit
└─ Advanced filters
    ↓
Phase 5: Backup & Polish
├─ Export (JSON/ZIP/DB)
├─ Import (merge/replace)
├─ Bulk operations
└─ UI polish
```

---

## Dependency Analysis

### Critical Path (Blocking Dependencies)

**Must Complete First:**
1. **Phase 1: Foundations** - Everything depends on this
   - `sheet-scanner-dtj` - Project structure & Clean Architecture setup
   - `sheet-scanner-us8` - Domain entities (SheetMusic, Tag, Composer)
   - `sheet-scanner-9uw` - Drift database with FTS5
   - `sheet-scanner-24w` - get_it dependency injection
   - `sheet-scanner-t42` - Repository pattern interfaces
   - `sheet-scanner-2yi` - Image storage with path_provider
   - `sheet-scanner-hpe` - App shell & navigation skeleton

**Phase 1 Unblocks:**
- Phase 2: Mobile OCR features (can start after entities + DI)
- Phase 3: Desktop workflow (can start after DI)
- Phase 4: Search (can start after database)
- Phase 5: Backup (can start after database)

### Parallelizable Work

**After Phase 1, can work in parallel:**
- Phase 2 (Mobile OCR) - Independent from Phase 3
- Phase 3 (Desktop) - Independent from Phase 2
- Phase 4 (Search) - Can start with Phase 2/3
- Phase 5 (Backup) - Finalization phase

---

## Detailed Task Breakdown

### Phase 1: Foundations (7 tasks) - **MUST DO FIRST**

| Task | ID | Details | Est. Time | Owner |
|------|-----|---------|-----------|-------|
| 1 | `dtj` | Project structure + Clean Architecture | 2-3h | Core/Lead |
| 2 | `us8` | Domain entities (SheetMusic, Tag, Composer) | 1-2h | Core |
| 3 | `9uw` | Drift database + FTS5 tables | 3-4h | Core |
| 4 | `24w` | get_it DI setup + service location | 1-2h | Core |
| 5 | `t42` | Repository interfaces | 1-2h | Core |
| 6 | `2yi` | Image storage system | 1-2h | Core |
| 7 | `hpe` | App shell + navigation skeleton | 2-3h | Frontend |

**Estimated Total:** 11-18 hours  
**Critical:** All must be completed before Phase 2-5

---

### Phase 2: Mobile OCR (6 tasks) - **Can start after Phase 1 + DI**

| Task | ID | Details | Depends On | Est. Time |
|------|-----|---------|------------|-----------|
| 1 | `9xw` | ML Kit integration | Phase 1 | 2-3h |
| 2 | `ri1` | Camera capture UI & viewfinder | Phase 1 | 2-3h |
| 3 | `bsb` | OCRScanCubit state management | Phase 1 + `9xw` | 2-3h |
| 4 | `qaq` | OCR review/edit screen | Phase 1 + `bsb` | 3-4h |

**Estimated Total:** 9-13 hours

---

### Phase 3: Desktop Workflow (3 tasks) - **Parallel with Phase 2**

| Task | ID | Details | Depends On | Est. Time |
|------|-----|---------|------------|-----------|
| 1 | `3je` | File picker + drag-drop | Phase 1 | 2-3h |
| 2 | `fc3` | Desktop-specific layouts & nav | Phase 1 + `hpe` | 2-3h |

**Estimated Total:** 4-6 hours

---

### Phase 4: Search & Filtering (5 tasks) - **Can start after Phase 1**

| Task | ID | Details | Depends On | Est. Time |
|------|-----|---------|------------|-----------|
| 1 | `eg7` | FTS5 integration in Drift | Phase 1 | 2-3h |
| 2 | `3ct` | Tag management system | Phase 1 | 2-3h |
| 3 | `2tm` | SearchCubit state | Phase 1 + `eg7` | 2-3h |
| 4 | `my0` | Browse/inventory list (MVP) | Phase 1 + `2tm` | 3-4h |
| 5 | `0fi` | Search/browse UI with filters | Phase 1 + `2tm` | 3-4h |
| 6 | `1qd` | Advanced search/filter modal | Phase 1 + `0fi` | 2-3h |

**Estimated Total:** 14-20 hours

---

### Phase 5: Backup & Polish (9 tasks) - **Can start after Phase 1**

| Task | ID | Details | Depends On | Est. Time |
|------|-----|---------|------------|-----------|
| 1 | `8py` | Export functionality (JSON/ZIP/DB) | Phase 1 | 3-4h |
| 2 | `dty` | Import functionality (merge/replace) | Phase 1 + `8py` | 2-3h |
| 3 | `6o2` | Backup/export UI screen | Phase 1 + `8py` | 2-3h |
| 4 | `pp1` | Bulk operations (desktop) | Phase 1 + `hpe` | 2-3h |
| 5 | `3nc` | Settings/configuration screen | Phase 1 | 2-3h |
| 6 | `c19` | Home/dashboard (MVP) | Phase 1 | 2-3h |
| 7 | `pcl` | Sheet detail view modal | Phase 1 | 2-3h |
| 8 | `7rz` | Edit existing sheet | Phase 1 + `pcl` | 2-3h |

**Estimated Total:** 17-24 hours

---

### Phase-Level Epics (5 tasks)

These are umbrella tasks for each phase:
- `sheet-scanner-l3k` - Phase 1: Foundations
- `sheet-scanner-d6f` - Phase 2: Mobile OCR
- `sheet-scanner-62k` - Phase 3: Desktop Workflow
- `sheet-scanner-6ir` - Phase 4: Search & Filtering
- `sheet-scanner-tfj` - Phase 5: Backup & Polish

These track completion and serve as rollup points.

---

## Recommended Agent Specializations

Based on typical Amp agent roles, recommend:

### 1. **Core/Lead Agent** (Architecture & Foundations)
- **Responsibilities:**
  - Phase 1 complete setup (all 7 tasks)
  - Architecture oversight & consistency
  - Database & DI infrastructure
  - Code review for architectural compliance
  - Mentoring other agents on design patterns

- **Tasks Owned:**
  - `dtj` - Project structure
  - `us8` - Domain entities
  - `9uw` - Drift database
  - `24w` - get_it DI
  - `t42` - Repository interfaces
  - `2yi` - Image storage
  - `hpe` - App shell

### 2. **Mobile/OCR Agent** (Phase 2)
- **Responsibilities:**
  - Mobile OCR feature development
  - ML Kit integration & optimization
  - Camera & image handling
  - Mobile-specific UI polish

- **Tasks Owned:**
  - `9xw` - ML Kit integration
  - `ri1` - Camera UI
  - `bsb` - OCRScanCubit
  - `qaq` - OCR review/edit

### 3. **Desktop/Frontend Agent** (Phase 3, UI)
- **Responsibilities:**
  - Desktop workflow implementation
  - Responsive layout handling
  - File picker & drag-drop
  - UI/UX polish across all screens

- **Tasks Owned:**
  - `3je` - File picker & drag-drop
  - `fc3` - Desktop layouts
  - `c19` - Home/dashboard
  - `my0` - Browse/inventory list
  - `0fi` - Search UI
  - `pcl` - Sheet detail modal
  - `3nc` - Settings screen

### 4. **Search/Data Agent** (Phase 4)
- **Responsibilities:**
  - FTS5 search implementation
  - Tag management system
  - Search/filter logic
  - Data querying & optimization

- **Tasks Owned:**
  - `eg7` - FTS5 integration
  - `3ct` - Tag management
  - `2tm` - SearchCubit
  - `1qd` - Advanced filters

### 5. **Backup/Polish Agent** (Phase 5)
- **Responsibilities:**
  - Export/import functionality
  - Bulk operations
  - Data integrity & validation
  - Final integration testing

- **Tasks Owned:**
  - `8py` - Export functionality
  - `dty` - Import functionality
  - `6o2` - Backup UI
  - `pp1` - Bulk operations
  - `7rz` - Edit existing sheet

---

## Code Review Process

### Quality Gates

**Before merging any PR:**

1. **Lint & Format**
   ```bash
   fvm dart analyze lib/
   fvm dart format lib/
   ```
   Must pass with no errors (warnings acceptable)

2. **Tests**
   ```bash
   fvm flutter test
   ```
   All tests must pass. Minimum 70% coverage for new code.

3. **Build**
   ```bash
   fvm flutter build apk --debug
   fvm flutter build ios --debug (on macOS)
   fvm flutter build web --debug
   ```
   Must build successfully on all target platforms

4. **Architecture Check**
   - No feature depends on another feature's data/presentation layer
   - No core layer depends on features
   - Domain layers are pure Dart (no framework code)
   - All imports follow the dependency rule

### Review Checklist

- [ ] Task in beads is `in_progress`
- [ ] Code follows FLUTTER_DART_BEST_PRACTICES.md
- [ ] Clean Architecture layers properly separated
- [ ] No code duplication
- [ ] Documentation comments added for public APIs
- [ ] Tests updated or added
- [ ] No console errors or warnings

### Code Review Roles

1. **Architectural Reviews** - Core/Lead agent
   - Verifies Clean Architecture compliance
   - Checks dependency injection setup
   - Reviews new modules/features

2. **Feature Reviews** - Respective domain experts
   - Mobile code → Mobile/OCR agent
   - Desktop/UI → Desktop/Frontend agent
   - Search/data → Search/Data agent
   - Export/backup → Backup/Polish agent

3. **Integration Reviews** - Core/Lead agent
   - Cross-feature interactions
   - Shared utilities & core layers
   - Final before merge to main

---

## Git & Beads Workflow

### Commit Convention

```
[bd-XXX] Brief description

Longer explanation if needed.

- Implements feature X
- Fixes issue Y
- Updates Z

Related: bd-ABC, bd-DEF
```

Where `bd-XXX` is the beads issue ID.

### Beads Status Lifecycle

```
New → in_progress → (review) → ready_to_close → closed

- Start task: bd update bd-XXX --status in_progress
- Ready for review: bd update bd-XXX --status ready_to_close
- Done: bd close bd-XXX --reason "Completed" or "Merged"
```

### File Reservations

When starting a task, reserve affected files:

```bash
bd file_reservation_paths . ["lib/features/ocr/**"] --exclusive --ttl 3600 --reason "bd-XXX: OCR integration"
```

Release when done:
```bash
bd release_file_reservations ["lib/features/ocr/**"]
```

---

## Integration Points

### Feature → Core Interactions

All features depend on these core utilities:
- `core/error/failures.dart` - Error handling
- `core/utils/either.dart` - Result type
- `core/di/injection.dart` - Dependency injection
- `core/platform/platform_detector.dart` - Platform checks

### Feature → Feature Interactions

Allowed dependencies:
- Search/Filtering uses SheetMusic entity from sheet_music domain
- Backup uses SheetMusic & Tag entities
- Mobile OCR returns SheetMusic entity for storage

**NOT allowed:**
- Feature A data layer depending on Feature B data
- Feature A presentation depending on Feature B presentation
- Circular dependencies

### Data Layer Coordination

All repositories registered in `core/di/injection.dart`:
```dart
getIt.registerSingleton<SheetMusicRepository>(
  SheetMusicRepositoryImpl(
    localDataSource: getIt<SheetMusicLocalDataSource>(),
  ),
);
```

---

## Communication & Coordination

### Synchronous
- Use Agent Mail for coordination messages
- Prefix subjects with `[bd-XXX]` for issue linking
- Use `thread_id` parameter to keep discussions grouped

### Asynchronous
- Check beads daily for task status
- Use `bd sync` to flush changes immediately
- Leave commit messages with context

### Issue Updates
- Update beads status as work progresses
- Leave comments in commits linking to related issues
- File new issues for blockers or scope changes

---

## Success Criteria

### Phase 1 (Foundations) - COMPLETE FIRST
- ✅ All 7 tasks merged
- ✅ Tests passing
- ✅ No lint errors
- ✅ Builds successfully

### Phase 2 (Mobile OCR)
- ✅ Camera UI works on Android & iOS
- ✅ ML Kit integration complete
- ✅ OCR processing functional
- ✅ UI tests passing

### Phase 3 (Desktop)
- ✅ File picker working on all platforms
- ✅ Desktop layouts responsive
- ✅ Drag-drop functional

### Phase 4 (Search)
- ✅ FTS5 search performant
- ✅ Filters work correctly
- ✅ Tag management complete

### Phase 5 (Backup & Polish)
- ✅ Export/import tested
- ✅ UI polish complete
- ✅ No known bugs
- ✅ Ready for release

---

## Timeline Estimate

| Phase | Tasks | Est. Hours | Dependencies | Start |
|-------|-------|-----------|--------------|-------|
| 1 | 7 | 11-18h | None | Week 1 |
| 2 | 4 | 9-13h | Phase 1 | Week 2 |
| 3 | 2 | 4-6h | Phase 1 | Week 2 |
| 4 | 6 | 14-20h | Phase 1 | Week 2 |
| 5 | 8 | 17-24h | Phase 1 | Week 3 |

**Total:** ~55-81 hours of development

With 5 parallel agents (after Phase 1), estimated completion: **2-3 weeks**

---

## Next Steps

1. **Assign agents** to specializations
2. **Start Phase 1** with Core/Lead agent
3. **Create feature branches** for each phase
4. **Set up code review process**
5. **Daily sync** on blockers and progress
6. **Weekly retrospective** on what's working

---

*This plan is living and should be updated as the team learns.*
