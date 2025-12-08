# Sheet Scanner - Task Assignments & Status

**Status:** In Progress (Phase 1 underway)  
**Last Updated:** 2025-12-06

---

## Overview

Sheet Scanner is decomposed into **5 phases** with 33 total tasks:

| Phase | Status | Tasks | Priority | Dependencies |
|-------|--------|-------|----------|--------------|
| Phase 1: Foundations | IN PROGRESS | 7 | P1 | None (base layer) |
| Phase 2: Mobile OCR | Open | 5 | P1 | Phase 1 |
| Phase 3: Desktop Workflow | Open | 7 | P1 | Phase 1 |
| Phase 4: Search & Filtering | Open | 4 | P1 | Phase 1 |
| Phase 5: Backup & Polish | Open | 5 | P1 | All phases |

---

## Phase 1: Foundations (CRITICAL PATH)

**Owner**: Core/Lead Agent  
**Timeline**: Weeks 1-2  
**Status**: IN PROGRESS (BlackCreek started, FuchsiaPond coordinating)

### Tasks

#### 1. `sheet-scanner-dtj` - Project Structure & Clean Architecture Setup
- **Status**: ✅ COMPLETED
- **Effort**: 2-3 hours
- **Dependencies**: None (start first)
- **Deliverables**:
  - Complete Flutter project structure
  - Clean Architecture folder hierarchy
  - Feature-based organization
  - Core layer foundation

#### 2. `sheet-scanner-us8` - Domain Entities (SheetMusic, Tag, Composer)
- **Status**: TODO
- **Effort**: 1-2 hours
- **Dependencies**: `dtj`
- **Deliverables**:
  - SheetMusic entity class (id, title, composer, notes, imageUrls, tags, createdAt, updatedAt)
  - Tag entity class (id, name, count)
  - Composer entity class (id, name, count)
  - Value equality and immutability
  - Documentation comments

#### 3. `sheet-scanner-9uw` - Drift Database with FTS5 Support
- **Status**: TODO
- **Effort**: 3-4 hours
- **Dependencies**: `us8`
- **Deliverables**:
  - Drift database setup with sqlite3_flutter_libs
  - Tables: sheet_music, tags, sheet_music_tags, sheet_music_fts
  - FTS5 virtual table for full-text search
  - Migrations framework
  - Database initialization

#### 4. `sheet-scanner-t42` - Repository Pattern Interfaces
- **Status**: TODO
- **Effort**: 1-2 hours
- **Dependencies**: `us8`
- **Deliverables**:
  - Abstract repository interfaces
  - Either/Result type usage
  - Failure handling contracts
  - Interfaces: SheetMusicRepository, TagRepository, OCRRepository, SearchRepository, BackupRepository

#### 5. `sheet-scanner-24w` - get_it Dependency Injection Setup
- **Status**: TODO
- **Effort**: 1-2 hours
- **Dependencies**: `dtj`, `9uw`
- **Deliverables**:
  - Service locator configuration
  - Repository registration
  - DataSource registration
  - UseCase registration
  - Factory setup & lazy singletons

#### 6. `sheet-scanner-2yi` - Image Storage System with path_provider
- **Status**: TODO
- **Effort**: 1-2 hours
- **Dependencies**: `dtj`
- **Deliverables**:
  - Image directory initialization
  - Image save/load functionality
  - File naming strategy
  - Cleanup utilities
  - Error handling

#### 7. `sheet-scanner-hpe` - App Shell & Navigation Skeleton
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: `dtj`
- **Deliverables**:
  - GoRouter setup with declarative routing
  - Navigation structure (mobile & desktop)
  - Placeholder screens: /, /scan, /browse, /search, /detail/:id, /settings
  - Error screen

---

## Phase 2: Mobile OCR

**Owner**: Mobile/OCR Agent  
**Timeline**: Weeks 2-3 (starts after Phase 1)  
**Status**: Open

### Task Dependencies Flow
```
Phase 1 → ML Kit Integration → Camera UI ↘
                                         → OCRScanCubit → OCR Review Screen
```

### Tasks

#### 1. `sheet-scanner-9xw` - ML Kit Integration for Text Recognition
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1
- **Deliverables**: ML Kit setup, text recognition, image processing, OCR result parsing

#### 2. `sheet-scanner-ri1` - Camera Capture UI & Viewfinder
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `9xw`
- **Deliverables**: Camera widget, live preview, capture button, permissions, mobile layout

#### 3. `sheet-scanner-bsb` - OCRScanCubit State Management
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `9xw`, `ri1`
- **Deliverables**: Cubit with states (initial, processing, success, error)

#### 4. `sheet-scanner-qaq` - OCR Review/Edit Screen
- **Status**: TODO
- **Effort**: 3-4 hours
- **Dependencies**: Phase 1, all Phase 2 tasks
- **Deliverables**: OCR results display, edit form, confidence badges, save/cancel actions

---

## Phase 3: Desktop Workflow

**Owner**: Desktop/Frontend Agent  
**Timeline**: Weeks 2-4 (parallel with Phase 2)  
**Status**: Open

### Phase 3 Core Tasks

#### 1. `sheet-scanner-3je` - File Picker & Drag-Drop Upload
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1
- **Deliverables**: Native file picker, drag-drop zone, file validation, multiple selection

#### 2. `sheet-scanner-fc3` - Desktop-Specific Layouts & Navigation
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `hpe`
- **Deliverables**: Desktop sidebar, multi-column layouts, keyboard shortcuts, context menus

