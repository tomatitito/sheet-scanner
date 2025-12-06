# Sheet Scanner - Agent Coordination & Work Plan

**Agent**: ChartreuseLake (claude-opus-4.1)  
**Date**: 2025-12-06  
**Status**: Ready for implementation

---

## I. Project Initialization Summary

### Agent Registration
✅ **Registered with Agent Mail** as `ChartreuseLake`
- Program: claude-code
- Model: claude-opus-4.1
- Task: Coordinate and execute sheet-scanner development

### Documentation Review
✅ **AGENTS.md** - Reviewed all rules:
- NO deletions without explicit permission
- Use FVM for all flutter/dart commands (never direct)
- Make code changes manually (no brittle scripts)
- No backwards compatibility needed (early development)
- Avoid file proliferation (revise in place)
- Colorful, detailed console output preferred
- Always verify Dart/Flutter changes for compile/lint errors

✅ **FLUTTER_DART_BEST_PRACTICES.md** - Core principles understood:
- Clean Architecture + Feature-First organization
- Cubit for state management (not Provider)
- SOLID principles throughout
- Immutable widgets and data structures
- Repository pattern for data abstraction
- Comprehensive testing strategy
- Dependency injection via get_it
- Platform-specific adaptation (iOS/Android/Desktop)

---

## II. Current Project State

### Beads Issue Database
**33 total tasks** organized in 5 phases:

| Phase | Status | Tasks | Priority | Dependencies |
|-------|--------|-------|----------|--------------|
| Phase 1: Foundations | OPEN | 5 | P1 | None (base layer) |
| Phase 2: Mobile OCR | OPEN | 5 | P1 | Phase 1 |
| Phase 3: Desktop Workflow | OPEN | 4 | P1 | Phase 1 |
| Phase 4: Search & Filtering | OPEN | 4 | P1 | Phase 1 |
| Phase 5: Backup & Polish | OPEN | 3 | P1 | All phases |
| High-Priority Features | OPEN | 7 | P2 | Mixed |

### Phase 1: Foundations (CRITICAL PATH)
1. `sheet-scanner-dtj` - Setup Flutter project structure with Clean Architecture
2. `sheet-scanner-us8` - Create domain entities: SheetMusic, Tag, Composer
3. `sheet-scanner-9uw` - Setup Drift database with FTS5 support
4. `sheet-scanner-t42` - Implement repository pattern interfaces
5. `sheet-scanner-24w` - Setup get_it dependency injection
6. `sheet-scanner-hpe` - Create basic app shell and navigation skeleton

### Phase 2: Mobile OCR
- Integrate ML Kit for text recognition
- Build OCRScanCubit state management
- Build camera capture UI and viewfinder
- Implement OCR review/edit screen
- Create image storage system with path_provider

### Phase 3: Desktop Workflow
- Implement file picker and drag-drop UI
- Build desktop-specific layouts and navigation
- Create home/dashboard screen (MVP)
- Create sheet detail view modal

### Phase 4: Search & Filtering
- Integrate FTS5 full-text search
- Build search/browse with filtering UI
- Implement tag management system
- Build SearchCubit state management

### Phase 5: Backup & Polish
- Implement export functionality (JSON/ZIP/Database)
- Implement import functionality with merge/replace modes
- Build backup/export UI screen

### High-Priority Additional Tasks
- Create basic app shell and navigation skeleton
- Implement browse/inventory list screen (MVP)
- Build sheet detail view modal
- Build desktop-specific layouts and navigation
- Implement file picker and drag-drop UI
- Build camera capture UI and viewfinder
- Build OCRScanCubit state management
- Setup edit existing sheet functionality
- Build settings/configuration screen
- Implement bulk operations for desktop
- Create advanced search/filter modal
- Create image storage system

---

## III. Recommended Work Strategy

### Single-Agent Approach (Current)
**Sequential execution through all phases:**

1. **Phase 1 (Foundation)** - Complete all 5 tasks
   - Estimated: 2-3 days
   - Outputs: Project skeleton, database schema, DI setup
   - Blocks: All downstream work

2. **Phase 2 (Mobile OCR)** - Complete all 5 tasks
   - Estimated: 3-4 days
   - Outputs: Mobile scan workflow, ML Kit integration

