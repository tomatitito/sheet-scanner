---
id: sheet-scanner-ns3
status: closed
deps: []
links: []
created: 2025-12-13T09:52:25.622381+01:00
type: task
priority: 2
---
# P2: Settings page features not implemented - theme, FTS5 toggle, licenses

The SettingsPage has three features that are marked as TODO and not implemented:

1. Line 41: Theme selection - onChanged callback has TODO comment
2. Line 82: FTS5 toggle - onChanged callback has TODO comment  
3. Line 111: License viewer - onPressed callback has TODO comment

Current behavior: UI controls are displayed but do nothing when interacted with

These should either be:
- Implemented with proper functionality
- Removed/hidden until ready to implement
- Disabled with explanatory text

File: lib/features/settings/presentation/pages/settings_page.dart:41,82,111
Impact: Confusing UX - buttons/toggles appear functional but don't work


