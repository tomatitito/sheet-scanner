---
id: sheet-scanner-cos
status: closed
deps: []
links: []
created: 2025-12-13T09:50:48.903784+01:00
type: task
priority: 2
---
# P2: Mixed navigation APIs (Navigator vs GoRouter)

Codebase mixes Navigator.pop() and context.pop() inconsistently, which can cause navigation bugs in GoRouter apps.

Examples:
- ocr_review_page.dart:142,244 uses Navigator.pop()  
- ocr_review_wrapper.dart:32,38 uses context.pop()
- browse_page.dart:140,142,355,357,404 uses Navigator.pop()

When using GoRouter, should consistently use context.pop()/push()/go() instead of Navigator API.

Impact: Inconsistent navigation behavior, potential back stack corruption.
Recommendation: Standardize on GoRouter API throughout codebase.


