---
id: sheet-scanner-4gj
status: closed
deps: []
links: []
created: 2025-12-14T10:12:53.756551+01:00
type: task
priority: 0
---
# BLOCKER: Fix compilation errors in dictation feature

speech_recognition_service.dart has 18 compilation errors: undefined getters (isInitialized), missing type imports, incorrect Stream/freezed usage. Must fix before merging or use git revert to remove incomplete code. Affects: lib/core/services/speech_recognition_service.dart, lib/features/sheet_music/data/repositories/speech_recognition_repository_impl.dart, lib/features/sheet_music/presentation/cubit/dictation_state.dart


