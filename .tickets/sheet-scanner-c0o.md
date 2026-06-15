---
id: sheet-scanner-c0o
status: closed
deps: [sheet-scanner-qdy]
links: []
created: 2026-01-13T22:34:41.784426+01:00
type: feature
priority: 2
---
# Auto-suggest piece titles based on selected composer

When a composer is selected, provide auto-suggestions for well-known titles/works by that composer as the user types.

Requirements:
- Suggest titles based on selected composer
- Filter suggestions as user types
- Need a local database mapping composers to their famous works

Example:
- Mozart selected → suggest 'Eine kleine Nachtmusik', 'Symphony No. 40', 'Piano Sonata No. 11', 'Requiem', etc.
- Bach selected → suggest 'Toccata and Fugue in D minor', 'Goldberg Variations', 'Well-Tempered Clavier', etc.

Data sources to investigate:
- IMSLP catalog (comprehensive but large)
- Open Opus API data (could download and embed)
- Wikidata SPARQL query for notable works
- Hand-curated top 20-50 works per major composer


