# Phase 3/4 Coordination Plan

**Date**: December 10, 2025  
**Coordinator**: PinkDog  
**Status**: Task breakdown complete, agents assigned, ready for parallel execution

## Executive Summary

Large Phase 3 and Phase 4 beads have been decomposed into **7 smaller, granular tasks** (each 2-5 hours max). Four helper agents have been created and assigned via Agent Mail with clear, focused missions.

**Timeline**: 2 working days total (Phase 3: parallel, Phase 4: sequential with parallel UI)

## Task Breakdown

### Phase 3: Desktop Polish & UX (3 tasks, 2 agents)

| Agent | Task ID | Title | Scope | Hours |
|-------|---------|-------|-------|-------|
| **RedPond** | sheet-scanner-cv1 | Polish desktop file picker | Drag-drop UX, visual feedback, error handling | 2-3 |
| **RedPond** | sheet-scanner-e3l | Desktop-specific responsive layouts | Sidebar nav, multi-column layouts, modal sizing | 2-3 |
| **ChartreuseStone** | sheet-scanner-hpu | Keyboard shortcuts & accessibility | Keyboard nav, focus mgmt, a11y compliance | 2-3 |

**Phase 3 Parallelism**: RedPond and ChartreuseStone can work independently (no dependencies)  
**Estimated Duration**: 4-6 hours (parallel)

### Phase 4: Search & Filtering (4 tasks, 2 agents)

| Agent | Task ID | Title | Scope | Hours | Dependencies |
|-------|---------|-------|-------|-------|--------------|
| **WhiteLake** | sheet-scanner-oak | Setup FTS5 schema in database | Virtual tables, triggers, query optimization | 2 | None |
| **WhiteLake** | sheet-scanner-3k5 | Build SearchCubit with FTS5 queries | State mgmt, debounced search, filtering | 2-3 | oak |
| **LilacLake** | sheet-scanner-29z | Tag management UI (CRUD) | Tag list, dialogs, inline creation | 2 | WhiteLake (can start in parallel) |
| **LilacLake** | sheet-scanner-oq6 | Search results UI with filters | Results display, ranking, filter bar, sort | 2-3 | 3k5 |

**Phase 4 Parallelism**:
- WhiteLake completes oak, then 3k5 (sequential, one agent)
- LilacLake starts 29z while WhiteLake works on 3k5 (parallel)
- LilacLake completes oq6 after WhiteLake finishes 3k5

**Estimated Duration**: 6-8 hours (sequential + parallel UI)

## Agent Assignments

### RedPond
- **Focus**: Phase 3 desktop polish (file picker & layouts)
- **Priority**: High (foundational for other features)
- **Skills**: UI/UX, responsive design, Flutter widgets
- **Message Thread**: Subject starts with `[sheet-scanner-cv1][sheet-scanner-e3l]`
- **Deliverables**:
  - Improved file picker with drag-drop visual feedback
  - Desktop sidebar navigation
  - Multi-column layout for sheet browsing
  - Modal sizing for desktop screens

### ChartreuseStone
- **Focus**: Phase 3 accessibility & keyboard shortcuts
- **Priority**: Medium (polish feature)
- **Skills**: A11y, keyboard interaction, Flutter focus management
- **Message Thread**: Subject starts with `[sheet-scanner-hpu]`
- **Deliverables**:
  - Keyboard navigation for all major screens
  - Global keyboard shortcuts (Cmd/Ctrl+S, etc.)
  - Focus indicators and management
  - Semantic labels for screen readers
  - WCAG 2.1 AA compliance

### WhiteLake
- **Focus**: Phase 4 database & search engine
- **Priority**: Highest (critical path)
- **Skills**: Dart/Drift, database design, query optimization
- **Message Thread**: Subject starts with `[sheet-scanner-oak][sheet-scanner-3k5]`
- **Deliverables**:
  - FTS5 virtual table in Drift schema
  - Auto-sync triggers for indexing
  - SearchCubit with state management
  - FTS5 query execution with ranking
  - Debounced search input handling

### LilacLake
- **Focus**: Phase 4 UI for tags & search results
- **Priority**: High (depends on WhiteLake)
- **Skills**: UI/UX, Cubit state management, list/grid layouts
- **Message Thread**: Subject starts with `[sheet-scanner-29z][sheet-scanner-oq6]`
- **Deliverables**:
  - Tag management screen (CRUD)
  - Tag dialogs (rename, merge, delete)
  - Inline tag creation in search UI
  - Search results list/grid display
  - Filter bar with multiple criteria
  - Sort options (relevance, date, composer)

## Architecture Guidelines

All agents MUST follow:

