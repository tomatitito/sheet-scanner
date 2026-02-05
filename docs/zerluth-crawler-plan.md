# Zerluth.de Crawler Plan

## Overview

This document captures the research and planning for crawling sheet music data from [zerluth.de](https://www.zerluth.de) to enrich the sheet-scanner app with:
- **Schwierigkeitsgrad (Difficulty Level)** - 1-5 scale
- **Besetzung (Instrumentation)** - e.g., "Fl,Pno", "Zwei Flöten"
- **Epoche (Era)** - derived from composition year or composer's era

---

## Data Source

### URL
```
https://www.zerluth.de/index.php?section=advancedsearch&Warengruppe=Fl%F6te
```

### Total Dataset
- **17,325 items** in the Flöte (flute) category
- **35 pages** at 500 items per page
- All items accessible via empty search (no filters)

---

## Technical Findings

### Authentication & Session
- **Session-based search** - requires cookies to maintain state
- **No login required** - public data
- **Cookie persistence** needed between requests

### API Endpoints

#### 1. Initiate Search (POST)
```bash
curl -L -c cookies.txt -b cookies.txt -X POST \
  "https://www.zerluth.de/index.php?action=search" \
  -d "db=Datenbank+Zerluth&Versender_Warengruppe=FLOETE&titelzahl_pro_seite=500"
```

#### 2. Paginated Results (GET)
```bash
curl -b cookies.txt \
  "https://www.zerluth.de/index.php?action=showresult&page=1&db=Datenbank+Zerluth"
```

Pages: 1-35

### HTML Structure

Each item is in a `<div id="art_*XXXXXX">` container:

```html
<div id="art_*000258983">
  <div class="artikeluebersicht">
    <div class="artikel">

      <!-- Image section -->
      <div class="artikelimage">...</div>

      <!-- Text section -->
      <div class="artikeltext">
        <strong class="link">Adams, Sally / Morley, Nigel (Arr/Hrsg)</strong>
        <article>Concert Repertoire</article>
        <b>Instrumentierung:</b>&nbsp;Fl,Pno<br>
        <b>Kategorie: </b>Alben (Flöte,Piano)
      </div>

      <!-- Price section with difficulty -->
      <div class="artikelpreis">
        <div class="ratings">
          <div class="ratings-tab">1</div>
          <div class="ratings-tab">2</div>
          <div class="ratings-tab activated">3</div>  <!-- activated = difficulty level -->
          <div class="ratings-tab">4</div>
          <div class="ratings-tab">5</div>
        </div>

        <!-- Hidden form fields with clean data -->
        <input name="cart_id" value="*000258983" type="hidden">
        <input name="cart_titel" value="Adams/Morley: Concert Repertoire" type="hidden">
        <input name="cart_autor" value="Adams, Sally / Morley, Nigel (Arr/Hrsg)" type="hidden">
      </div>

    </div>
  </div>
</div>
```

### Data Extraction Selectors

| Field | Selector/Method |
|-------|-----------------|
| **ID** | `div[id^="art_"]` → extract ID from attribute |
| **Composer** | `input[name="cart_autor"]` value, or `.artikeltext strong.link` |
| **Title** | `input[name="cart_titel"]` value (cleanest source) |
| **Difficulty** | `.ratings-tab.activated` text content (1-5, may be absent) |
| **Instrumentation** | Regex on `.artikeltext`: `/Instrumentierung:<\/b>&nbsp;\s*([^<]+)/` |
| **Category** | Regex on `.artikeltext`: `/Kategorie: <\/b>([^<]+)/` |

### Sample Extracted Data

```json
[
  {
    "id": "*000258983",
    "composer": "Adams, Sally / Morley, Nigel (Arr/Hrsg)",
    "title": "Adams/Morley: Concert Repertoire",
    "difficulty": 3,
    "instrumentation": "Fl,Pno",
    "category": "Alben (Flöte,Piano)"
  },
  {
    "id": "*000230744",
    "composer": "21 Maskentänze",
    "title": "Maskentänze: Englische Instrumentalmusik um 1600",
    "difficulty": 2,
    "instrumentation": "Fl,B.c.",
    "category": "Alben (Flöte,Piano)"
  }
]
```

---

## Besetzung (Instrumentation) Categories

The site offers ~70 instrumentation categories. Key ones:

| Code | German | English |
|------|--------|---------|
| RN800 | Flöte-Solo | Flute Solo |
| RN820 | Flöte,Piano | Flute & Piano |
| RN900 | Zwei Flöten | Two Flutes |
| RN920 | Drei Flöten | Three Flutes |
| RN1000 | Flöte,Gitarre | Flute & Guitar |
| RN1020 | Flöte,Violine | Flute & Violin |
| RN420 | Bläserquintett | Wind Quintet |
| RN730 | Ensemble Musik (flexible Besetzung) | Flexible Ensemble |

Full list available in the search form's `<select id="Besetungsselektor">`.

---

## Implementation Options

### Option 1: Dart Script (Recommended)

Create `tool/crawl_zerluth.dart`:

```dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = http.Client();
  final cookieJar = <String, String>{};

  // 1. Initiate search
  final searchResponse = await client.post(
    Uri.parse('https://www.zerluth.de/index.php?action=search'),
    body: {
      'db': 'Datenbank Zerluth',
      'Versender_Warengruppe': 'FLOETE',
      'titelzahl_pro_seite': '500',
    },
  );
  // Extract cookies from response...

  // 2. Crawl pages 1-35
  final allItems = <Map<String, dynamic>>[];

  for (var page = 1; page <= 35; page++) {
    print('Fetching page $page/35...');

    final response = await client.get(
      Uri.parse('https://www.zerluth.de/index.php?action=showresult&page=$page&db=Datenbank+Zerluth'),
      headers: {'Cookie': cookieJar.entries.map((e) => '${e.key}=${e.value}').join('; ')},
    );

    final document = html_parser.parse(response.body);
    final items = document.querySelectorAll('div[id^="art_"]');

    for (final item in items) {
      allItems.add(_extractItem(item));
    }

    // Be nice to the server
    await Future.delayed(Duration(milliseconds: 500));
  }

  // 3. Save to JSON
  final output = File('lib/data/sources/zerluth_flute.json');
  await output.writeAsString(JsonEncoder.withIndent('  ').convert(allItems));

  print('Saved ${allItems.length} items');
}

Map<String, dynamic> _extractItem(Element item) {
  // ... extraction logic
}
```

**Pros:**
- Native to project
- Fast (direct HTTP)
- Easy to integrate output

**Cons:**
- Cookie handling needs care

### Option 2: Python Script

```python
import requests
from bs4 import BeautifulSoup
import json
import time

session = requests.Session()

# Initiate search
session.post(
    'https://www.zerluth.de/index.php?action=search',
    data={
        'db': 'Datenbank Zerluth',
        'Versender_Warengruppe': 'FLOETE',
        'titelzahl_pro_seite': '500',
    }
)

all_items = []

for page in range(1, 36):
    print(f'Fetching page {page}/35...')

    response = session.get(
        f'https://www.zerluth.de/index.php?action=showresult&page={page}&db=Datenbank+Zerluth'
    )

    soup = BeautifulSoup(response.text, 'html.parser')

    for item in soup.select('div[id^="art_"]'):
        # Extract fields...
        pass

    time.sleep(0.5)

with open('zerluth_flute.json', 'w') as f:
    json.dump(all_items, f, indent=2, ensure_ascii=False)
```

### Option 3: Browser Automation (Playwright)

Use the web-browser skill to:
1. Navigate and submit search
2. Loop through pages
3. Extract via JavaScript

**Slower but handles edge cases.**

---

## App Changes Required

### 1. Data Model Updates

**`lib/features/sheet_music/domain/entities/sheet_music.dart`**

Add fields:
```dart
@freezed
class SheetMusic with _$SheetMusic {
  const factory SheetMusic({
    // ... existing fields ...
    int? difficulty,           // 1-5 scale
    String? instrumentation,   // e.g., "Fl,Pno"
    String? epoch,             // e.g., "Baroque", "Classical"
  }) = _SheetMusic;
}
```

### 2. Database Migration

**`lib/core/database/database.dart`**

Add columns:
```dart
// In sheet_music table
IntColumn get difficulty => integer().nullable()();
TextColumn get instrumentation => text().nullable()();
TextColumn get epoch => text().nullable()();
```

Increment schema version and add migration.

### 3. UI Updates

**Add/Edit forms:**
- Difficulty selector (1-5 visual scale like zerluth.de)
- Instrumentation dropdown or autocomplete
- Epoch dropdown (derived from composer or manual)

**List/Detail views:**
- Show difficulty badge
- Show instrumentation
- Filter by difficulty/instrumentation

### 4. Data Integration

Create new data source:
```
lib/data/sources/zerluth_flute.json
```

Update `ComposerDataSource` to:
1. Load zerluth data
2. Match with existing composers by name
3. Enrich works with difficulty/instrumentation

---

## Epoch Determination

Since zerluth.de doesn't provide epoch, derive it from:

1. **Composer's known epoch** (already in `KnownComposer` entity)
2. **Composition year** (if title contains year like "BWV 1080")
3. **Manual mapping** for common periods

### Epoch Categories
- Medieval (before 1400)
- Renaissance (1400-1600)
- Baroque (1600-1750)
- Classical (1750-1820)
- Romantic (1820-1900)
- 20th Century (1900-2000)
- Contemporary (2000+)

---

## Execution Checklist

- [ ] Create crawler script (`tool/crawl_zerluth.dart` or Python)
- [ ] Test on first page
- [ ] Run full crawl (expect ~30 min with delays)
- [ ] Review and clean data
- [ ] Add new fields to `SheetMusic` entity
- [ ] Create database migration
- [ ] Update add/edit forms with new fields
- [ ] Add difficulty/instrumentation display to list views
- [ ] Create filter options for new fields
- [ ] Integrate zerluth data with composer matching
- [ ] Test autocomplete with enriched data

---

## Notes

- **Rate limiting**: Use 500ms delay between requests to be respectful
- **Error handling**: Some items may lack difficulty or instrumentation
- **Composer name normalization**: zerluth uses "Lastname, Firstname" format
- **Data freshness**: Consider re-crawling periodically for new items

---

*Document created: 2026-02-05*
*Based on exploration of zerluth.de structure*
