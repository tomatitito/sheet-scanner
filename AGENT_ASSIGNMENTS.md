# 🎼 Agent Specialization & Task Assignments

**Status:** Ready for implementation  
**Date:** 2025-12-06

---

## Overview

The Sheet Scanner project has been analyzed and decomposed into **5 agent specializations**, each owning a distinct domain. This document provides:
1. Agent roles & responsibilities
2. Detailed task assignments
3. Dependency graph for each agent
4. Hand-off points and integration

---

## 1. Core/Lead Agent

**Role:** Architecture, Foundations, & Code Review  
**Priority:** CRITICAL - Must start first  
**Timeline:** Weeks 1-2

### Owned Phase
**Phase 1: Foundations** (All 7 tasks)

### Detailed Tasks

#### 1. `sheet-scanner-dtj` - Project Structure & Clean Architecture Setup
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** None (start first)
- **Deliverables:**
  - Complete Flutter project structure
  - Clean Architecture folder hierarchy
  - Feature-based organization
  - Core layer foundation
  - README for project structure
  - Initial `.gitignore` and pubspec.yaml
- **Key Files:**
  ```
  lib/
  ├── core/
  │   ├── di/
  │   ├── error/
  │   ├── platform/
  │   └── utils/
  ├── features/
  │   ├── sheet_music/
  │   ├── ocr/
  │   ├── search/
  │   └── backup/
  └── main.dart
  ```
- **Tests:** None (structural task)

#### 2. `sheet-scanner-us8` - Domain Entities (SheetMusic, Tag, Composer)
- **Status:** Not started
- **Effort:** 1-2 hours
- **Dependencies:** `dtj` (must have project structure)
- **Deliverables:**
  - SheetMusic entity class
  - Tag entity class
  - Composer entity class
  - Value equality and immutability
  - Documentation comments
- **Key Entities:**
  ```dart
  class SheetMusic {
    final int id;
    final String title;
    final String composer;
    final String notes;
    final List<String> imageUrls;
    final List<String> tags;
    final DateTime createdAt;
    final DateTime updatedAt;
  }
  
  class Tag {
    final int id;
    final String name;
    final int count; // number of sheets with this tag
  }
  
  class Composer {
    final int id;
    final String name;
    final int count; // number of sheets by this composer
  }
  ```
- **Tests:** Unit tests for entity equality

#### 3. `sheet-scanner-9uw` - Drift Database with FTS5 Support
- **Status:** Not started
- **Effort:** 3-4 hours
- **Dependencies:** `us8` (needs entities)
- **Deliverables:**
  - Drift database setup with sqlite3_flutter_libs
  - Tables for SheetMusic, Tag, SheetMusicTag mapping
  - FTS5 virtual table for full-text search
  - Migrations framework
  - Database initialization
  - Connection management
- **Database Schema:**
  - `sheet_music` - Main table
  - `tags` - Tag definitions
  - `sheet_music_tags` - Junction table
  - `sheet_music_fts` - FTS5 virtual table
- **Tests:** Database initialization, table creation

#### 4. `sheet-scanner-24w` - get_it Dependency Injection Setup
- **Status:** Not started
- **Effort:** 1-2 hours
- **Dependencies:** `dtj` (project structure), `9uw` (database)
- **Deliverables:**
  - Service locator configuration
  - Repository registration
  - DataSource registration
  - UseCase registration
  - Factory setup
  - Lazy singleton patterns
- **Key Setup:**
  ```dart
  // core/di/injection.dart
  final getIt = GetIt.instance;
  
  void setupInjection() {
    // Register database
    // Register repositories
    // Register use cases
    // Register cubits
  }
  ```
- **Tests:** Dependency resolution tests

#### 5. `sheet-scanner-t42` - Repository Pattern Interfaces
- **Status:** Not started
- **Effort:** 1-2 hours
- **Dependencies:** `us8` (needs entities)
- **Deliverables:**
  - Abstract repository interfaces for each feature
  - Either/Result type usage
  - Failure handling contracts
  - Repository documentation
