---
id: sheet-scanner-dsjb
status: open
deps: [sheet-scanner-vlc0]
links: []
created: 2026-02-21T09:20:06.493057+01:00
type: feature
priority: 2
---
# Extract musical key signatures from work titles into discrete field

## Overview
Extract musical key signatures from work title strings into a discrete `musicalKey` field on `WorkData`/`WorkInfo` for filtering, display, and search.

## Data Analysis
- **OpenOpus**: 5,043 works (20%) have key signatures in titles
- **Zerluth**: 1,329 works have German key notation (Dur/moll)

## Key Signature Patterns to Extract

### English Notation
| Pattern | Example | Count |
|---------|---------|-------|
| in X major | 'in F major' | 2,938 |
| in X minor | 'in B minor' | 2,104 |
| in X-flat major/minor | 'in B-flat major' | rare |
| in X-sharp major/minor | 'in F-sharp minor' | rare |

### German Notation (Zerluth)
| Pattern | Example | Count |
|---------|---------|-------|
| X-Dur | 'G-Dur', 'Es-Dur' | 980 |
| X-moll | 'c-moll', 'fis-moll' | 349 |

## Normalized Output Format
Store in standardized format: `{note}{accidental} {mode}`
- Examples: 'G major', 'C minor', 'F# minor', 'Bb major'

## German to English Mapping
| German | English |
|--------|---------|
| -Dur | major |
| -moll | minor |
| -is | # (sharp) |
| -es | b (flat) |
| H | B |
| B | Bb |

## Implementation Tasks
1. Add `musicalKey` field to `WorkData` class
2. Add `musicalKey` field to `WorkInfo` class
3. Create `KeySignatureExtractor` utility with regex patterns
4. Handle German notation conversion (Dur→major, moll→minor, is→#, es→b)
5. Apply extraction in `WorkData.fromJson()`
6. Update UI to display key signature
7. Add key to search/filter options

## Acceptance Criteria
- [ ] Works display their key signature when available
- [ ] German and English notations both parsed correctly
- [ ] Keys normalized to consistent format
- [ ] Filtering by key works in search


