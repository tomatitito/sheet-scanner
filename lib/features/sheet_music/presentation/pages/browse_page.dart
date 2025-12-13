import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/add_sheet_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/sheet_detail_page.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BrowseCubit>()..loadSheetMusic(),
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatefulWidget {
  const _BrowseView();

  @override
  State<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<_BrowseView> {
  final _searchController = TextEditingController();
  late final _browseCubit = context.read<BrowseCubit>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
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
        ],
      ),
      body: BlocBuilder<BrowseCubit, BrowseState>(
        builder: (context, state) {
          if (state is BrowseInitial || state is BrowseLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is BrowseError) {
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
                      _browseCubit.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is BrowseLoaded) {
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddSheetPage(
                            onSuccess: () {
                              _browseCubit.refresh();
                              Navigator.pop(context);
                            },
                            onClose: () => Navigator.pop(context),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Sheet Music'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _browseCubit.refresh(),
              child: Column(
                children: [
                  // Search and filter section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _browseCubit.search(query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search titles, composers...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _browseCubit.search('');
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
                        // Filter chips and sort dropdown
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // All chip
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: FilterChip(
                                        label: const Text('All'),
                                        selected: state.selectedTags.isEmpty,
                                        onSelected: (_) {
                                          _browseCubit.filterByTags([]);
                                        },
                                      ),
                                    ),
                                    // Tag chips
                                    ..._browseCubit.getAllTags().take(5).map(
                                          (tag) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: FilterChip(
                                              label: Text(tag),
                                              selected: state.selectedTags
                                                  .contains(tag),
                                              onSelected: (_) {
                                                final newTags =
                                                    List<String>.from(
                                                  state.selectedTags,
                                                );
                                                if (newTags.contains(tag)) {
                                                  newTags.remove(tag);
                                                } else {
                                                  newTags.add(tag);
                                                }
                                                _browseCubit.filterByTags(
                                                  newTags,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sort dropdown
                            DropdownButton<String>(
                              value: state.sortBy,
                              items: const [
                                DropdownMenuItem(
                                  value: 'recent',
                                  child: Text('Recent'),
                                ),
                                DropdownMenuItem(
                                  value: 'oldest',
                                  child: Text('Oldest'),
                                ),
                                DropdownMenuItem(
                                  value: 'title',
                                  child: Text('Title'),
                                ),
                                DropdownMenuItem(
                                  value: 'composer',
                                  child: Text('Composer'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _browseCubit.sortBy(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Results info
                  if (state.searchQuery.isNotEmpty ||
                      state.selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            '${state.filteredSheets.length} results',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          if (state.searchQuery.isNotEmpty ||
                              state.selectedTags.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear filters'),
                              onPressed: () {
                                _searchController.clear();
                                _browseCubit.clearFilters();
                              },
                            ),
                        ],
                      ),
                    ),
                  // Sheet list
                  Expanded(
                    child: state.filteredSheets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different search terms or filters',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          )
                        : _buildGrid(
                            context,
                            state,
                            isMobile,
                          ),
                  ),
                ],
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
                _browseCubit.refresh();
                Navigator.pop(context);
              },
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    BrowseLoaded state,
    bool isMobile,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid columns based on screen width
    int columns = 1;
    if (screenWidth >= 600) {
      columns = 2;
    }
    if (screenWidth >= 900) {
      columns = 3;
    }
    if (screenWidth >= 1200) {
      columns = 4;
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: state.filteredSheets.length,
      itemBuilder: (context, index) {
        final sheetMusic = state.filteredSheets[index];
        return _SheetGridCard(
          sheetMusic: sheetMusic,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SheetDetailPage(
                sheetMusicId: sheetMusic.id,
                onClose: () => Navigator.pop(context),
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetGridCard extends StatelessWidget {
  final dynamic sheetMusic;
  final VoidCallback onTap;

  const _SheetGridCard({
    required this.sheetMusic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder or actual image
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: sheetMusic.imageUrls?.isNotEmpty ?? false
                    ? Image.asset(
                        sheetMusic.imageUrls.first,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.library_music,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sheetMusic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sheetMusic.composer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (sheetMusic.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: sheetMusic.tags
                          .take(2)
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
