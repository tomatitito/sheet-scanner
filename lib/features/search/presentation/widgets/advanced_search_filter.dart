import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_cubit.dart';

/// Advanced search filter widget for multi-criteria search.
class AdvancedSearchFilter extends StatefulWidget {
  final List<String> availableTags;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClose;

  const AdvancedSearchFilter({
    Key? key,
    required this.availableTags,
    required this.onApply,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  late TextEditingController _queryController;
  late TextEditingController _composerController;
  final Set<String> _selectedTags = {};
  String _sortBy = 'createdAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _composerController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = {
      'query': _queryController.text,
      'composer': _composerController.text,
      'tags': _selectedTags.toList(),
      'sortBy': _sortBy,
      'descending': _sortDescending,
    };

    // For now, use simple search with composer filtering
    if (_queryController.text.isNotEmpty) {
      context.read<SearchCubit>().search(_queryController.text);
    } else {
      context.read<SearchCubit>().clearSearch();
    }

    widget.onApply(filters);
  }

  void _reset() {
    _queryController.clear();
    _composerController.clear();
    _selectedTags.clear();
    _sortBy = 'createdAt';
    _sortDescending = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Search',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Query field
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Search Query',
                hintText: 'Search title, composer, notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Composer filter
            TextField(
              controller: _composerController,
              decoration: InputDecoration(
                labelText: 'Composer',
                hintText: 'Filter by composer...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            if (widget.availableTags.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Sort options
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'createdAt', child: Text('Date Created')),
                      DropdownMenuItem(value: 'title', child: Text('Title')),
                      DropdownMenuItem(value: 'composer', child: Text('Composer')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortBy = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  ),
                  onPressed: () {
                    setState(() => _sortDescending = !_sortDescending);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