- **Interfaces:**
  - SheetMusicRepository
  - TagRepository
  - OCRRepository
  - SearchRepository
  - BackupRepository
- **Tests:** Interface contracts (abstract)

#### 6. `sheet-scanner-2yi` - Image Storage System with path_provider
- **Status:** Not started
- **Effort:** 1-2 hours
- **Dependencies:** `dtj` (project structure)
- **Deliverables:**
  - Image directory initialization
  - Image save/load functionality
  - File naming strategy
  - Cleanup utilities
  - Error handling
- **Features:**
  - Save images with unique IDs
  - Load images by sheet ID
  - Cleanup on sheet deletion
  - Disk space management utilities
- **Tests:** Image save/load, error cases

#### 7. `sheet-scanner-hpe` - App Shell & Navigation Skeleton
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** `dtj` (project structure)
- **Deliverables:**
  - GoRouter setup with declarative routing
  - Navigation structure (mobile & desktop)
  - App state management
  - Placeholder screens for all routes
  - Error screen
- **Routes:**
  - `/` - Home/Dashboard
  - `/scan` - Camera (mobile) / Upload (desktop)
  - `/browse` - Inventory list
  - `/search` - Search results
  - `/detail/:id` - Sheet detail
  - `/settings` - Settings
- **Tests:** Route navigation tests

### Responsibilities After Phase 1

1. **Architectural Oversight**
   - Review all features for Clean Architecture compliance
   - Approve new modules and feature structure
   - Maintain dependency rules

2. **Code Review Leadership**
   - Approve all PRs for architectural alignment
   - Guide other agents on design patterns
   - Enforce quality standards

3. **Integration Points**
   - Maintain core layer consistency
   - Manage dependency injection configuration
   - Handle cross-feature communication

4. **Documentation**
   - Keep architecture documentation current
   - Document design decisions
   - Maintain coding standards

---

## 2. Mobile/OCR Agent

**Role:** Mobile OCR feature implementation  
**Priority:** High (starts Week 2, after Phase 1)  
**Timeline:** Weeks 2-3

### Owned Phase
**Phase 2: Mobile OCR** (4 tasks)

### Detailed Tasks

#### 1. `sheet-scanner-9xw` - ML Kit Integration for Text Recognition
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1 (core, DI, image storage)
- **Deliverables:**
  - ML Kit setup and initialization
  - Text recognition implementation
  - Image processing pipeline
  - OCR result parsing
  - Error handling for recognition
  - Platform-specific setup (iOS/Android)
- **Key Features:**
  - Detect text from images
  - Extract metadata (confidence scores)
  - Handle multiple text blocks
  - Process rotated images
- **Tests:** ML Kit integration tests with sample images

#### 2. `sheet-scanner-ri1` - Camera Capture UI & Viewfinder
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `9xw` (ML Kit)
- **Deliverables:**
  - Camera widget setup
  - Live preview
  - Capture button UI
  - Permissions handling
  - Error states
  - Mobile-optimized layout
- **UI Elements:**
  - Full-screen camera preview
  - Capture button (bottom center)
  - Gallery access button
  - Permissions prompt
  - Error messages
- **Tests:** Camera initialization, permissions

#### 3. `sheet-scanner-bsb` - OCRScanCubit State Management
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `9xw`, `ri1`
- **Deliverables:**
  - Cubit implementation for OCR flow
  - State definitions with freezed
  - Processing state management
  - Result handling
  - Error state management
- **States:**
  ```dart
  @freezed
  class OCRScanState with _$OCRScanState {
    const factory OCRScanState.initial() = _Initial;
    const factory OCRScanState.processing({required double progress}) = _Processing;
    const factory OCRScanState.success({required OCRResult result}) = _Success;
    const factory OCRScanState.error(String message) = _Error;
  }
  ```
- **Tests:** State transitions, event handling

