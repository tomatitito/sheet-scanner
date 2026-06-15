---
id: sheet-scanner-9el
status: closed
deps: []
links: []
created: 2025-12-13T09:50:59.522287+01:00
type: task
priority: 2
---
# P2: Add missing page routes to app_router.dart

Several page files exist in the codebase but are not registered as routes in app_router.dart. They are accessed via imperative navigation (Navigator.push) instead of declarative routing (GoRouter).

Missing routes:
1. sheet_detail_page.dart - Accessed via Navigator.push from browse/home pages
2. edit_sheet_page.dart - Accessed via Navigator.push from sheet detail page
3. advanced_search_page.dart - May not be used anywhere yet

These should be added to GoRouter configuration with proper parameter handling:

Example:
GoRoute(
  path: '/sheet/:id',
  name: 'sheet-detail',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return SheetDetailPage(sheetMusicId: id);
  },
),

Benefits:
- Consistent navigation pattern throughout app
- Deep linking support
- Better back button handling
- Easier testing

Related to: sheet-scanner-tcg (mixed navigation paradigms)

Files:
- lib/core/router/app_router.dart
- lib/features/sheet_music/presentation/pages/sheet_detail_page.dart
- lib/features/sheet_music/presentation/pages/edit_sheet_page.dart
- lib/features/search/presentation/pages/advanced_search_page.dart


