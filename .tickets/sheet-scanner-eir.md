---
id: sheet-scanner-eir
status: closed
deps: [sheet-scanner-nl5]
links: []
created: 2026-01-14T23:08:43.804465+01:00
type: task
priority: 2
---
# Refactor composers.dart to load from multiple JSON source files

Replace the static const kComposers list with a loader that reads all JSON files from lib/data/sources/ directory at app startup. Merge composers from all sources, deduplicate by name, and expose as List<ComposerData>. This allows adding new repertoire (e.g., violin, clarinet) without code changes.


