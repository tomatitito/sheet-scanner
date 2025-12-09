import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/add_sheet_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/browse_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/sheet_detail_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/desktop_sidebar.dart';

/// Desktop-optimized browse/library page with sidebar navigation
class BrowsePageDesktop extends StatefulWidget {
  const BrowsePageDesktop({super.key});

  @override
  State<BrowsePageDesktop> createState() => _BrowsePageDesktopState();
}

class _BrowsePageDesktopState extends State<BrowsePageDesktop> {
  final _searchController = TextEditingController();
  int? _selectedSheetMusicId;
  bool _showAddForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateTo(SidebarNavItem item) {
    context.pushNamed(item.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop();

    if (!isDesktop) {
      // Fallback to mobile version if not on desktop
      return const BrowsePage();
    }

    return BlocProvider(
      create: (context) => getIt<BrowseCubit>()..loadSheetMusic(),
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar navigation
            DesktopSidebar(
              items: const [
                SidebarNavItem(
                  label: 'Home',
                  icon: Icons.home,
                  routeName: 'home',
                  tooltip: 'Go to home',
                ),
                SidebarNavItem(
                  label: 'Browse',
                  icon: Icons.library_music,
                  routeName: 'browse',
                  tooltip: 'Browse library',
                ),
                SidebarNavItem(
                  label: 'Scan',
                  icon: Icons.camera,
                  routeName: 'scan',
                  tooltip: 'Scan sheet music',
                ),
              ],
              currentRoute: 'browse',
              onItemTapped: _navigateTo,
            ),
            // Main content area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Browse Library'),
                  elevation: 0,
                  actions: [
                    BlocBuilder<BrowseCubit, BrowseState>(
                      builder: (context, state) {
                        if (state is BrowseLoaded && state.sheets.isNotEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '${state.filteredSheets.length}/${state.sheets.length}',
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
                body: BlocBuilder<BrowseCubit, BrowseState>(
                  builder: (context, state) {
                    if (state is BrowseInitial || state is BrowseLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is BrowseError) {
                      return _buildErrorView(context, state);
                    } else if (state is BrowseLoaded) {
                      return _buildDesktopBrowseView(context, state);
                    }

                    return const Center(
                      child: Text('Unknown state'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBrowseView(BuildContext context, BrowseLoaded state) {
    final browseCubit = context.read<BrowseCubit>();

    if (state.sheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No sheet music yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your inventory',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left side: List with search/filter
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          browseCubit.search(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search titles, composers...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    browseCubit.search('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: state.selectedTags.isEmpty,
                              onSelected: (_) {
                                browseCubit.filterByTags([]);
                              },
                            ),
                            const SizedBox(width: 8),
                            ...browseCubit.getAllTags().take(4).map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FilterChip(
                                      label: Text(tag),
                                      selected:
                                          state.selectedTags.contains(tag),
                                      onSelected: (_) {
                                        final newTags = List<String>.from(
                                            state.selectedTags);
                                        if (newTags.contains(tag)) {
                                          newTags.remove(tag);
                                        } else {
                                          newTags.add(tag);
                                        }
                                        browseCubit.filterByTags(newTags);
                                      },
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // List of sheets
                Expanded(
                  child: state.filteredSheets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => browseCubit.refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.filteredSheets.length,
                            itemBuilder: (context, index) {
                              final sheet = state.filteredSheets[index];
                              final isSelected =
                                  _selectedSheetMusicId == sheet.id;

                              return Container(
                                color: isSelected
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                child: ListTile(
                                  title: Text(sheet.title),
                                  subtitle: Text(sheet.composer),
                                  onTap: () {
                                    setState(() {
                                      _selectedSheetMusicId = sheet.id;
                                      _showAddForm = false;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        // Right side: Detail panel
        Expanded(
          child: _buildDetailPanel(context, state),
        ),
      ],
    );
  }

  Widget _buildDetailPanel(BuildContext context, BrowseLoaded state) {
    if (_showAddForm) {
      return AddSheetPage(
        onSuccess: () {
          context.read<BrowseCubit>().refresh();
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
      return SheetDetailPage(
        sheetMusicId: _selectedSheetMusicId!,
        onClose: () {
          setState(() {
            _selectedSheetMusicId = null;
          });
        },
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.select_all,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a sheet music to view details',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BrowseError state) {
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<BrowseCubit>().refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
