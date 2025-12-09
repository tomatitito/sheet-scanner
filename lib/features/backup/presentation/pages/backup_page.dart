import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/backup/presentation/cubit/backup_cubit.dart';
import 'package:sheet_scanner/features/backup/presentation/cubit/backup_state.dart';

/// Main page for backup/export operations
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Export'),
      ),
      body: BlocListener<BackupCubit, BackupState>(
        listener: (context, state) {
          state.whenOrNull(
            exportSuccess: (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export successful!\nFormat: ${result.format}\nPath: ${result.filePath}',
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            error: (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        child: BlocBuilder<BackupCubit, BackupState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Export Options',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _ExportButton(
                    label: 'Export Database',
                    description: 'Export the complete database as .db file',
                    isLoading: state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ),
                    onPressed: () {
                      context.read<BackupCubit>().exportDatabase();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ExportButton(
                    label: 'Export as JSON',
                    description: 'Export metadata as JSON (metadata only)',
                    isLoading: state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ),
                    onPressed: () {
                      context.read<BackupCubit>().exportToJson();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ExportButton(
                    label: 'Export as ZIP',
                    description: 'Export database and images as ZIP archive',
                    isLoading: state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ),
                    onPressed: () {
                      context.read<BackupCubit>().exportToZip();
                    },
                  ),
                  const SizedBox(height: 32),
                  state.maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper widget for export buttons
class _ExportButton extends StatelessWidget {
  final String label;
  final String description;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.description,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Export ${label.toLowerCase()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
