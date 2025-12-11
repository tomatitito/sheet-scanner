import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_cubit.dart';

/// A search bar widget that triggers FTS search with debounce.
class SearchBarWidget extends StatefulWidget {
  final Duration debounceDelay;
  final VoidCallback onClear;

  const SearchBarWidget({
    Key? key,
    this.debounceDelay = const Duration(milliseconds: 500),
    required this.onClear,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  Future<void>? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.ignore();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.ignore();

    if (query.isEmpty) {
      context.read<SearchCubit>().clearSearch();
      return;
    }

    _debounceTimer = Future.delayed(widget.debounceDelay, () {
      context.read<SearchCubit>().search(query);
    });
  }

  void _onClear() {
    _controller.clear();
    context.read<SearchCubit>().clearSearch();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search sheets, composers...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
