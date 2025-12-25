import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/add_sheet_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/home_page_desktop.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/sheet_detail_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/empty_library_placeholder.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/sheet_music_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use desktop layout on desktop platforms
    if (PlatformHelper.isDesktop()) {
      return const HomePageDesktop();
    }

    // Use mobile layout on mobile platforms
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadSheetMusic(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheet Music Library'),
        elevation: 0,
        actions: [
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoaded && state.sheetMusicList.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${state.totalCount} items',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load library',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.failure.userMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeCubit>().refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is HomeLoaded) {
            if (state.sheetMusicList.isEmpty) {
              return EmptyLibraryPlaceholder(
                onAddPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => AddSheetPage(
                      onSuccess: () {
                        context.read<HomeCubit>().refresh();
                      },
                      onClose: () => context.pop(),
                    ),
                  );
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.sheetMusicList.length,
                itemBuilder: (context, index) {
                  final sheetMusic = state.sheetMusicList[index];
                  return SheetMusicListItem(
                    sheetMusic: sheetMusic,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => SheetDetailPage(
                          sheetMusicId: sheetMusic.id,
                          onClose: () => context.pop(),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddSheetPage(
              onSuccess: () {
                context.read<HomeCubit>().refresh();
              },
              onClose: () => context.pop(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