#### 4. `sheet-scanner-qaq` - OCR Review/Edit Screen
- **Status:** Not started
- **Effort:** 3-4 hours
- **Dependencies:** Phase 1, all above Phase 2 tasks
- **Deliverables:**
  - OCR results display
  - Edit form for detected metadata
  - Confidence badges
  - Save/cancel actions
  - Navigation to sheet detail
- **UI Elements:**
  - OCR result preview
  - Title field (editable, pre-filled from OCR)
  - Composer field (editable, pre-filled from OCR)
  - Notes field (multiline)
  - Tag selection
  - Save/Cancel buttons
- **Tests:** Form validation, state binding

### Dependencies Flow

```
Phase 1 → 9xw (ML Kit) → ri1 (Camera UI) ↘
                                           → bsb (OCRScanCubit) → qaq (Review Screen)
```

### Integration Points

- **Mobile Only:** Camera access specific to mobile
- **With Sheet Music Feature:** Save OCR results as SheetMusic entity
- **With Image Storage:** Store captured images in app storage

---

## 3. Desktop/Frontend Agent

**Role:** Desktop workflow & UI implementation  
**Priority:** High (starts Week 2, parallel with Mobile)  
**Timeline:** Weeks 2-4

### Owned Phase
**Phase 3: Desktop Workflow** + UI screens from Phases 1-5

### Detailed Tasks from Phase 3

#### 1. `sheet-scanner-3je` - File Picker & Drag-Drop Upload
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1
- **Deliverables:**
  - Native file picker integration
  - Drag-drop zone UI
  - File validation
  - Multiple file selection
  - Error handling
- **Features:**
  - Platform-native file picker
  - Drag-drop from desktop
  - Image format validation
  - File size limits
- **Tests:** File picker integration, drag-drop

#### 2. `sheet-scanner-fc3` - Desktop-Specific Layouts & Navigation
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `hpe` (app shell)
- **Deliverables:**
  - Desktop sidebar navigation
  - Multi-column layouts
  - Keyboard shortcuts
  - Context menus
  - Responsive breakpoints
- **Layouts:**
  - Sidebar nav (collapsible)
  - Content area
  - Detail pane (optional)
  - Settings panel
- **Tests:** Layout responsiveness, navigation

### Owned UI Screens (from other phases)

#### 3. `sheet-scanner-c19` - Home/Dashboard Screen
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, database connection
- **Deliverables:**
  - Stats display (total sheets, composers, tags)
  - Recent activity list
  - Quick action buttons
  - Adaptive layout (mobile/desktop)
- **UI Elements:**
  - Stats cards
  - Recent sheets list
  - Add sheet button (CTA)
  - Navigation to browse
- **Tests:** Widget tests for stats display

#### 4. `sheet-scanner-my0` - Browse/Inventory List Screen (MVP)
- **Status:** Not started
- **Effort:** 3-4 hours
- **Dependencies:** Phase 1, `c19` (home flow)
- **Deliverables:**
  - Sheet music list view
  - Lazy loading with ListView.builder
  - Adaptive grid (mobile/desktop)
  - Empty states
  - Item actions
- **UI Elements:**
  - List/Grid toggle
  - Sheet cards (with cover image)
  - Composer & title display
  - Tap to detail view
- **Tests:** List building, item rendering

#### 5. `sheet-scanner-0fi` - Search/Browse UI with Filters
- **Status:** Not started
- **Effort:** 3-4 hours
- **Dependencies:** Phase 1, `my0`, SearchCubit from Phase 4
- **Deliverables:**
  - Search bar with debounce
  - Filter button/sidebar
  - Filter UI (tags, composer)
  - Sort options
  - Live search results
- **UI Elements:**
  - Search input
  - Filter chips
  - Sorted results list
  - Clear filters button
- **Tests:** Search integration, filter UI

#### 6. `sheet-scanner-pcl` - Sheet Detail View Modal
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `my0`
- **Deliverables:**
  - Full sheet metadata display
  - Image gallery/carousel
  - Edit/delete actions
  - Share functionality
  - Tag display