### Shared UI Screens (from Desktop Agent)

#### 3. `sheet-scanner-c19` - Home/Dashboard Screen
- **Status**: TODO
- **Effort**: 2-3 hours
- **Deliverables**: Stats display, recent activity, quick actions, adaptive layout

#### 4. `sheet-scanner-my0` - Browse/Inventory List Screen (MVP)
- **Status**: TODO
- **Effort**: 3-4 hours
- **Deliverables**: Sheet list/grid, lazy loading, empty states, item actions

#### 5. `sheet-scanner-0fi` - Search/Browse UI with Filters
- **Status**: TODO
- **Effort**: 3-4 hours
- **Deliverables**: Search bar, filter UI, sort options, live results

#### 6. `sheet-scanner-pcl` - Sheet Detail View Modal
- **Status**: TODO
- **Effort**: 2-3 hours
- **Deliverables**: Full metadata, image gallery, edit/delete actions, tag display

#### 7. `sheet-scanner-3nc` - Settings/Configuration Screen
- **Status**: TODO
- **Effort**: 2-3 hours
- **Deliverables**: App preferences, theme toggle, backup link, app info

---

## Phase 4: Search & Filtering

**Owner**: Search/Data Agent  
**Timeline**: Weeks 2-3 (parallel with Phase 2 & 3)  
**Status**: Open

### Task Dependencies Flow
```
Phase 1 → FTS5 Search → SearchCubit ↘
      → Tag Management ─────────────→ Advanced Search UI
```

### Tasks

#### 1. `sheet-scanner-eg7` - FTS5 Full-Text Search Integration
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1
- **Deliverables**: FTS5 table setup, indexing logic, query functions, ranking

#### 2. `sheet-scanner-3ct` - Tag Management System
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1
- **Deliverables**: Tag CRUD, suggestions, auto-complete, merging, cascade deletion

#### 3. `sheet-scanner-2tm` - SearchCubit State Management
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `eg7`
- **Deliverables**: Cubit with debounced search, filter state, sort options

#### 4. `sheet-scanner-1qd` - Advanced Search/Filter Modal
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `2tm`
- **Deliverables**: Complex filter UI, date range picker, multi-select tags, preset filters

---

## Phase 5: Backup & Polish

**Owner**: Backup/Polish Agent  
**Timeline**: Weeks 3-4 (depends on all phases)  
**Status**: Open

### Task Dependencies Flow
```
Phase 1 → Export → Import
      → Backup UI
      → Bulk Operations (with Phase 3 UI)
      → Edit Sheet (with Phase 3 detail view)
```

### Tasks

#### 1. `sheet-scanner-8py` - Export Functionality (JSON/ZIP/Database)
- **Status**: TODO
- **Effort**: 3-4 hours
- **Dependencies**: Phase 1
- **Deliverables**: JSON export, ZIP export with images, SQLite export, scheduling

#### 2. `sheet-scanner-dty` - Import Functionality (Merge/Replace Modes)
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `8py`
- **Deliverables**: Import from JSON/ZIP/DB, merge/replace modes, duplicate detection, rollback

#### 3. `sheet-scanner-6o2` - Backup/Export UI Screen
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, `8py`
- **Deliverables**: Format selector, file picker, progress indicator, success messages

#### 4. `sheet-scanner-pp1` - Bulk Operations (Desktop)
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, Phase 3 browse UI
- **Deliverables**: Multi-select, bulk delete, bulk tags, bulk export, action toolbar

#### 5. `sheet-scanner-7rz` - Edit Existing Sheet Functionality
- **Status**: TODO
- **Effort**: 2-3 hours
- **Dependencies**: Phase 1, Phase 3 detail view
- **Deliverables**: Edit form, image management, tag updates, validation

---

## Agent Hand-Off Protocol

### Phase 1 → Phases 2-5

Core/Lead Agent delivers:
- ✅ Complete project structure
- ✅ Working database with migrations
- ✅ DI setup in `injection.dart`
- ✅ Repository interfaces
- ✅ Image storage system
- ✅ App shell with routing
- ✅ Tests passing
- ✅ No lint/format errors

Phase 2-5 agents:
- Use DI to access services
- Follow repository pattern
- Use Either<Failure, Result> types
- Keep features independent
- Never import data/presentation from other features (domain only)

### Integration Testing

Core/Lead Agent verifies:
- All features integrate correctly
- Cross-feature communication works
- No broken dependencies
- Final code review before merge

---

## Success Metrics

### Code Quality
- 0 lint errors (warnings acceptable)
- 70%+ test coverage
- All tests passing
- Clean architecture compliance verified

### Feature Completeness
- All tasks closed with working code
- Manual testing on target platforms
- UI responsive on mobile/tablet/desktop
- Error handling for edge cases

### Team Health
- Clear communication via beads & agent mail
- No blocked tasks lasting >2 hours
- Daily progress updates
- Weekly retrospectives

---

## Coordination Tools

### Beads Issue Tracking
```bash
bd create "Task title" -t task -p 1
bd update sheet-scanner-123 --status in_progress
bd close sheet-scanner-123 --reason "Completed"
bd ready --json
bd sync
```

### Agent Mail
- Coordination between agents
- Design decisions & architecture questions
- Status updates and blockers
- Code review feedback

### File Reservations
Reserve files before starting work:
```bash
mcp__mcp_agent_mail__file_reservation_paths(
  paths: ["lib/features/sheet_music/**"],
  exclusive: true,
  reason: "sheet-scanner-123: Implementing sheet_music feature"
)
```
