---
id: sheet-scanner-tcg
status: closed
deps: []
links: []
created: 2025-12-13T09:50:12.71713+01:00
type: bug
priority: 1
---
# P1: Mixed navigation paradigms causing inconsistent behavior

The app uses both GoRouter (declarative navigation with context.push/pop) and Navigator (imperative navigation with Navigator.push/pop) throughout the codebase. This creates inconsistent back button behavior and navigation stack issues.

Examples:
- SheetDetailPage line 298-311: Uses Navigator.push with MaterialPageRoute
- EditSheetPage line 127: Uses Navigator.pop
- OCRReviewPage line 142: Uses Navigator.pop
- AddSheetPage line 323: Uses context.push (GoRouter)

Problem: When mixing paradigms, the back button behavior becomes unpredictable, navigation stacks can get corrupted, and deep linking breaks.

Solution: Standardize on GoRouter throughout the app. All pages should be registered as routes and use context.push/pop/go consistently.

Files affected:
- lib/features/sheet_music/presentation/pages/sheet_detail_page.dart
- lib/features/sheet_music/presentation/pages/edit_sheet_page.dart  
- lib/features/sheet_music/presentation/pages/ocr_review_page.dart
- lib/core/router/app_router.dart (missing route registrations)


