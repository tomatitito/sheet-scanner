import 'package:flutter/material.dart';

import '../../../../data/composers.dart';

/// A text field with autocomplete suggestions for classical composer names.
///
/// Uses the curated list from [kComposerNames] to provide suggestions
/// as the user types. Supports both keyboard navigation and tap selection.
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
        return Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase().trim();
            if (query.isEmpty) {
              return const Iterable<String>.empty();
            }
            return kComposerNames.where(
              (name) => name.toLowerCase().contains(query),
            );
          },
          displayStringForOption: (option) => option,
          onSelected: (selection) {
            controller.text = selection;
            onChanged(selection);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 250,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      final composer = kComposers.firstWhere(
                        (c) => c.name == option,
                        orElse: () => ComposerData(name: option, epoch: ''),
                      );
                      final isHighlighted =
                          AutocompleteHighlightedOption.of(context) == index;
                      return ListTile(
                        tileColor: isHighlighted
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        title: Text(option),
                        subtitle: composer.epoch.isNotEmpty
                            ? Text(
                                '${composer.epoch} ${composer.lifeYears}',
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
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
}
