---
id: sheet-scanner-ve5
status: open
deps: [sheet-scanner-vlc0]
links: []
created: 2026-02-21T09:19:55.117634+01:00
type: feature
priority: 2
---
# Extract opus/catalog numbers from work titles into discrete field

## Overview
Extract opus and catalog numbers from work title strings into a discrete `catalogNumber` field on `WorkData`/`WorkInfo` for filtering, display, and search.

## Data Analysis
- **OpenOpus**: 10,941 works (43.4%) have catalog numbers in titles
- **Zerluth**: 2,200+ works have op. numbers, 119 KV, 101 BWV

## Catalog Number Patterns to Extract
| Pattern | Example | Count (OpenOpus) |
|---------|---------|------------------|
| Op./op. | op. 6 | 5,457 |
| K. (Mozart) | K.467 | 1,099 |
| BWV (Bach) | BWV 1067 | (in Zerluth) |
| Wq. (CPE Bach) | Wq.118 | 384 |
| Hob. (Haydn) | Hob.IX:11 | 439 |
| D. (Schubert) | D.944 | 1,023 |
| S. (Liszt) | S.139 | 808 |
| L. (Debussy) | L.119 | 606 |
| WWV (Wagner) | WWV 61 | 47 |
| RV (Vivaldi) | RV 269 | (to add) |

## Implementation Tasks
1. Add `catalogNumber` field to `WorkData` class
2. Add `catalogNumber` field to `WorkInfo` class  
3. Create `CatalogNumberExtractor` utility with regex patterns
4. Apply extraction in `WorkData.fromJson()`
5. Update UI to display catalog number (subtitle or badge)
6. Add catalog number to search index for autocomplete

## Acceptance Criteria
- [ ] Works display their catalog number when available
- [ ] Searching 'K.467' finds Mozart Piano Concerto No. 21
- [ ] Multiple catalog numbers handled (e.g., 'K.467, H.263')


