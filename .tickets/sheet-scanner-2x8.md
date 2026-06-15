---
id: sheet-scanner-2x8
status: closed
deps: []
links: []
created: 2025-12-13T09:52:06.237711+01:00
type: bug
priority: 2
---
# Failure.toString() exposes technical details instead of user-friendly messages

In lib/core/error/failures.dart:18-20, Failure.toString() returns:
'Failure: $message${code != null ? ' (code: $code)' : ''}'

This technical format is used directly in UI error displays:
- lib/features/sheet_music/presentation/pages/home_page.dart:84 shows state.failure.toString()
- lib/features/sheet_music/presentation/pages/add_sheet_page.dart:71 shows state.failure.toString()

Users see technical error messages like 'Failure: Database error (code: DB_001)' instead of friendly messages like 'Unable to load your library. Please try again.'

Impact: Poor UX - users see confusing technical errors instead of helpful guidance.

Fix: 
1. Add a .userMessage getter to Failure that returns friendly text
2. Update UI to use failure.userMessage instead of failure.toString()
3. Keep toString() for logging/debugging