1. **Clean Architecture**
   - Domain layer: entities, repository interfaces, use cases (no dependencies)
   - Data layer: repository implementations, data sources, models
   - Presentation layer: Cubits, pages, widgets

2. **State Management**
   - Use **Cubit** (not raw BLoC)
   - State classes using `@freezed`
   - Separate states for loading/idle/success/error

3. **File Structure**
   ```
   lib/features/
   ├── feature_name/
   │   ├── data/
   │   │   ├── datasources/
   │   │   ├── models/
   │   │   └── repositories/
   │   ├── domain/
   │   │   ├── entities/
   │   │   ├── repositories/
   │   │   └── usecases/
   │   └── presentation/
   │       ├── cubit/
   │       ├── pages/
   │       └── widgets/
   ```

4. **Key Files to Review**
   - `ARCHITECTURE.md` - Layer dependencies, patterns
   - `AGENTS.md` - Code style, naming conventions
   - `lib/core/di/injection.dart` - Dependency injection setup
   - `lib/features/*/` - Example feature structure

## Coordination Mechanics

### Communication
- **Agent Mail**: Primary coordination channel
- **Message Threads**: One thread per agent/task group
- **Updates**: At task completion, or if blockers appear

### File Reservations
When starting work:
```bash
mcp__mcp_agent_mail__file_reservation_paths(
  project_key="/Volumes/sourcecode/personal/sheet-scanner",
  agent_name="AgentName",
  paths=["lib/features/feature_name/**/*.dart"],
  exclusive=true,
  reason="bd-123: Brief description"
)
```

### Sync Points

**Before coding**: Review architecture, check for conflicts

**After each subtask**:
1. Run `fvm flutter analyze` to check for errors
2. Run `fvm flutter format lib/` if needed
3. Commit with message: `feat/bd-123: Description`
4. Push to branch if needed

**After task completion**:
1. Verify `fvm flutter test` passes (if tests exist)
2. Check app still builds: `fvm flutter build web` (or target platform)
3. Update beads: `bd close bd-123 --reason "Completed"`
4. Sync: `bd sync`

## Quality Gates

Before marking a task complete:

- ✅ Code follows Clean Architecture
- ✅ No lint errors: `fvm flutter analyze`
- ✅ Code formatted: `fvm dart format`
- ✅ Tests pass (if applicable)
- ✅ App builds for target platform
- ✅ Architecture.md patterns followed
- ✅ Commit messages are descriptive
- ✅ No merge conflicts introduced

## Known Constraints

1. **FVM Only**: Always use `fvm flutter` and `fvm dart`, never direct commands
2. **No Regex Changes**: Manual edits only for code changes (no bulk scripts)
3. **Immutable Entities**: Domain entities should be immutable/freezed
4. **No Circular Dependencies**: Features must not depend on sibling features' data/presentation layers
5. **Test on Target Platforms**: Desktop features on macOS, a11y on VoiceOver

## Expected Outcomes

### Phase 3 Completion
- ✅ Improved file picker with UX polish
- ✅ Desktop-optimized layouts and navigation
- ✅ Keyboard shortcuts and accessibility compliance
- ✅ App ready for Phase 4 search implementation

### Phase 4 Completion
- ✅ FTS5 full-text search engine operational
- ✅ SearchCubit with debounced queries
- ✅ Tag management CRUD UI
- ✅ Search results display with filtering and sorting
- ✅ Ready for Phase 5 (backup/export)

## Blockers & Resolution

| Blocker | Owner | Resolution |
|---------|-------|-----------|
| Drift FTS5 syntax unclear | WhiteLake | Review `sqlite3_flutter_libs` docs + examples |
| Keyboard event handling | ChartreuseStone | Check Flutter Focus widget docs |
| Responsive breakpoints | RedPond | Use `LayoutBuilder` + MediaQuery |
| Tag merge logic | LilacLake | Depends on DB schema from WhiteLake |

## Next Steps

1. **RedPond & ChartreuseStone**: Start Phase 3 work immediately (no dependencies)
2. **WhiteLake**: Start FTS5 schema (critical path)
3. **LilacLake**: Await WhiteLake's oak completion, start 29z in parallel
4. **PinkDog**: Monitor progress, unblock as needed, prepare Phase 5 tasks

---

## Quick Reference: Agent Inbox Messages

Each agent has received a dedicated message with:
- ✅ Task scope and acceptance criteria
- ✅ Architecture guidelines
- ✅ Expected time estimates
- ✅ Coordination expectations
- ✅ Clear "what success looks like"

Agents can reply in their thread with blockers or questions.

**Coordinator Email Address**: Use Agent Mail message threads (no external email)

---

**Last Updated**: 2025-12-10 00:26 UTC  
**Status**: Ready for execution
