---
id: sheet-scanner-zro
status: closed
deps: []
links: []
created: 2025-12-13T09:51:03.037215+01:00
type: bug
priority: 1
---
# Global keyboard shortcuts are non-functional dead code

In lib/main.dart:46-68, _handleGlobalShortcut() handles keyboard shortcuts but all cases are either empty or incomplete:
- saveAction (line 49): Empty - comment says 'will be handled by specific Cubits' but no implementation
- newItemAction (line 54): Empty - comment says 'navigate or trigger add dialog' but no implementation
- searchAction (line 57): Empty - comment says 'Open search/filter' but no implementation  
- escapeAction (line 60-64): Uses legacy Navigator.pop instead of go_router

This creates the illusion of keyboard support without actual functionality.

Impact: Misleading code, keyboard shortcuts don't work, wasted CPU cycles.

Fix: Either implement the shortcuts properly or remove the dead code.


