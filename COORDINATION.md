# Sheet Scanner - Agent Coordination Plan

**Coordinator**: BrownPond  
**Date**: 2025-12-06  
**Status**: Active Coordination

## Project Overview

A local-first Flutter app for cataloging sheet music with OCR scanning, search, and backup functionality.

**Tech Stack**:
- Flutter + Dart
- Clean Architecture (feature-based)
- Drift + FTS5 (SQLite database)
- BLoC/Cubit (state management)
- get_it (dependency injection)
- ML Kit (mobile OCR)

## Phase Structure & Dependencies

### Phase 1: Foundations (7 tasks) — BLOCKING OTHERS
Core infrastructure that all other phases depend on.

```
Phase 1 ──→ [Phase 2, 3, 4, 5]  ← All blocked until Phase 1 complete
```

**Tasks**:
1. `sheet-scanner-dtj` - Setup Flutter project structure with Clean Architecture
2. `sheet-scanner-us8` - Create domain entities: SheetMusic, Tag, Composer
3. `sheet-scanner-9uw` - Setup Drift database with FTS5 support
4. `sheet-scanner-t42` - Implement repository pattern interfaces
5. `sheet-scanner-24w` - Setup get_it dependency injection
6. `sheet-scanner-hpe` - Create basic app shell and navigation skeleton
7. `sheet-scanner-2yi` - Create image storage system with path_provider

**Definition of Done**: 
- Project structure matches PLAN.md architecture exactly
- All 5 phases can import from core without conflicts
- DI container is wired and tested
- Database schema is defined and tested
- App compiles and runs (empty UI acceptable)

---

### Phase 2: Mobile OCR (6 tasks) — Depends on Phase 1

```
Phase 1 ← [Phase 2]
          ├─→ Phase 3 (optional)
          ├─→ Phase 4 (optional)
          └─→ Phase 5 (optional)
```

**Tasks**:
1. `sheet-scanner-9xw` - Integrate ML Kit for text recognition
2. `sheet-scanner-ri1` - Build camera capture UI and viewfinder
3. `sheet-scanner-bsb` - Build OCRScanCubit state management
4. `sheet-scanner-qaq` - Implement OCR review/edit screen
5. (Phase 3 Desktop: File picker and drag-drop upload)
6. (Phase 3 Desktop: Build desktop-specific layouts)

**Definition of Done**:
- Camera flow works (capture → OCR → edit → save)
- ML Kit integration tested
- OCR results display with confidence scores
- Edit screen allows corrections before save

---

### Phase 3: Desktop Workflow (5 tasks) — Depends on Phase 1, Optional Phase 2

Can start in parallel with Phase 2 after Phase 1, but uses Phase 2 OCRScanCubit pattern.

**Tasks**:
1. `sheet-scanner-3je` - Implement file picker and drag-drop UI
2. `sheet-scanner-fc3` - Build desktop-specific layouts and navigation
3. `sheet-scanner-c19` - Create home/dashboard screen (MVP)
4. `sheet-scanner-my0` - Implement browse/inventory list screen (MVP)
5. `sheet-scanner-pcl` - Build sheet detail view modal

**Definition of Done**:
- Desktop UI responsive and functional
- File picker and drag-drop working
- Home screen shows stats
- Browse/inventory list with basic search

---

### Phase 4: Search & Filtering (5 tasks) — Depends on Phase 1, Phase 3

Search features depend on having data to search and a browse UI to display results.

**Tasks**:
1. `sheet-scanner-eg7` - Integrate FTS5 full-text search
2. `sheet-scanner-0fi` - Build search/browse with filtering UI
3. `sheet-scanner-3ct` - Implement tag management system
4. `sheet-scanner-2tm` - Build SearchCubit state management
5. `sheet-scanner-1qd` - Create advanced search/filter modal

**Definition of Done**:
- FTS5 queries work and are optimized
- Search bar with live results
- Tag-based filtering
- Advanced search modal
- Sorting options (date, title, composer, etc.)

---

