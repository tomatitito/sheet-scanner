import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/data/catalog_prefixes.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/edit_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/edit_sheet_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/language_selector.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/composer_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/title_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/voice_input_button.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/musical_key_dropdown.dart';

/// Page for editing an existing sheet music entry
class EditSheetPage extends StatefulWidget {
  final int sheetMusicId;
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;

  const EditSheetPage({
    super.key,
    required this.sheetMusicId,
    this.onSuccess,
    this.onClose,
  });

  @override
  State<EditSheetPage> createState() => _EditSheetPageState();
}

class _EditSheetPageState extends State<EditSheetPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _composerController;
  late final TextEditingController _opusController;
  late final TextEditingController _notesController;
  final List<String> _tags = [];
  String? _selectedMusicalKey;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _composerController = TextEditingController();
    _opusController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _composerController.dispose();
    _opusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    context.read<EditSheetCubit>().validate(
          title: value,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onComposerChanged(String value) {
    // Auto-populate opus field if it's empty and composer has a known catalog
    if (_opusController.text.isEmpty) {
      final prefix = getCatalogPrefixForComposer(value);
      if (prefix != null) {
        _opusController.text = prefix;
      }
    }

    context.read<EditSheetCubit>().validate(
          title: _titleController.text,
          composer: value,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onOpusChanged(String value) {
    context.read<EditSheetCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: value.isEmpty ? null : value,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onMusicalKeyChanged(String? value) {
    setState(() {
      _selectedMusicalKey = value;
    });
    context.read<EditSheetCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: value,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onNotesChanged(String value) {
    context.read<EditSheetCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: value,
          tags: _tags,
        );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      context.read<EditSheetCubit>().validate(
            title: _titleController.text,
            composer: _composerController.text,
            opus: _opusController.text.isEmpty ? null : _opusController.text,
            musicalKey: _selectedMusicalKey,
            notes: _notesController.text,
            tags: _tags,
          );
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    context.read<EditSheetCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _submitForm(int id, DateTime createdAt) {
    context.read<EditSheetCubit>().submitForm(
          id: id,
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
          createdAt: createdAt,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<EditSheetCubit>()..loadSheetMusic(widget.sheetMusicId),
      child: BlocListener<EditSheetCubit, EditSheetState>(
        listener: (context, state) {
          if (state is EditSheetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Sheet music "${state.sheetMusic.title}" updated successfully'),
                duration: const Duration(seconds: 2),
              ),
            );
            widget.onSuccess?.call();
            if (mounted && context.mounted) {
              context.pop();
            }
          } else if (state is EditSheetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.failure.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _EditSheetForm(
          sheetMusicId: widget.sheetMusicId,
          titleController: _titleController,
          composerController: _composerController,
          opusController: _opusController,
          notesController: _notesController,
          tags: _tags,
          selectedMusicalKey: _selectedMusicalKey,
          onTitleChanged: _onTitleChanged,
          onComposerChanged: _onComposerChanged,
          onOpusChanged: _onOpusChanged,
          onMusicalKeyChanged: _onMusicalKeyChanged,
          onNotesChanged: _onNotesChanged,
          onAddTag: _addTag,
          onRemoveTag: _removeTag,
          onSubmit: _submitForm,
          onClose: widget.onClose,
          onMusicalKeyInitialized: (key) {
            _selectedMusicalKey = key;
          },
        ),
      ),
    );
  }
}

class _EditSheetForm extends StatefulWidget {
  final int sheetMusicId;
  final TextEditingController titleController;
  final TextEditingController composerController;
  final TextEditingController opusController;
  final TextEditingController notesController;
  final List<String> tags;
  final String? selectedMusicalKey;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onComposerChanged;
  final ValueChanged<String> onOpusChanged;
  final ValueChanged<String?> onMusicalKeyChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;
  final Function(int, DateTime) onSubmit;
  final VoidCallback? onClose;
  final ValueChanged<String?> onMusicalKeyInitialized;

  const _EditSheetForm({
    required this.sheetMusicId,
    required this.titleController,
    required this.composerController,
    required this.opusController,
    required this.notesController,
    required this.tags,
    required this.selectedMusicalKey,
    required this.onTitleChanged,
    required this.onComposerChanged,
    required this.onOpusChanged,
    required this.onMusicalKeyChanged,
    required this.onNotesChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSubmit,
    required this.onMusicalKeyInitialized,
    this.onClose,
  });

  @override
  State<_EditSheetForm> createState() => _EditSheetFormState();
}

class _EditSheetFormState extends State<_EditSheetForm> {
  final _formKey = GlobalKey<FormState>();
  String _newTag = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditSheetCubit, EditSheetState>(
      builder: (context, state) {
        if (state is EditSheetInitial || state is EditSheetLoading) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? () => context.pop(),
              ),
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is EditSheetError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? () => context.pop(),
              ),
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load sheet music',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.failure.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<EditSheetCubit>()
                          .refresh(widget.sheetMusicId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is EditSheetLoaded ||
            state is EditSheetValidating ||
            state is EditSheetValid ||
            state is EditSheetInvalid ||
            state is EditSheetSubmitting ||
            state is EditSheetSuccess) {
          // Initialize form fields from loaded data
          final loadedSheet =
              state is EditSheetLoaded ? state.sheetMusic : null;
          if (loadedSheet != null &&
              widget.titleController.text.isEmpty &&
              widget.composerController.text.isEmpty) {
            widget.titleController.text = loadedSheet.title;
            widget.composerController.text = loadedSheet.composer;
            widget.opusController.text = loadedSheet.opus ?? '';
            widget.notesController.text = loadedSheet.notes ?? '';
            widget.tags.clear();
            widget.tags.addAll(loadedSheet.tags);
            widget.onMusicalKeyInitialized(loadedSheet.musicalKey);
          }

          final isSubmitting = state is EditSheetSubmitting;
          final errors = state is EditSheetInvalid ? state.errors : {};
          final sheetMusic =
              state is EditSheetLoaded ? state.sheetMusic : loadedSheet;

          if (sheetMusic == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? () => context.pop(),
              ),
              title: const Text('Edit Sheet Music'),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language selector for voice recognition
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Text(
                            'Voice Language:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 12),
                          LanguageSelector(
                            initialLanguage: 'en_US',
                          ),
                        ],
                      ),
                    ),
                    // Title field with autocomplete (based on composer) and voice input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TitleAutocompleteField(
                            controller: widget.titleController,
                            composerName: widget.composerController.text,
                            enabled: !isSubmitting,
                            errorText: errors['title'],
                            onChanged: widget.onTitleChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: VoiceInputButton(
                            onDictationComplete: (text) {
                              widget.titleController.text = text;
                              widget.onTitleChanged(text);
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Voice input error: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            tooltip: 'Voice input for title',
                            size: 48.0,
                            idleColor: Colors.blue,
                            listeningColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Composer field with autocomplete and voice input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ComposerAutocompleteField(
                            controller: widget.composerController,
                            enabled: !isSubmitting,
                            errorText: errors['composer'],
                            onChanged: widget.onComposerChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: VoiceInputButton(
                            onDictationComplete: (text) {
                              widget.composerController.text = text;
                              widget.onComposerChanged(text);
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Voice input error: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            tooltip: 'Voice input for composer',
                            size: 48.0,
                            idleColor: Colors.blue,
                            listeningColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Opus/Catalog number field (optional)
                    TextFormField(
                      controller: widget.opusController,
                      enabled: !isSubmitting,
                      onChanged: widget.onOpusChanged,
                      decoration: InputDecoration(
                        labelText: 'Opus/Catalog Number',
                        hintText: 'e.g., Op. 27, BWV 846, K. 331',
                        errorText: errors['opus'],
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.tag),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Musical Key dropdown (optional)
                    MusicalKeyDropdown(
                      selectedValue: widget.selectedMusicalKey,
                      enabled: !isSubmitting,
                      errorText: errors['musicalKey'],
                      onChanged: widget.onMusicalKeyChanged,
                    ),
                    const SizedBox(height: 16),

                    // Notes field with voice input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.notesController,
                            enabled: !isSubmitting,
                            onChanged: widget.onNotesChanged,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              hintText: 'Optional notes about the piece',
                              errorText: errors['notes'],
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.notes),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: VoiceInputButton(
                            onDictationComplete: (text) {
                              final currentText = widget.notesController.text;
                              widget.notesController.text = currentText.isEmpty
                                  ? text
                                  : '$currentText $text';
                              widget
                                  .onNotesChanged(widget.notesController.text);
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Voice input error: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            tooltip: 'Voice input for notes',
                            size: 48.0,
                            idleColor: Colors.blue,
                            listeningColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tags section
                    Text(
                      'Tags',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _newTag = value;
                            },
                            enabled: !isSubmitting,
                            decoration: const InputDecoration(
                              hintText: 'Enter tag name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  widget.onAddTag(_newTag);
                                  _newTag = '';
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                onDeleted: isSubmitting
                                    ? null
                                    : () => widget.onRemoveTag(tag),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (isSubmitting ||
                                state is EditSheetInvalid ||
                                state is EditSheetInitial ||
                                state is EditSheetLoading)
                            ? null
                            : () {
                                widget.onSubmit(
                                    sheetMusic.id, sheetMusic.createdAt);
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          isSubmitting ? 'Updating...' : 'Update Sheet Music',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Helper text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Fields marked with * are required',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Unknown state')),
        );
      },
    );
  }
}
