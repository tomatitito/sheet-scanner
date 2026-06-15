---
id: sheet-scanner-zpv
status: closed
deps: []
links: []
created: 2026-02-05T23:13:49.67485+01:00
type: epic
priority: 3
---
# Crawl zerluth.de for flute repertoire data

Crawl 17,325 flute sheet music entries from zerluth.de to enrich the app with:
- Schwierigkeitsgrad (Difficulty Level, 1-5)
- Besetzung (Instrumentation)
- Epoche (Era, derived from composer)

See docs/zerluth-crawler-plan.md for full technical details.

Subtasks:
- sheet-scanner-zlx: Create Dart crawler script
- sheet-scanner-d5k: Run full crawl (17k items)
- sheet-scanner-dfr: Add fields to SheetMusic entity
- sheet-scanner-dmc: Database migration
- sheet-scanner-bnu: Update UI
- sheet-scanner-dxg: Integrate data with composer matching