### Phase 5: Backup & Polish (4 tasks) — Depends on Phase 1, Phase 3, Phase 4

Final polish including export/import and bulk operations.

**Tasks**:
1. `sheet-scanner-8py` - Implement export functionality (JSON/ZIP/Database)
2. `sheet-scanner-dty` - Implement import functionality with merge/replace modes
3. `sheet-scanner-6o2` - Build backup/export UI screen
4. `sheet-scanner-7rz` - Setup edit existing sheet functionality
5. `sheet-scanner-pp1` - Implement bulk operations for desktop (multi-select, batch delete)
6. `sheet-scanner-3nc` - Build settings/configuration screen

**Definition of Done**:
- Export to JSON/ZIP/Database
- Import with merge/replace modes
- Settings screen functional
- Edit sheet functionality
- Bulk operations on desktop

---

## Suggested Work Distribution

### Strategy 1: Sequential (Safe, Lower Risk)
- **Agent 1**: Phase 1 (7 tasks) → Phase 3 Desktop (5 tasks)
- **Agent 2**: Phase 2 Mobile OCR (6 tasks)
- **Agent 3**: Phase 4 Search (5 tasks)
- **Agent 4**: Phase 5 Backup (4 tasks)

### Strategy 2: Parallel (Faster, Requires Coordination)
- **Agent 1**: Phase 1 Foundation (blocking) — blocks all others
- **Agent 2**: Phase 2 Mobile OCR (can start after Phase 1 completes)
- **Agent 3**: Phase 3 Desktop (can start after Phase 1 completes)
- **Agent 4**: Phase 4 Search (starts after Phase 1 + Phase 3)

---

## Code Review Checklist

All code must pass:

1. **Linting**: `fvm dart analyze`
2. **Formatting**: `fvm dart format lib/`
3. **Build**: `fvm flutter build linux` (test compilation)
4. **Architecture**:
   - ✅ Correct layer isolation (no circular deps)
   - ✅ Domain layer has ZERO framework dependencies
   - ✅ Data/Presentation depend on Domain (interfaces)
   - ✅ File reservations used before committing
5. **Testing**:
   - Unit tests for use cases and repositories
   - Widget tests for Cubits
6. **Documentation**:
   - dartdoc comments on public APIs
   - Architecture diagrams if adding new modules

---

## Critical Rules Reminder

### 🚫 NEVER
- Delete files without explicit permission
- Run `git reset --hard` or `rm -rf`
- Create versioned files (no `V2.dart`, `_improved.dart`)
- Modify files with scripts/regex (manual changes only)
- Break Clean Architecture boundaries

### ✅ DO
- Use `bd` for task tracking
- Reserve files before editing: `file_reservation_paths()`
- Sync regularly: `bd sync`
- Reference phase issues in commit messages: `[sheet-scanner-dtj]`
- Run quality gates after changes

---

## Communication Protocol

1. **Agent Introduction**: Post to agent mail with role/responsibilities
2. **File Conflicts**: Use agent mail to discuss before reserving
3. **Blockers**: Update beads issue with `blocked_by` relationship
4. **Progress**: Post daily updates to agent mail
5. **Code Review**: Request review via agent mail with diff links

---

## Success Metrics

- ✅ All Phase 1 tasks complete and green
- ✅ App compiles with no warnings
- ✅ Architecture integrity verified
- ✅ File reservations prevent conflicts
- ✅ Test coverage > 70% for domain layer
- ✅ All tasks tracked in beads (status, priority, dependencies)
- ✅ Zero unreviewed code merged

---

## Next Actions

1. **BrownPond** (Coordinator):
   - Wait for other agents to register
   - Assign tasks based on agent count/specialization
   - Monitor progress via beads
   
2. **Assigned Agents**:
   - Reserve files for your tasks
   - Update beads status as you work
   - Request code review via agent mail
   - Sync regularly: `bd sync`

---

**Status**: Awaiting agent assignments
**Last Updated**: 2025-12-06T20:24:44Z
