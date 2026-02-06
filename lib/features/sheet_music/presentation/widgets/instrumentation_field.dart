import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Common instrumentation options from zerluth.de
const List<String> kDefaultInstrumentations = [
  'Fl,Pno',
  'Flöte-Solo',
  'Zwei Flöten',
  'Drei Flöten',
  'Fl,Gitarre',
  'Fl,Violine',
  'Fl,B.c.',
  'Bläserquintett',
  'Ensemble',
];

/// A field for selecting or entering instrumentation.
/// Supports both predefined options and custom entries.
class InstrumentationField extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final String? errorText;

  const InstrumentationField({
    super.key,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<InstrumentationField> createState() => _InstrumentationFieldState();
}

class _InstrumentationFieldState extends State<InstrumentationField> {
  late final TextEditingController _controller;
  List<String> _customInstrumentations = [];
  bool _isLoading = true;

  static const String _storageKey = 'custom_instrumentations';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedValue);
    _loadCustomInstrumentations();
  }

  @override
  void didUpdateWidget(InstrumentationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue &&
        widget.selectedValue != _controller.text) {
      _controller.text = widget.selectedValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCustomInstrumentations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey) ?? [];
      setState(() {
        _customInstrumentations = stored;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading custom instrumentations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCustomInstrumentation(String value) async {
    if (value.isEmpty) return;
    if (kDefaultInstrumentations.contains(value)) return;
    if (_customInstrumentations.contains(value)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _customInstrumentations.add(value);
      await prefs.setStringList(_storageKey, _customInstrumentations);
      setState(() {});
    } catch (e) {
      debugPrint('Error saving custom instrumentation: $e');
    }
  }

  List<String> get _allInstrumentations =>
      [...kDefaultInstrumentations, ..._customInstrumentations];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.selectedValue ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _allInstrumentations;
        }
        return _allInstrumentations.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        widget.onChanged?.call(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sync the controller with widget value
        if (fieldController.text != widget.selectedValue &&
            widget.selectedValue != null) {
          fieldController.text = widget.selectedValue!;
        }

        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          enabled: widget.enabled,
          onChanged: (value) {
            widget.onChanged?.call(value.isEmpty ? null : value);
          },
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              _saveCustomInstrumentation(value);
            }
            onFieldSubmitted();
          },
          decoration: InputDecoration(
            labelText: 'Instrumentation',
            hintText: 'e.g., Fl,Pno, Zwei Flöten',
            helperText: 'Type or select from suggestions',
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.group),
            suffixIcon: fieldController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: widget.enabled
                        ? () {
                            fieldController.clear();
                            widget.onChanged?.call(null);
                          }
                        : null,
                  )
                : null,
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 300,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  final isCustom = _customInstrumentations.contains(option);

                  return ListTile(
                    leading: Icon(
                      isCustom ? Icons.person : Icons.music_note,
                      size: 20,
                    ),
                    title: Text(option),
                    dense: true,
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
