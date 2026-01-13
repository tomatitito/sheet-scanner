import 'package:flutter/material.dart';

import '../../../../data/composer_works.dart';

/// A text field with autocomplete suggestions for piece titles based on selected composer.
///
/// Provides suggestions from the [ComposerWorksData] when the user types,
/// filtered to match the currently selected composer.
class TitleAutocompleteField extends StatefulWidget {
  const TitleAutocompleteField({
    required this.controller,
    required this.composerName,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;

  /// The currently selected composer name to filter works.
  final String composerName;

  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;

  @override
  State<TitleAutocompleteField> createState() => _TitleAutocompleteFieldState();
}

class _TitleAutocompleteFieldState extends State<TitleAutocompleteField> {
  List<String> _availableWorks = const [];

  @override
  void initState() {
    super.initState();
    _loadWorks();
  }

  @override
  void didUpdateWidget(TitleAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.composerName != widget.composerName) {
      _loadWorks();
    }
  }

  void _loadWorks() {
    final data = ComposerWorksData.instance;
    if (!data.isLoaded) {
      // Data not loaded yet - try loading
      data.load().then((_) {
        if (mounted) {
          setState(() {
            _availableWorks =
                data.getWorksForComposerFuzzy(widget.composerName);
          });
        }
      });
    } else {
      _availableWorks = data.getWorksForComposerFuzzy(widget.composerName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no composer selected or no works available, show simple text field
    if (widget.composerName.isEmpty || _availableWorks.isEmpty) {
      return TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: 'Title *',
          hintText: 'Enter piece title',
          errorText: widget.errorText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.music_note),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase().trim();
            if (query.isEmpty) {
              // Show all works for composer when field is empty but focused
              return _availableWorks.take(10);
            }
            return _availableWorks
                .where((work) => work.toLowerCase().contains(query))
                .take(15);
          },
          displayStringForOption: (option) => option,
          onSelected: (selection) {
            widget.controller.text = selection;
            widget.onChanged(selection);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      final isHighlighted =
                          AutocompleteHighlightedOption.of(context) == index;
                      return ListTile(
                        tileColor: isHighlighted
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        title: Text(
                          option,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        dense: true,
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            fieldFocusNode,
            onFieldSubmitted,
          ) {
            // Sync external controller with autocomplete's internal one
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (textEditingController.text != widget.controller.text) {
                textEditingController.text = widget.controller.text;
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: widget.focusNode ?? fieldFocusNode,
              enabled: widget.enabled,
              onChanged: (value) {
                widget.controller.text = value;
                widget.onChanged(value);
              },
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: _availableWorks.isNotEmpty
                    ? 'Start typing or select from ${_availableWorks.length} works...'
                    : 'Enter piece title',
                errorText: widget.errorText,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.music_note),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          widget.controller.clear();
                          widget.onChanged('');
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
