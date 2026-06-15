---
id: sheet-scanner-1qs
status: closed
deps: []
links: []
created: 2025-12-13T09:52:47.202534+01:00
type: bug
priority: 2
---
# P2: Image.asset used for file:// paths in browse grid

BrowsePage grid card (browse_page.dart:436-439) uses Image.asset() to load sheet music images, but imageUrls contain file paths not asset paths.

Image.asset() is for bundled assets (images shipped with app).
For user photos/files, should use Image.file(File(path)) or Image.network() for URLs.

This causes images to never load, user only sees placeholder icon.

File: lib/features/sheet_music/presentation/pages/browse_page.dart:436-439