3. **Phase 3 (Desktop)** - Complete all 4 tasks
   - Estimated: 2-3 days
   - Outputs: Desktop UI, file picker, navigation

4. **Phase 4 (Search & Filtering)** - Complete all 4 tasks
   - Estimated: 2-3 days
   - Outputs: FTS5 integration, search UI, tag management

5. **Phase 5 (Backup & Polish)** - Complete all 3 tasks
   - Estimated: 2 days
   - Outputs: Export/import, settings, refinement

### Multi-Agent Approach (If Team Expands)
**After Phase 1 completion, parallelize by feature domain:**

```
Phase 1 (Foundations) ──────┬─────────────┬─────────────┬─────────────┐
                             │             │             │             │
                        Phase 2        Phase 3      Phase 4       Phase 5
                      (Mobile OCR)  (Desktop UI)  (Search)     (Backup)
                        (Agent A)    (Agent B)    (Agent B)     (Agent C)
                                                                  │
                                                          + High-Priority
                                                           Features
```

**Parallel Work Rules:**
- Each agent owns a complete feature (domain → data → presentation)
- Agents work on different feature domains
- File reservations prevent merge conflicts
- Code reviews follow Clean Architecture layers
- Agent Mail for async decision-making

---

## IV. Quality Assurance & Code Review Strategy

### Pre-Implementation Checklist
- [ ] Run `fvm flutter pub get` to sync dependencies
- [ ] Review FLUTTER_DART_BEST_PRACTICES.md for guidelines
- [ ] Check `analysis_options.yaml` for lint rules
- [ ] Plan architecture layers before coding

### Post-Implementation Verification
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

### Code Review Checklist

**Domain Layer Reviews:**
- [ ] No external dependencies (pure Dart)
- [ ] Entities are immutable
- [ ] Repository interfaces are abstract
- [ ] Use cases contain only business logic
- [ ] Error types (Failure) are properly defined

**Data Layer Reviews:**
- [ ] Repositories implement domain interfaces correctly
- [ ] Data sources are properly abstracted
- [ ] Models convert cleanly to entities
- [ ] Database queries are optimized
- [ ] Error handling maps external exceptions to Failures

**Presentation Layer Reviews:**
- [ ] Cubits manage state correctly
- [ ] Widgets are immutable and composable
- [ ] No business logic in UI code
- [ ] State transitions are complete
- [ ] Error states are handled and displayed

### Testing Requirements
- **Unit Tests**: Domain logic (use cases), data layer (repositories)
- **Widget Tests**: Cubit transitions, UI components
- **Integration Tests**: End-to-end flows (scan → save → search)
- **Lint & Format**: 100% compliance with analysis rules

---

## V. File Organization & Clean Architecture

### Project Structure (After Phase 1)
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

### Dependency Rules (CRITICAL)
**These rules MUST be enforced:**

1. ✅ Features can depend on `core/`
   ```dart
   import 'package:sheet_scanner/core/error/failures.dart';  // OK
   ```

2. ✅ Features can depend on other features' **domain only**
   ```dart
   import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';  // OK
   import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';  // ❌ NO!
   ```

3. ❌ Core cannot depend on features
   ```dart
   import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';  // ❌ NO!
   ```

4. ❌ Domain cannot depend on data or presentation
   ```dart
   // domain/usecases/scan_use_case.dart
   import '../../data/datasources/ml_kit.dart';  // ❌ NO!
   import '../../presentation/cubit/ocr_cubit.dart';  // ❌ NO!
   ```

---

## VI. Coordination Mechanisms

### 1. Beads Issue Tracking
**Commands to know:**
```bash
# Create new issue
bd create "Task title" -t task -p 1 --json

# Update status
bd update sheet-scanner-123 --status in_progress

# List ready tasks
bd ready --json

# Close completed task
bd close sheet-scanner-123 --reason "Completed"

# Force sync to remote
bd sync
```

**Workflow:**
- Use beads as single source of truth for task status
- Prefix Mail subjects with `[bd-123]` for cross-reference
- Link thread_id in Mail to beads issue id

### 2. Agent Mail Messaging
**When to use:**
- Coordination between agents
- Design decisions & architecture questions
- Status updates and blockers
- Code review feedback