- **UI Elements:**
  - Large image display
  - Title/composer/tags
  - Notes display
  - Action buttons (edit, delete, share)
  - Modal backdrop & animations
- **Tests:** Detail view rendering, actions

#### 7. `sheet-scanner-3nc` - Settings/Configuration Screen
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1
- **Deliverables:**
  - App preferences UI
  - Theme toggle (light/dark)
  - Backup section link
  - App info
  - About page
- **UI Elements:**
  - Settings form
  - Theme selector
  - Export/Backup link
  - App version
  - Clear cache button
- **Tests:** Settings persistence, theme toggle

### Integration Points

- **With Phase 2:** Handle OCR results from mobile
- **With Phase 4:** Connect search results to filter UI
- **With Phase 5:** Link to backup/export

---

## 4. Search/Data Agent

**Role:** Search, filtering, and data querying  
**Priority:** High (starts Week 2, after Phase 1)  
**Timeline:** Weeks 2-3

### Owned Phase
**Phase 4: Search & Filtering** (6 tasks)

### Detailed Tasks

#### 1. `sheet-scanner-eg7` - FTS5 Full-Text Search Integration
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1 (database)
- **Deliverables:**
  - FTS5 table setup in Drift
  - Indexing logic
  - Query functions
  - Ranking/relevance
  - Text tokenization
- **Features:**
  - Search by title
  - Search by composer
  - Search by notes
  - Phrase search
  - Relevance ranking
- **Tests:** FTS5 queries, ranking

#### 2. `sheet-scanner-3ct` - Tag Management System
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, domain entities
- **Deliverables:**
  - Tag CRUD operations
  - Tag suggestions
  - Auto-complete
  - Tag merging
  - Tag deletion with cascade
- **Features:**
  - Create tags
  - List all tags with counts
  - Suggest tags based on existing
  - Merge duplicate tags
  - Delete unused tags
- **Tests:** Tag operations, cascade behavior

#### 3. `sheet-scanner-2tm` - SearchCubit State Management
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `eg7` (FTS5)
- **Deliverables:**
  - Cubit for search/filter state
  - Debounced search
  - Filter state management
  - Sort options
- **States:**
  ```dart
  @freezed
  class SearchState with _$SearchState {
    const factory SearchState.idle() = _Idle;
    const factory SearchState.searching() = _Searching;
    const factory SearchState.results({required List<SheetMusic> sheets}) = _Results;
    const factory SearchState.error(String message) = _Error;
  }
  ```
- **Tests:** Cubit logic, debouncing

#### 4. `sheet-scanner-1qd` - Advanced Search/Filter Modal
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `2tm`
- **Deliverables:**
  - Complex filter UI
  - Date range picker
  - Multi-select for tags
  - Composer filter
  - Notes filter
  - Save search filters
- **UI Elements:**
  - Filter form
  - Preset filters
  - Save/load filters
  - Clear all button
- **Tests:** Advanced filter logic

### Dependencies Flow

```
Phase 1 → eg7 (FTS5) → 2tm (SearchCubit) ↘
       → 3ct (Tags)  ─────────────────────→ 1qd (Advanced Search UI)
```

### Integration Points

- **With Sheet Music Feature:** Query SheetMusic entities
- **With Browse UI:** Provide search results
- **With Detail View:** Link filtered items

---

## 5. Backup/Polish Agent

**Role:** Export, import, backup, and finalization  
**Priority:** Medium (starts Week 2-3)  
**Timeline:** Weeks 3-4

### Owned Phase
**Phase 5: Backup & Polish** (8 tasks)

### Detailed Tasks

#### 1. `sheet-scanner-8py` - Export Functionality (JSON/ZIP/Database)
- **Status:** Not started
- **Effort:** 3-4 hours
- **Dependencies:** Phase 1, database
- **Deliverables:**
  - JSON export (metadata only)
  - ZIP export (with images)
  - Database export (raw SQLite)
  - Export scheduling
  - Error handling
