---
id: sheet-scanner-tja
status: closed
deps: []
links: []
created: 2025-12-13T09:50:04.277647+01:00
type: bug
priority: 0
---
# P0: Navigation bug - AddSheetPage loses form state when scanning

When user is filling out the AddSheetPage form and clicks 'Scan Sheet Music' button (line 323), they navigate to /scan using context.push('/scan'). After completing the scan flow (scan → OCR review → cancel/back), the user returns to AddSheetPage but ALL their form data (title, composer, notes, tags) is lost.

Expected: Form state should be preserved when returning from scan flow
Actual: All fields are cleared, user must re-enter everything

File: lib/features/sheet_music/presentation/pages/add_sheet_page.dart:323
Root cause: Using context.push() creates a new route which doesn't preserve parent widget state
Impact: Critical UX issue - users lose work when using scan feature from add sheet page


