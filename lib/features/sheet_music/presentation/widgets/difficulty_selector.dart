import 'package:flutter/material.dart';

/// A visual selector for difficulty level (1-5 scale).
/// Similar to the rating tabs on zerluth.de.
class DifficultySelector extends StatelessWidget {
  final int? selectedValue;
  final ValueChanged<int?>? onChanged;
  final bool enabled;
  final String? errorText;
  final bool isAutoFilled;

  const DifficultySelector({
    super.key,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.isAutoFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Difficulty Level',
            hintText: 'Select difficulty (optional)',
            errorText: errorText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.trending_up),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Clear button
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: selectedValue == null
                      ? colorScheme.outline.withValues(alpha: 0.3)
                      : colorScheme.outline,
                ),
                tooltip: 'Clear difficulty',
                onPressed: enabled && selectedValue != null
                    ? () => onChanged?.call(null)
                    : null,
              ),
              // Difficulty levels 1-5
              ...List.generate(5, (index) {
                final level = index + 1;
                final isSelected = selectedValue == level;

                return InkWell(
                  onTap: enabled ? () => onChanged?.call(level) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getDifficultyColor(level)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? _getDifficultyColor(level).withValues(alpha: 0.8)
                            : colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        if (errorText == null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              isAutoFilled
                  ? '${_getDifficultyLabel(selectedValue)} (auto-filled)'
                  : _getDifficultyLabel(selectedValue),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isAutoFilled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontStyle: isAutoFilled ? FontStyle.italic : null,
              ),
            ),
          ),
      ],
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(int? level) {
    switch (level) {
      case 1:
        return 'Very Easy - Beginner level';
      case 2:
        return 'Easy - Elementary level';
      case 3:
        return 'Moderate - Intermediate level';
      case 4:
        return 'Difficult - Advanced level';
      case 5:
        return 'Very Difficult - Professional level';
      default:
        return 'No difficulty selected';
    }
  }
}