- **Export Formats:**
  - JSON: Lightweight, metadata only
  - ZIP: Complete with images
  - SQLite: Raw database file
- **Tests:** Export file creation, integrity

#### 2. `sheet-scanner-dty` - Import Functionality (Merge/Replace Modes)
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `8py` (export format knowledge)
- **Deliverables:**
  - Import from JSON
  - Import from ZIP
  - Import from database
  - Merge mode (skip duplicates)
  - Replace mode (delete all, import)
  - Duplicate detection
  - Error rollback
- **Features:**
  - Parse import file
  - Validate schema
  - Detect duplicates by title+composer
  - Merge with existing data
  - Restore images
- **Tests:** Import scenarios, merge logic

#### 3. `sheet-scanner-6o2` - Backup/Export UI Screen
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `8py` (export logic)
- **Deliverables:**
  - Export format selector
  - File location picker
  - Progress indicator
  - Success/error messages
  - Share functionality (mobile)
  - Import file selector
- **UI Elements:**
  - Format selection (JSON/ZIP/DB)
  - Include images checkbox
  - Save location picker
  - Progress bar
  - Completion message
  - Share button (mobile)
- **Tests:** UI interactions, file selection

#### 4. `sheet-scanner-pp1` - Bulk Operations (Desktop)
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `my0` (list UI)
- **Deliverables:**
  - Multi-select checkboxes
  - Bulk delete
  - Bulk tag operations
  - Bulk export selected
  - Action toolbar
  - Selection UI
- **Features:**
  - Select multiple sheets
  - Batch delete with confirmation
  - Add/remove tags in bulk
  - Export selected sheets
  - Select all/clear all
- **Tests:** Bulk operation logic

#### 5. `sheet-scanner-7rz` - Edit Existing Sheet Functionality
- **Status:** Not started
- **Effort:** 2-3 hours
- **Dependencies:** Phase 1, `pcl` (detail view)
- **Deliverables:**
  - Edit form modal
  - Update SheetMusic entity
  - Image management
  - Tag updates
  - Save/cancel logic
  - Validation
- **UI Elements:**
  - Edit form
  - Image gallery (delete/add)
  - Tag multi-select
  - Notes field
  - Save/Cancel buttons
- **Tests:** Form validation, updates

### Integration Points

- **With Browse UI:** Bulk operations context
- **With Settings:** Export settings
- **With File Storage:** Image inclusion in exports

---

## Task Dependencies Summary

### Critical Path (Must Complete Sequentially)

```
Phase 1 (dtj, us8, 9uw, 24w, t42, 2yi, hpe)
    ↓
Phase 2, 3, 4, 5 (Can run in parallel after Phase 1)
```

### Within Phase 4 (Sequential)

```
eg7 (FTS5) → 2tm (SearchCubit) → 1qd (Advanced Search UI)
3ct (Tags) ───────────────┘
```

### Within Phase 5 (Mostly Independent)

```
8py (Export) → dty (Import)
            → 6o2 (Backup UI)
pp1 (Bulk Ops) ← depends on Phase 1 + browse UI
7rz (Edit) ← depends on Phase 1 + detail view
```

---

## Hand-Off Protocol

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
- Follow import rules (never import data/presentation from other features)

### Integration Testing

Core/Lead Agent responsible for:
- Verifying all features integrate correctly
- Checking cross-feature communication
- Ensuring no broken dependencies
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

## Next Steps

1. **Assign agents** to their specializations
2. **Core/Lead agent** starts Phase 1 immediately
3. **Schedule daily standup** for status sync
4. **Use beads for tracking**:
   ```bash
   bd update <task-id> --status in_progress
   bd close <task-id> --reason "Completed and merged"
   ```
5. **Code reviews** per COORDINATION_PLAN.md
6. **Weekly retrospective** on Friday

---

*Ready to start. Waiting for agent assignments.*
