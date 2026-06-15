---
id: sheet-scanner-6u5
status: closed
deps: []
links: []
created: 2025-12-13T09:52:47.368939+01:00
type: bug
priority: 2
---
# P2: GridView rebuilds on every search keystroke

BrowsePage (browse_page.dart:164-189) calls browseCubit.search() on every TextField onChanged event without debouncing.

User typing 'Beethoven' = 9 search operations, each:
- Triggers BlocBuilder rebuild
- Filters entire sheet list
- Rebuilds entire GridView
- Recreates all grid cards

With 1000+ sheets, causes laggy typing experience.

Should debounce search input (300-500ms delay) before triggering search.

File: lib/features/sheet_music/presentation/pages/browse_page.dart:166


