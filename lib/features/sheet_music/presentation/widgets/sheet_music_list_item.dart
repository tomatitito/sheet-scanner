import 'package:flutter/material.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Displays a single sheet music item in the library
class SheetMusicListItem extends StatelessWidget {
  final SheetMusic sheetMusic;
  final VoidCallback? onTap;

  /// Whether this item is in selection mode
  final bool isSelectionMode;

  /// Whether this item is currently selected (only used in selection mode)
  final bool isSelected;

  /// Callback when selection checkbox is toggled (only in selection mode)
  final ValueChanged<bool>? onSelectionChanged;

  const SheetMusicListItem({
    super.key,
    required this.sheetMusic,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged?.call(value ?? false),
            )
          : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.blue.shade700,
              ),
            ),
      title: Text(
        sheetMusic.title,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Composer: ${sheetMusic.composer}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (sheetMusic.tags.isNotEmpty)
            Text(
              'Tags: ${sheetMusic.tags.join(', ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
        ],
      ),
      trailing: isSelectionMode
          ? null
          : Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
      onTap:
          isSelectionMode ? () => onSelectionChanged?.call(!isSelected) : onTap,
    );
  }
}
