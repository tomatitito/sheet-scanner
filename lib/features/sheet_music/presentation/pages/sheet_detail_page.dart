import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_detail_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_detail_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/edit_sheet_page.dart';

/// Page for displaying detailed view of a sheet music item
/// Can be shown as a modal or full page depending on platform
class SheetDetailPage extends StatelessWidget {
  final int sheetMusicId;
  final VoidCallback? onClose;

  const SheetDetailPage({
    super.key,
    required this.sheetMusicId,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SheetDetailCubit>()..loadSheetMusic(sheetMusicId),
      child: _SheetDetailView(onClose: onClose, sheetMusicId: sheetMusicId),
    );
  }
}

class _SheetDetailView extends StatelessWidget {
  final VoidCallback? onClose;
  final int sheetMusicId;

  const _SheetDetailView({
    this.onClose,
    required this.sheetMusicId,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocListener<SheetDetailCubit, SheetDetailState>(
      listener: (context, state) {
        if (state is SheetDetailDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sheet music deleted successfully'),
              duration: Duration(milliseconds: 1500),
            ),
          );
          // Return to previous screen after deletion
          context.pop(true);
        } else if (state is SheetDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.failure}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SheetDetailCubit, SheetDetailState>(
        builder: (context, state) {
          if (state is SheetDetailInitial || state is SheetDetailLoading) {
            return Scaffold(
              appBar: isMobile
                  ? AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => context.pop(),
                      ),
                      title: const Text('Loading...'),
                    )
                  : null,
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is SheetDetailError) {
            return Scaffold(
              appBar: isMobile
                  ? AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => context.pop(),
                      ),
                      title: const Text('Error'),
                    )
                  : null,
              body: Center(
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
                      'Failed to load sheet music',
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
                        // Retry loading the sheet music using the stored ID
                        context
                            .read<SheetDetailCubit>()
                            .loadSheetMusic(sheetMusicId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SheetDetailLoaded) {
            final sheetMusic = state.sheetMusic;
            return Scaffold(
              appBar: isMobile
                  ? AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => context.pop(),
                      ),
                      title: Text(
                        sheetMusic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : null,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with music note icon
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 64,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            sheetMusic.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Details section
                    _DetailSection(
                        label: 'Composer', value: sheetMusic.composer),

                    if (sheetMusic.notes != null &&
                        sheetMusic.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: _DetailSection(
                          label: 'Notes',
                          value: sheetMusic.notes!,
                        ),
                      ),

                    if (sheetMusic.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: sheetMusic.tags
                                  .map((tag) => Chip(label: Text(tag)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                    if (sheetMusic.imageUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Images',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: sheetMusic.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    // Metadata
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metadata',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created: ${sheetMusic.createdAt.toString().split('.')[0]}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Updated: ${sheetMusic.updatedAt.toString().split('.')[0]}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditSheetPage(
                                    sheetMusicId: sheetMusic.id,
                                    onSuccess: () {
                                      context
                                          .read<SheetDetailCubit>()
                                          .refresh(sheetMusic.id);
                                    },
                                    onClose: () => context.pop(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmationDialog(
                                context, sheetMusic.id),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Unknown state')),
          );
        },
      ),
    );
  }

  /// Show a confirmation dialog before deleting
  void _showDeleteConfirmationDialog(BuildContext context, int sheetMusicId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Sheet Music'),
        content: const Text(
          'Are you sure you want to delete this sheet music? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SheetDetailCubit>().deleteSheetMusic(sheetMusicId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for displaying detail fields
class _DetailSection extends StatelessWidget {
  final String label;
  final String value;

  const _DetailSection({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
