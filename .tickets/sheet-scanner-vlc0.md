---
id: sheet-scanner-vlc0
status: open
deps: []
links: []
created: 2026-02-21T09:20:17.621798+01:00
type: epic
priority: 2
---
# Structured metadata extraction from work titles

## Epic Overview
Extract structured metadata (opus/catalog numbers, musical keys) from free-text work titles into discrete, queryable fields.

## Background
Work titles from OpenOpus and Zerluth contain valuable metadata embedded in the text:
- **Catalog numbers**: 'Piano Concerto No. 21, K.467' → K.467
- **Musical keys**: 'Symphony No. 40 in G minor' → G minor

Currently this data is only available as unstructured text, limiting search and filtering capabilities.

## Goals
1. Parse and extract catalog numbers into `catalogNumber` field
2. Parse and extract key signatures into `musicalKey` field
3. Enable filtering/searching by these fields
4. Display extracted metadata in the UI

## Data Coverage
| Field | OpenOpus | Zerluth | Total |
|-------|----------|---------|-------|
| Catalog numbers | 10,941 (43%) | 2,200+ | ~13,000 |
| Key signatures | 5,043 (20%) | 1,329 | ~6,300 |

## Child Issues
- sheet-scanner-ve5: Extract opus/catalog numbers
- sheet-scanner-dsjb: Extract musical key signatures

## Technical Approach
Create reusable extractor utilities in `lib/data/extractors/`:
- `catalog_number_extractor.dart`
- `key_signature_extractor.dart`

Apply extraction during data loading in `WorkData.fromJson()` so all consumers benefit automatically.


