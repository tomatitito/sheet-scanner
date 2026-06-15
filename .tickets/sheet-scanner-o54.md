---
id: sheet-scanner-o54
status: closed
deps: []
links: []
created: 2025-12-13T09:52:07.334562+01:00
type: bug
priority: 2
---
# No loading states during refresh operations

In multiple pages, refresh operations don't show loading indicators:

Example in lib/features/sheet_music/presentation/pages/home_page.dart:119-120:
RefreshIndicator(
  onRefresh: () => context.read<HomeCubit>().refresh(),

The HomeCubit.refresh() method (home_cubit.dart:31) calls loadSheetMusic() which emits HomeLoading, but the UI doesn't distinguish between initial loading and refresh loading. During refresh, the HomeLoading state replaces the current data with a loading spinner, making the entire list disappear.

Impact: Poor UX - content flash/flicker during refresh, user loses context.

Fix: Add separate RefreshLoading state or use a bool flag in HomeLoaded to show a non-intrusive loading indicator during refresh.


