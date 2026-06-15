---
id: sheet-scanner-oaz
status: closed
deps: []
links: []
created: 2025-12-13T09:50:41.189693+01:00
type: bug
priority: 0
---
# P0: Singleton cubits cause stale state across navigations

All cubits are registered as singletons in DI container (injection.dart:233-314), but this causes stale state when navigating between pages.

Example bug flow:
1. User visits HomePage → HomeCubit loads 10 items
2. User navigates to BrowsePage  
3. User adds new item via AddSheetPage → now 11 items in DB
4. User navigates back to HomePage → SAME HomeCubit instance still has cached 10 items

Root cause: getIt.registerSingleton means ONE instance is shared across all usages. When BlocProvider.create calls getIt<HomeCubit>(), it gets the same instance with stale cached state.

Solution: Change to registerFactory() for all cubits, OR implement proper state refresh on page resume.

Files affected:
- lib/core/di/injection.dart:233-314 (all cubit registrations)
- All pages using BlocProvider.create with getIt

Impact: Data inconsistency across the app, users won't see latest changes after navigation.


