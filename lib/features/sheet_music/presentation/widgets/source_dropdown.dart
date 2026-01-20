import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheet_scanner/core/services/source_manager.dart';

/// A dropdown widget for selecting a sheet music source.
/// Sources can be managed (added/removed) by the user.
class SourceDropdown extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final String? errorText;

  const SourceDropdown({
    super.key,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<SourceDropdown> createState() => _SourceDropdownState();
}

class _SourceDropdownState extends State<SourceDropdown> {
  List<String> _sources = ['private'];
  SourceManager? _sourceManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sourceManager = SourceManager(prefs: prefs);
      await _sourceManager!.ensureDefaults();

      setState(() {
        _sources = _sourceManager!.getSources();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sources: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showManageSourcesDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _ManageSourcesDialog(
        sourceManager: _sourceManager!,
        onSourcesChanged: () {
          setState(() {
            _sources = _sourceManager!.getSources();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: widget.selectedValue?.isEmpty == true ? null : widget.selectedValue,
          onChanged: widget.enabled ? widget.onChanged : null,
          decoration: InputDecoration(
            labelText: 'Source',
            hintText: 'Select source (optional)',
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.source),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None (optional)'),
            ),
            ..._sources.map((source) => DropdownMenuItem<String>(
                  value: source,
                  child: Text(source),
                )),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _showManageSourcesDialog,
          icon: const Icon(Icons.settings),
          label: const Text('Manage Sources'),
        ),
      ],
    );
  }
}

/// Dialog for managing (adding/removing) source values.
class _ManageSourcesDialog extends StatefulWidget {
  final SourceManager sourceManager;
  final VoidCallback onSourcesChanged;

  const _ManageSourcesDialog({
    required this.sourceManager,
    required this.onSourcesChanged,
  });

  @override
  State<_ManageSourcesDialog> createState() => _ManageSourcesDialogState();
}

class _ManageSourcesDialogState extends State<_ManageSourcesDialog> {
  final TextEditingController _newSourceController = TextEditingController();
  List<String> _sources = [];

  @override
  void initState() {
    super.initState();
    _sources = widget.sourceManager.getSources();
  }

  @override
  void dispose() {
    _newSourceController.dispose();
    super.dispose();
  }

  Future<void> _addSource() async {
    final newSource = _newSourceController.text.trim();
    if (newSource.isEmpty) {
      _showMessage('Please enter a source name');
      return;
    }

    final success = await widget.sourceManager.addSource(newSource);
    if (success) {
      setState(() {
        _sources = widget.sourceManager.getSources();
        _newSourceController.clear();
      });
      widget.onSourcesChanged();
      _showMessage('Source "$newSource" added');
    } else {
      _showMessage('Source "$newSource" already exists');
    }
  }

  Future<void> _removeSource(String source) async {
    final success = await widget.sourceManager.removeSource(source);
    if (success) {
      setState(() {
        _sources = widget.sourceManager.getSources();
      });
      widget.onSourcesChanged();
      _showMessage('Source "$source" removed');
    } else {
      _showMessage('Cannot remove "$source"');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Sources'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add new source section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSourceController,
                    decoration: const InputDecoration(
                      labelText: 'New Source',
                      hintText: 'e.g., music school',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSource(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addSource,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Existing sources list
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Existing Sources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sources.length,
                itemBuilder: (context, index) {
                  final source = _sources[index];
                  final isDefault = source == 'private';

                  return ListTile(
                    leading: const Icon(Icons.label),
                    title: Text(source),
                    trailing: isDefault
                        ? const Chip(
                            label: Text('Default'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSource(source),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
