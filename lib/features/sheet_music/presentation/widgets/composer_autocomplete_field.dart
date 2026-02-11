import 'package:flutter/material.dart';

import '../../../../data/composers.dart';

/// A text field with autocomplete suggestions for classical composer names.
///
/// Uses the curated list from [kComposerNames] to provide suggestions
/// as the user types. Supports both keyboard navigation and tap selection.
/// Shows Zerluth metadata including works count and average difficulty.
class ComposerAutocompleteField extends StatelessWidget {
  const ComposerAutocompleteField({
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<ComposerData>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase().trim();
            if (query.isEmpty) {
              // Show popular/recommended composers when empty
              return kComposers
                  .where((c) => c.isPopular || c.isRecommended)
                  .take(10);
            }
            return kComposers
                .where((c) => c.name.toLowerCase().contains(query))
                .take(50);
          },
          displayStringForOption: (option) => option.name,
          onSelected: (selection) {
            controller.text = selection.name;
            onChanged(selection.name);
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
                      final composer = options.elementAt(index);
                      final isHighlighted =
                          AutocompleteHighlightedOption.of(context) == index;

                      // Build subtitle with epoch, life years, and works info
                      final subtitleParts = <String>[];
                      if (composer.epoch.isNotEmpty &&
                          composer.epoch != 'Unknown') {
                        subtitleParts.add(composer.epoch);
                      }
                      if (composer.lifeYears.isNotEmpty) {
                        subtitleParts.add(composer.lifeYears);
                      }
                      if (composer.worksCount > 0) {
                        subtitleParts.add('${composer.worksCount} works');
                      }

                      // Build trailing with difficulty and badges
                      Widget? trailing;
                      final badges = <Widget>[];
                      if (composer.isPopular) {
                        badges.add(_buildBadge(context, '★', Colors.amber));
                      }
                      if (composer.averageDifficulty != null) {
                        badges.add(_buildDifficultyIndicator(
                            context, composer.averageDifficulty!));
                      }
                      if (badges.isNotEmpty) {
                        trailing = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: badges,
                        );
                      }

                      return ListTile(
                        tileColor: isHighlighted
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        title: Text(composer.name),
                        subtitle: subtitleParts.isNotEmpty
                            ? Text(
                                subtitleParts.join(' • '),
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
                        trailing: trailing,
                        dense: true,
                        onTap: () => onSelected(composer),
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
            // Sync the external controller with the autocomplete's internal one
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (textEditingController.text != controller.text) {
                textEditingController.text = controller.text;
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode ?? fieldFocusNode,
              enabled: enabled,
              onChanged: (value) {
                controller.text = value;
                onChanged(value);
              },
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: InputDecoration(
                labelText: 'Composer *',
                hintText: 'Start typing a composer name...',
                errorText: errorText,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          controller.clear();
                          onChanged('');
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

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _buildDifficultyIndicator(BuildContext context, double difficulty) {
    // Show difficulty as filled/unfilled stars (1-5 scale)
    final fullStars = difficulty.round().clamp(1, 5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return Icon(
            i < fullStars ? Icons.star : Icons.star_border,
            size: 12,
            color: i < fullStars
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          );
        }),
      ),
    );
  }
}
