---
id: sheet-scanner-y0s
status: closed
deps: []
links: []
created: 2025-12-13T09:50:21.327574+01:00
type: bug
priority: 1
---
# P1: SheetDetailPage retry button doesn't work

In SheetDetailPage, when the sheet music fails to load (SheetDetailError state), a 'Retry' button is shown at line 111-122. However, clicking this button shows a SnackBar saying 'Unable to retry - ID unknown' instead of actually retrying.

The comment on line 113-114 says: 'Cannot retry without knowing the ID - this shouldn't happen as error is shown when loading fails'

Problem: The retry button is enabled but doesn't have access to the sheetMusicId to call loadSheetMusic() again. This is poor UX.

Solutions:
1. Store the sheetMusicId in the cubit so retry can use it
2. Disable the retry button if ID is unavailable
3. Pass the ID through the error state

Expected: Retry button should reload the sheet music
Actual: Retry button shows error message

File: lib/features/sheet_music/presentation/pages/sheet_detail_page.dart:111-122
Impact: Users can't recover from temporary load failures


