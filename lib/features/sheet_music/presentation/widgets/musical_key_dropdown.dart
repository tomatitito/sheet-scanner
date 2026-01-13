import 'package:flutter/material.dart';
import 'package:sheet_scanner/features/sheet_music/domain/musical_key.dart';

/// A dropdown widget for selecting a musical key.
class MusicalKeyDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final String? errorText;

  const MusicalKeyDropdown({
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
        labelText: 'Musical Key',
        hintText: 'Select key (optional)',
        errorText: errorText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.music_note),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None (optional)'),
        ),
        ...MusicalKey.majorKeys.map((key) => DropdownMenuItem<String>(
              value: key.storageValue,
              child: Text(key.displayName),
            )),
        ...MusicalKey.minorKeys.map((key) => DropdownMenuItem<String>(
              value: key.storageValue,
              child: Text(key.displayName),
            )),
      ],
    );
  }
}
