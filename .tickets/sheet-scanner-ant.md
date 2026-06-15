---
id: sheet-scanner-ant
status: closed
deps: []
links: []
created: 2025-12-13T09:51:30.873893+01:00
type: bug
priority: 1
---
# Add tag text field doesn't clear after adding tag in AddSheetPage

In lib/features/sheet_music/presentation/pages/add_sheet_page.dart:267-296, when a user enters a tag name and clicks 'Add', the tag is added to the list (line 131) but the TextField is not cleared.

The _addTag method sets _newTag = '' (line 291), but this doesn't clear the TextField because there's no controller for it. The TextField uses onChanged to track _newTag but has no controller to programmatically clear it.

Impact: Poor UX - user must manually clear the field before adding another tag.

Fix: Add a TextEditingController for the tag field and call controller.clear() in _addTag().


