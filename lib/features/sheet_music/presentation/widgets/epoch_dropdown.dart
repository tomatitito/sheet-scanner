import 'package:flutter/material.dart';

/// Musical epoch/era options.
/// Derived from historical periods in classical music.
class MusicalEpoch {
  final String value;
  final String displayName;
  final String dateRange;

  const MusicalEpoch({
    required this.value,
    required this.displayName,
    required this.dateRange,
  });

  static const List<MusicalEpoch> epochs = [
    MusicalEpoch(
      value: 'medieval',
      displayName: 'Medieval',
      dateRange: 'before 1400',
    ),
    MusicalEpoch(
      value: 'renaissance',
      displayName: 'Renaissance',
      dateRange: '1400-1600',
    ),
    MusicalEpoch(
      value: 'baroque',
      displayName: 'Baroque',
      dateRange: '1600-1750',
    ),
    MusicalEpoch(
      value: 'classical',
      displayName: 'Classical',
      dateRange: '1750-1820',
    ),
    MusicalEpoch(
      value: 'romantic',
      displayName: 'Romantic',
      dateRange: '1820-1900',
    ),
    MusicalEpoch(
      value: '20th_century',
      displayName: '20th Century',
      dateRange: '1900-2000',
    ),
    MusicalEpoch(
      value: 'contemporary',
      displayName: 'Contemporary',
      dateRange: '2000+',
    ),
  ];

  static MusicalEpoch? fromValue(String? value) {
    if (value == null) return null;
    try {
      return epochs.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

/// A dropdown widget for selecting a musical epoch/era.
class EpochDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final String? errorText;

  const EpochDropdown({
    super.key,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue?.isEmpty == true ? null : selectedValue,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: 'Epoch / Era',
        hintText: 'Select musical period (optional)',
        errorText: errorText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.history),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None (optional)'),
        ),
        ...MusicalEpoch.epochs.map((epoch) => DropdownMenuItem<String>(
              value: epoch.value,
              child: Row(
                children: [
                  Expanded(child: Text(epoch.displayName)),
                  Text(
                    epoch.dateRange,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
