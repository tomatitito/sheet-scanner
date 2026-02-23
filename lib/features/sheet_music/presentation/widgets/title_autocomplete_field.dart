import 'package:flutter/material.dart';

import '../../../../data/composer_works.dart';

/// Callback for when a work is selected with its metadata.
typedef OnWorkSelected = void Function(
  String title,
  int? difficulty,
  String? instrumentation,
);

/// A text field with autocomplete suggestions for piece titles based on selected composer.
///
/// Provides suggestions from the [ComposerWorksData] when the user types,
/// filtered to match the currently selected composer.
/// Shows difficulty, catalog number, key signature, and instrumentation for enriched data.
class TitleAutocompleteField extends StatefulWidget {
  const TitleAutocompleteField({
    required this.controller,
    required this.composerName,
    required this.onChanged,
    this.onWorkSelected,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;

  /// The currently selected composer name to filter works.
  final String composerName;

  final ValueChanged<String> onChanged;

  /// Callback when a work is selected, provides metadata for auto-fill.
  final OnWorkSelected? onWorkSelected;

  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;

  @override
  State<TitleAutocompleteField> createState() => _TitleAutocompleteFieldState();
}

class _TitleAutocompleteFieldState extends State<TitleAutocompleteField> {
  List<WorkInfo> _availableWorks = const [];
  bool _isLoading = false;

  /// Shared group ID for TapRegion so that tapping inside either the field
  /// or the dropdown doesn't dismiss the dropdown.
  final _tapRegionGroupId = Object();

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
      // Data not loaded yet — show loading indicator
      setState(() => _isLoading = true);
      data.load().then((_) {
        if (mounted) {
          setState(() {
            _availableWorks = data.getWorksInfoFuzzy(widget.composerName);
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _availableWorks = data.getWorksInfoFuzzy(widget.composerName);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no composer selected, show simple text field
    if (widget.composerName.isEmpty) {
      return _buildPlainField();
    }

    // Loading state: show field with a loading indicator in the suffix
    if (_isLoading) {
      return _buildLoadingField();
    }

    // No works available for this composer — plain field
    if (_availableWorks.isEmpty) {
      return _buildPlainField();
    }

    return _buildAutocompleteField();
  }

  /// Plain text field without autocomplete suggestions.
  Widget _buildPlainField() {
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

  /// Text field showing a loading indicator while suggestion data is being fetched.
  Widget _buildLoadingField() {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'Loading suggestions…',
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.music_note),
        suffixIcon: const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  /// Full autocomplete field with dropdown suggestions.
  Widget _buildAutocompleteField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<WorkInfo>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase().trim();
            if (query.isEmpty) {
              // Show all works for composer when field is empty but focused
              return _availableWorks.take(15);
            }
            return _availableWorks
                .where((work) =>
                    work.title.toLowerCase().contains(query) ||
                    (work.catalogNumber != null &&
                        work.catalogNumber!.toLowerCase().contains(query)) ||
                    (work.musicalKey != null &&
                        work.musicalKey!.toLowerCase().contains(query)))
                .take(20);
          },
          displayStringForOption: (option) => option.title,
          onSelected: (selection) {
            widget.controller.text = selection.title;
            widget.onChanged(selection.title);
            // Call auto-fill callback with metadata
            widget.onWorkSelected?.call(
              selection.title,
              selection.difficulty,
              selection.instrumentation,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return TapRegion(
              groupId: _tapRegionGroupId,
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    constraints: BoxConstraints(
                      maxHeight: 350,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final work = options.elementAt(index);
                        final isHighlighted =
                            AutocompleteHighlightedOption.of(context) == index;

                        // Build subtitle with metadata
                        final subtitleParts = <String>[];
                        if (work.catalogNumber != null &&
                            work.catalogNumber!.isNotEmpty) {
                          subtitleParts.add(work.catalogNumber!);
                        }
                        if (work.musicalKey != null &&
                            work.musicalKey!.isNotEmpty) {
                          subtitleParts.add(work.musicalKey!);
                        }
                        if (work.instrumentation != null &&
                            work.instrumentation!.isNotEmpty) {
                          subtitleParts.add(work.instrumentation!);
                        }
                        if (work.genre != null && work.genre!.isNotEmpty) {
                          subtitleParts.add(work.genre!);
                        }
                        final subtitle = subtitleParts.isNotEmpty
                            ? subtitleParts.join(' • ')
                            : null;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          color: isHighlighted
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                          child: ListTile(
                            title: Text(
                              work.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: subtitle != null
                                ? Text(
                                    subtitle,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            trailing: work.difficulty != null
                                ? _buildDifficultyIndicator(
                                    context, work.difficulty!)
                                : null,
                            dense: true,
                            onTap: () => onSelected(work),
                          ),
                        );
                      },
                    ),
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

            return TapRegion(
              groupId: _tapRegionGroupId,
              onTapOutside: (_) => fieldFocusNode.unfocus(),
              child: TextFormField(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyIndicator(BuildContext context, int difficulty) {
    // Show difficulty as filled/unfilled stars (1-5 scale)
    final clampedDifficulty = difficulty.clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < clampedDifficulty ? Icons.star : Icons.star_border,
          size: 14,
          color: i < clampedDifficulty
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        );
      }),
    );
  }
}
