---
id: sheet-scanner-ws8
status: closed
deps: []
links: []
created: 2025-12-13T09:50:24.572896+01:00
type: bug
priority: 0
assignee: FuchsiaCastle
---
# Critical: All Cubits registered as singletons causing state contamination

In lib/core/di/injection.dart:232-316, all Cubits are registered using registerSingleton<>() instead of registerFactory<>(). This means all widget instances share the same Cubit instance, causing state contamination across different screens and preventing proper cleanup. Cubits should be registered as factories so each widget gets a fresh instance with clean state.

Example: HomeCubit at line 244 is registered as singleton, so multiple HomePage instances would share state.

Impact: Data corruption, memory leaks, unpredictable behavior when navigating between screens.

Fix: Change all getIt.registerSingleton<XxxCubit>() to getIt.registerFactory<XxxCubit>() for all 12 Cubits (lines 233-316).


