import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_cubit.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_state.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_suggestion_cubit.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_suggestion_state.dart';
import 'package:sheet_scanner/features/search/presentation/widgets/advanced_search_filter.dart';
import 'package:sheet_scanner/features/search/presentation/widgets/search_results.dart';

/// Advanced search/filter modal page.
/// Provides multi-criteria search with filters for title, composer, tags, and sorting.
class AdvancedSearchPage extends StatelessWidget {
  const AdvancedSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter panel
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: BlocBuilder<TagSuggestionCubit, TagSuggestionState>(
              builder: (context, tagState) {
                final availableTags = tagState.maybeWhen(
                  loaded: (tags) => tags.map((t) => t.name).toList(),
                  orElse: () => <String>[],
                );

                return AdvancedSearchFilter(
                  availableTags: availableTags,
                  onApply: (filters) {
                    // Filters are already applied via SearchCubit in the widget
                  },
                  onClose: () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Search results
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return state.when(
                  idle: () => const Center(
                    child: Text('Enter search criteria'),
                  ),
                  loading: (currentQuery) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: (results, query, totalCount) => SearchResults(
                    results: results,
                    query: query,
                    onSheetTap: (sheet) {
                      // Navigate to sheet detail
                      Navigator.pop(context, sheet);
                    },
                  ),
                  empty: (query) => const Center(
                    child: Text('No results found'),
                  ),
                  error: (message, query) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $message'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SearchCubit>().clearSearch();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
