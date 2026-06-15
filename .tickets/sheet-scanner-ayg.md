---
id: sheet-scanner-ayg
status: closed
deps: []
links: []
created: 2025-12-13T09:52:08.425579+01:00
type: bug
priority: 2
---
# No error handling for file picker failures

In lib/features/sheet_music/presentation/pages/add_sheet_page.dart:144-172, the _pickFiles() method has a try-catch but the error handling is minimal:

catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error selecting files: $e'),

This shows the raw exception message to users, which could be technical and unhelpful. Common file picker errors include:
- Permission denied
- File too large
- Unsupported file type
- Storage not available

Impact: Poor UX - users see technical errors and don't know how to fix the problem.

Fix: Parse common error types and show specific, actionable error messages.


