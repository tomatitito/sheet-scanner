---
id: sheet-scanner-t70
status: closed
deps: []
links: []
created: 2026-01-13T22:42:41.97103+01:00
type: task
priority: 2
---
# Download and embed Open Opus dataset for composer/works data

Downloaded the Open Opus public domain dataset (https://api.openopus.org/work/dump.json) containing:
- 25,195 works across 200+ composers
- Composer metadata: name, complete_name, epoch, birth/death years
- Work metadata: title, subtitle, genre, popular/recommended flags

File saved to: lib/data/openopus_dump.json (3.2 MB)

This provides the data source for:
- Composer autocomplete (sheet-scanner-388)
- Local composer list (sheet-scanner-qdy)
- Title auto-suggestions (sheet-scanner-c0o)


