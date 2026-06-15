---
id: sheet-scanner-25b
status: closed
deps: []
links: []
created: 2025-12-13T09:52:36.137401+01:00
type: task
priority: 2
---
# No image optimization or caching strategy for sheet music covers

The app captures and stores high-resolution images from the camera but has no optimization or caching strategy:

In scan_camera_page.dart:63, camera is initialized with ResolutionPreset.veryHigh, which can produce very large image files (5-10MB each).

Issues:
1. No image compression before storage
2. No thumbnail generation for list views
3. No image caching (images loaded from disk every time)
4. Large images slow down list scrolling and increase storage usage

Impact: 
- Poor performance in library list view
- Excessive storage usage
- Slow app startup
- Battery drain

Fix:
1. Compress images to reasonable size (e.g., 1920x1080 at 85% quality)
2. Generate thumbnails for list views
3. Implement image caching strategy
4. Consider using flutter_cache_manager


