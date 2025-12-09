import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/add_sheet_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/sheet_detail_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/desktop_layout.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/empty_library_placeholder.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/sheet_music_list_item.dart';

/// Desktop-optimized home page with side-by-side layout.
class HomePageDesktop extends StatefulWidget {
  const HomePageDesktop({super.key});

  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  int? _selectedSheetMusicId;
  bool _showAddForm = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop();

    if (!isDesktop) {
      // Fallback to mobile layout if not on desktop
      return _buildMobileLayout();
    }

    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadSheetMusic(),
      child: Scaffold(
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
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showAddForm = true;
                  _selectedSheetMusicId = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial || state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HomeError) {
              return _buildErrorView(context, state);
            } else if (state is HomeLoaded) {
              return _buildDesktopView(context, state);
            }

            return const Center(
              child: Text('Unknown state'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context, HomeLoaded state) {
    if (state.sheetMusicList.isEmpty) {
      return Center(
        child: EmptyLibraryPlaceholder(
          onAddPressed: () {
            setState(() {
              _showAddForm = true;
              _selectedSheetMusicId = null;
            });
          },
        ),
      );
    }

    // Build list panel
    final listPanel = RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.sheetMusicList.length,
        itemBuilder: (context, index) {
          final sheetMusic = state.sheetMusicList[index];
          final isSelected = _selectedSheetMusicId == sheetMusic.id;

          return Container(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            child: SheetMusicListItem(
              sheetMusic: sheetMusic,
              onTap: () {
                setState(() {
                  _selectedSheetMusicId = sheetMusic.id;
                  _showAddForm = false;
                });
              },
            ),
          );
        },
      ),
    );

    // Build detail panel
    Widget? detailPanel;
    if (_showAddForm) {
      detailPanel = AddSheetPage(
        onSuccess: () {
          context.read<HomeCubit>().refresh();
          setState(() {
            _showAddForm = false;
            _selectedSheetMusicId = null;
          });
        },
        onClose: () {
          setState(() {
            _showAddForm = false;
          });
        },
      );
    } else if (_selectedSheetMusicId != null) {
      detailPanel = SheetDetailPage(
        sheetMusicId: _selectedSheetMusicId!,
        onClose: () {
          setState(() {
            _selectedSheetMusicId = null;
          });
        },
      );
    }

    return DesktopLayout(
      listPanel: listPanel,
      detailPanel: detailPanel,
      showDetailPanel: _showAddForm || _selectedSheetMusicId != null,
      onDetailClose: () {
        setState(() {
          _selectedSheetMusicId = null;
          _showAddForm = false;
        });
      },
      listPanelWidthRatio: 0.35,
    );
  }

  Widget _buildErrorView(BuildContext context, HomeError state) {
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
              state.failure.toString(),
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
  }

  Widget _buildMobileLayout() {
    // For mobile, redirect to the original mobile home page
    return const SizedBox.shrink();
  }
}
