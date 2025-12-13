import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/utils/platform_helper.dart';

/// Desktop-optimized file picker with visual enhancements.
/// Provides better UX for file selection with drag-drop area visualization
/// and file size/type validation feedback.
class FilePickerDropZone extends StatefulWidget {
  final List<String> selectedFiles;
  final VoidCallback onPickFiles;
  final Function(String) onRemoveFile;
  final bool isSubmitting;

  const FilePickerDropZone({
    super.key,
    required this.selectedFiles,
    required this.onPickFiles,
    required this.onRemoveFile,
    this.isSubmitting = false,
  });

  @override
  State<FilePickerDropZone> createState() => _FilePickerDropZoneState();
}

class _FilePickerDropZoneState extends State<FilePickerDropZone> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // File picker area
        _buildPickerArea(context, isDesktop),
        const SizedBox(height: 16),
        // Selected files list
        if (widget.selectedFiles.isNotEmpty) _buildSelectedFilesList(context),
      ],
    );
  }

  Widget _buildPickerArea(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withValues(alpha: 0.02),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDesktop ? Icons.cloud_upload_outlined : Icons.folder_open,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isDesktop
                  ? 'Drag files here or select below'
                  : 'Select files from your device',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Supported: PDF, JPG, PNG, GIF',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: widget.isSubmitting ? null : widget.onPickFiles,
              icon: const Icon(Icons.folder_open),
              label: Text(isDesktop ? 'Select Files...' : 'Choose Files'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Files (${widget.selectedFiles.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.selectedFiles.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, index) {
              final filePath = widget.selectedFiles[index];
              final fileName = filePath.split('/').last;
              final fileSize = _getFileSize(filePath);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: _getFileIcon(fileName),
                title: Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  fileSize,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: widget.isSubmitting
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Remove file',
                        onPressed: () => widget.onRemoveFile(filePath),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final size = file.lengthSync();
      if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return Icon(Icons.picture_as_pdf, color: Colors.red[400]);
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return Icon(Icons.image, color: Colors.blue[400]);
    }
    return const Icon(Icons.insert_drive_file);
  }
}
