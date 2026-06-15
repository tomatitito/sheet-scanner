---
id: sheet-scanner-d8g
status: closed
deps: []
links: []
created: 2025-12-13T09:52:37.352039+01:00
type: bug
priority: 2
---
# Database connection not properly initialized or managed

In lib/core/di/injection.dart:57, AppDatabase is registered as a singleton with just:
getIt.registerSingleton<AppDatabase>(AppDatabase());

Issues:
1. No error handling if database initialization fails
2. No verification that database is ready before use
3. Comment says 'LazyDatabase will initialize on first use' but there's no explicit initialization
4. No database migration strategy visible
5. No cleanup/close on app shutdown

Impact:
- Potential crashes if database init fails
- Race conditions on first access
- Database corruption if not closed properly
- Difficult to handle database errors

Fix:
1. Add async database initialization
2. Verify database is ready before registering
3. Add proper error handling
4. Implement shutdown hook to close database


