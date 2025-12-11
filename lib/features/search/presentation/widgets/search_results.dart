import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Widget to display search results.
class SearchResults extends StatelessWidget {
  final List<SheetMusic> results;
  final String query;
  final Function(SheetMusic) onSheetTap;
  final bool isLoading;
  final String? errorMessage;

  const SearchResults({
    super.key,
    required this.results,
    required this.query,
    required this.onSheetTap,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different search terms or filters',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final sheet = results[index];
        return SearchResultTile(
          sheet: sheet,
          onTap: () => onSheetTap(sheet),
        );
      },
    );
  }
}

/// Individual search result tile.
class SearchResultTile extends StatelessWidget {
  final SheetMusic sheet;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.sheet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: sheet.imageUrls.isNotEmpty
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
              child: Image.file(
                File(sheet.imageUrls.first),
                fit: BoxFit.cover,
              ),
            )
           : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.music_note),
            ),
      title: Text(
        sheet.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        sheet.composer,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