**Key commands:**
```
mcp__mcp_agent_mail__send_message    # Send message to agent(s)
mcp__mcp_agent_mail__reply_message   # Continue thread
mcp__mcp_agent_mail__fetch_inbox     # Check for messages
mcp__mcp_agent_mail__mark_message_read
mcp__mcp_agent_mail__acknowledge_message
```

### 3. File Reservations
**When to reserve:**
- Starting work on a feature module
- Making significant refactors
- Avoiding parallel edits of same files

**Commands:**
```bash
# Reserve feature files
mcp__mcp_agent_mail__file_reservation_paths(
  paths: ["lib/features/sheet_music/**"],
  exclusive: true,
  reason: "bd-123: Implementing sheet_music feature"
)

# Release when done
mcp__mcp_agent_mail__release_file_reservations(...)
```

---

## VII. Session Workflow (For Agents)

**At session start:**
1. Call `macro_start_session` with project path and task description
2. Check inbox with `fetch_inbox` for messages from other agents
3. Reserve feature files if applicable

**During session:**
1. Make code changes following guidelines
2. Run lint/format/test verification
3. Create new beads issues for discovered problems
4. Update beads issue status as work progresses

**At session end (BEFORE STOPPING):**
1. Close completed beads issues: `bd close issue-id --reason "..."`
2. Update in-progress issues: `bd update issue-id --status ...`
3. Force sync: `bd sync`
4. Verify: `git status` shows "up to date"
5. Release file reservations
6. Document next steps for continuity

---

## VIII. Landing the Plane

When all work is complete:

1. **File remaining issues**
   ```bash
   bd create "Issue title" -p 1 --json
   ```

2. **Run quality gates**
   ```bash
   fvm dart analyze
   fvm dart format lib/
   fvm flutter test
   ```

3. **Close finished issues**
   ```bash
   bd close bd-123 bd-124 --reason "Completed"
   ```

4. **Sync and push**
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # Must show "up to date with origin/main"
   ```

5. **Clean up**
   ```bash
   git stash clear
   git remote prune origin
   ```

6. **Document next session**
   - Provide summary of completed work
   - List filed issues for follow-up
   - Suggest next session prompt

---

## IX. Next Immediate Actions

### Recommended First Session
**Goal**: Complete Phase 1 (Foundations)

**Tasks to complete:**
1. ✓ `sheet-scanner-dtj` - Setup Flutter project structure
2. ✓ `sheet-scanner-hpe` - Create app shell and navigation skeleton
3. ✓ `sheet-scanner-us8` - Create domain entities
4. ✓ `sheet-scanner-9uw` - Setup Drift database with FTS5
5. ✓ `sheet-scanner-t42` - Implement repository pattern interfaces
6. ✓ `sheet-scanner-24w` - Setup get_it dependency injection

**Deliverables:**
- [ ] Flutter project runs without errors
- [ ] Database schema generated
- [ ] DI container configured
- [ ] Basic navigation works
- [ ] All tests pass
- [ ] Lint/format compliance 100%

---

## X. Communication Template for Other Agents

When other agents join, introduce yourself with this template:

```markdown
## New Agent Onboarding

Hello, I'm [AgentName]. I'm joining the sheet-scanner project.

### Quick Start
1. Read AGENTS.md and FLUTTER_DART_BEST_PRACTICES.md
2. Review this AGENT_COORDINATION.md file
3. Check current beads issues: `bd list --json`
4. Review PLAN.md for architecture details

### Coordination
- Use Agent Mail for decisions/questions
- Use Beads for issue tracking
- Use file reservations to avoid conflicts
- Code reviews follow Clean Architecture layers

### My Focus
I'm taking responsibility for:
- [Phase X / Feature Y]
- Work period: [dates]
- Blockers: [if any]

Let's sync on architecture before I start coding!
```

---

## Summary

**Ready for Phase 1 Implementation?**

The project is well-documented and architecturally sound. Phase 1 is the critical path—once it's complete, downstream phases can be parallelized.

**Key Success Factors:**
✅ Clean Architecture discipline (domain purity critical)
✅ Comprehensive testing at each layer
✅ Strict dependency rules enforcement
✅ Regular synchronization with `bd sync`
✅ Code reviews for architecture compliance

**First Step**: Begin Phase 1 setup and register any additional agents who join.
