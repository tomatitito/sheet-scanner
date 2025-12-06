# Session Coordination - GreenMountain

**Date**: 2025-12-06  
**Agent**: GreenMountain  
**Role**: Multi-agent coordination and task assignment

## Project Analysis

### Current State
- ✅ Project repo initialized
- ✅ Complete PLAN.md with architecture details
- ✅ FLUTTER_DART_BEST_PRACTICES.md with quality standards
- ✅ 31 Beads issues created and organized into 5 phases
- ⏳ No agents working yet (awaiting assignment)

### Beads Structure

**5 Phases at Priority 0 (Main Work Streams):**
1. **bd-sheet-scanner-l3k**: Phase 1 - Foundations
2. **bd-sheet-scanner-d6f**: Phase 2 - Mobile OCR  
3. **bd-sheet-scanner-62k**: Phase 3 - Desktop Workflow
4. **bd-sheet-scanner-6ir**: Phase 4 - Search & Filtering
5. **bd-sheet-scanner-tfj**: Phase 5 - Backup & Polish

**26 Sub-tasks at Priority 1-2** distributed across phases.

### Critical Path
```
Phase 1 (Foundations) ──→ Phase 2/3/4 (Parallel) ──→ Phase 5 (Polish)
    2-3 days              3-4 days each              3-4 days
```

## Proposed Work Division

### Agent Assignments (Recommendations)

**If only 1 agent (me - GreenMountain):**
- Execute sequentially: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
- Estimated total: 14-18 days of development

**If 2 agents:**
- Agent A: Phase 1 + Phase 4 (architecture focus)
- Agent B: Phase 2 + Phase 3 (mobile & desktop)
- Phase 5 picks up after 1 and 4 complete

**If 3+ agents:**
- Agent A: Phase 1 (Foundations) - **CRITICAL, blocks all**
- Agent B: Phase 2 (Mobile OCR)
- Agent C: Phase 3 (Desktop) + Phase 5 (Backup/Polish)
- Agent D: Phase 4 (Search) - can start after Phase 1 domain entities

## Next Session Action Items

### Immediate (Before Starting Code)
- [ ] Determine if other agents are participating
- [ ] For each active agent: assign primary phase + support responsibilities
- [ ] Create file reservation strategy per phase
- [ ] Install git hooks: `bd hooks install`
- [ ] Verify all agents can access git repo and Beads

### Phase 1 Kickoff (Before Anyone Codes)
- [ ] Review PLAN.md sections 6.1 (Project Structure) and 6.2 (Layer Hierarchy)
- [ ] Create detailed entity specifications (SheetMusic, Tag, Composer)
- [ ] Design database schema (Drift DDL)
- [ ] Design repository interfaces (abstract classes)
- [ ] Document DI setup (get_it config)

### Quality Standards Agreement
- [ ] All code must pass: `fvm dart analyze` (no errors/warnings)
- [ ] All code must pass: `fvm dart format --set-exit-if-changed`
- [ ] All code must compile: `fvm flutter build apk --debug` (or equivalent)
- [ ] All commits must have: `[bd-XXXX] Description`
- [ ] All commits use GPG signing (configured in CLAUDE.md)

## File Reservation Strategy

### By Phase
- **Phase 1**: `lib/core/**`, `lib/features/sheet_music/domain/**`
- **Phase 2**: `lib/features/ocr/**`, image storage paths
- **Phase 3**: File picker UI, `lib/features/*/presentation/** (layouts)`
- **Phase 4**: `lib/features/search/**`, `lib/features/sheet_music/presentation/**`
- **Phase 5**: `lib/features/backup/**`, `lib/features/settings/**`

### Shared/Coordination Points
- `lib/main.dart` - only for final app shell
- `pubspec.yaml` - changes discussed first
- Database schema - locked during other phases

## Git/Sync Protocol

**End of each session, each agent must:**
1. Ensure all local changes committed
2. Update Beads status: `bd update <id> --status <status>`
3. Force sync: `bd sync` (immediate push to remote)
4. Verify clean state: `git status` (nothing untracked, working tree clean)
5. Message next agent with progress and blockers

**Never leave:**
- Uncommitted changes
- Stale Beads database state
- Unpushed commits

## Risk Mitigation

### Database Schema Conflicts
- Phase 1 leader creates schema, others don't modify
- Schema changes require coordinated discussion
- Lock schema after Phase 1 is 90% complete

### Merge Conflicts
- Each phase owns distinct feature directories
- Use file reservations proactively
- Commit frequently with atomic units
- Rebase rather than merge when possible

### Missing Dependencies
- Phase 2 needs Phase 1 entities/DI before starting
- Phase 4 needs Phase 1 database before FTS5 implementation
- Phase 5 needs Phases 1 & 4 complete

### Quality Regression
- Run quality gates at start/end of each session
- If any phase fails gates, file P0 issue immediately
- All phases must pass before "landing the plane"

## Success Criteria

### End of Session Checklist
- ✅ All code passes static analysis
- ✅ All code properly formatted
- ✅ Project builds without errors
- ✅ No untracked files
- ✅ No uncommitted changes
- ✅ All changes pushed to remote
- ✅ Beads updated with accurate status
- ✅ Blocking issues identified and filed

## References

- **PLAN.md** - Complete architecture and feature specifications
- **SCREENS.md** - UI wireframes and component specifications
- **COORDINATION_PLAN.md** - Detailed work breakdown and coordination rules
- **FLUTTER_DART_BEST_PRACTICES.md** - Code quality and style standards
- **AGENTS.md** - Multi-agent coordination and git safety rules
- **CLAUDE.md** - Environment-specific rules and git config

---

**Status**: Ready for agent assignment and Phase 1 kickoff
