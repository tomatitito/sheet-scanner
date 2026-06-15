---
id: sheet-scanner-bfw
status: closed
deps: []
links: []
created: 2025-12-13T09:50:42.183654+01:00
type: bug
priority: 2
---
# P2: SearchBarWidget debounce uses Future instead of Timer

SearchBarWidget implements search debouncing using Future.delayed instead of a proper Timer. This can cause issues with cancellation and memory management.

Current implementation (lines 22, 38, 45):
Future<void>? _debounceTimer;  // Should be Timer?
_debounceTimer?.ignore();       // ignore() doesn't cancel the Future
_debounceTimer = Future.delayed(widget.debounceDelay, () { ... });

Problems:
1. Future.ignore() doesn't actually cancel the delayed callback
2. If user types quickly, multiple callbacks could execute
3. Memory leak potential from uncancelled futures
4. Misleading variable name

Recommendation: Use dart:async Timer with timer.cancel()

File: lib/features/search/presentation/widgets/search_bar.dart:22,38,45
Impact: Potential race conditions and memory issues


