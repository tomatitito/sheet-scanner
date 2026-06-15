---
id: sheet-scanner-cuh
status: closed
deps: []
links: []
created: 2025-12-13T09:51:36.259705+01:00
type: bug
priority: 1
---
# P1: Confusing navigation stack with modal sheets and GoRouter

HomePage displays AddSheetPage and SheetDetailPage using showModalBottomSheet (lines 105-114, 129-136, 151-160). However, AddSheetPage has a 'Scan Sheet Music' button that uses context.push('/scan'), which creates a confusing navigation stack.

Flow:
1. User on HomePage
2. Taps FAB → AddSheetPage shown as modal bottom sheet
3. User taps 'Scan Sheet Music' → context.push('/scan') pushes scan page
4. Now the modal sheet is still open underneath the scan page
5. Back navigation becomes confusing (modal + routes mixed)

Problems:
- Modal presentation mixed with declarative routing
- User can't see the modal is still open behind scan page
- Back button behavior is unpredictable
- On some platforms, dismissing the scan page might leave the modal orphaned

Additional issue: Lines 112, 134, 158 use Navigator.pop(context) to close modals, but if context.push() was used inside, Navigator.pop might not work correctly.

Solutions:
1. Don't show forms in modals - navigate to full pages instead
2. OR close modal before navigating to scan (but then lose form state)
3. OR use a multi-step wizard within the modal (no GoRouter navigation)

Files:
- lib/features/sheet_music/presentation/pages/home_page.dart:105-160
- lib/features/sheet_music/presentation/pages/add_sheet_page.dart:323

Related: sheet-scanner-tcg, sheet-scanner-tja


