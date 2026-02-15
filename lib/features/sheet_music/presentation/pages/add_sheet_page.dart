import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/accessibility/semantic_widgets.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/data/auto_fill_matcher.dart';
import 'package:sheet_scanner/data/catalog_prefixes.dart';
import 'package:sheet_scanner/features/sheet_music/data/services/file_picker_service.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/file_picker_drop_zone.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/language_selector.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/composer_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/title_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/voice_input_button.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/musical_key_dropdown.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/source_dropdown.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/difficulty_selector.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/instrumentation_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/epoch_dropdown.dart';

/// Page for adding a new sheet music entry to the library
class AddSheetPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;

  const AddSheetPage({
    super.key,
    this.onSuccess,
    this.onClose,
  });

  @override
  State<AddSheetPage> createState() => _AddSheetPageState();
}

class _AddSheetPageState extends State<AddSheetPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _composerController;
  late final TextEditingController _opusController;
  late final TextEditingController _notesController;
  String? _musicalKey;
  String? _source;
  int? _difficulty;
  String? _instrumentation;
  String? _epoch;
  final List<String> _tags = [];
  final List<String> _selectedFiles = [];
  late final FilePickerService _filePickerService;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _composerController = TextEditingController();
    _opusController = TextEditingController();
    _notesController = TextEditingController();
    _filePickerService = getIt<FilePickerService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _composerController.dispose();
    _opusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddSheetCubit>(),
      child: BlocListener<AddSheetCubit, AddSheetState>(
        listener: (context, state) {
          if (state is AddSheetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sheet music "${state.sheetMusic.title}" added successfully'),
                duration: const Duration(seconds: 2),
              ),
            );
            widget.onSuccess?.call();
            if (mounted && context.mounted) {
              context.pop();
            }
          } else if (state is AddSheetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.userMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _AddSheetForm(
          titleController: _titleController,
          composerController: _composerController,
          opusController: _opusController,
          notesController: _notesController,
          musicalKey: _musicalKey,
          onMusicalKeyChanged: (value) => setState(() => _musicalKey = value),
          source: _source,
          onSourceChanged: (value) => setState(() => _source = value),
          difficulty: _difficulty,
          onDifficultyChanged: (value) => setState(() => _difficulty = value),
          instrumentation: _instrumentation,
          onInstrumentationChanged: (value) => setState(() => _instrumentation = value),
          epoch: _epoch,
          onEpochChanged: (value) => setState(() => _epoch = value),
          tags: _tags,
          selectedFiles: _selectedFiles,
          filePickerService: _filePickerService,
          onClose: widget.onClose,
        ),
      ),
    );
  }
}

class _AddSheetForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController composerController;
  final TextEditingController opusController;
  final TextEditingController notesController;
  final String? musicalKey;
  final ValueChanged<String?> onMusicalKeyChanged;
  final String? source;
  final ValueChanged<String?> onSourceChanged;
  final int? difficulty;
  final ValueChanged<int?> onDifficultyChanged;
  final String? instrumentation;
  final ValueChanged<String?> onInstrumentationChanged;
  final String? epoch;
  final ValueChanged<String?> onEpochChanged;
  final List<String> tags;
  final List<String> selectedFiles;
  final FilePickerService filePickerService;
  final VoidCallback? onClose;

  const _AddSheetForm({
    required this.titleController,
    required this.composerController,
    required this.opusController,
    required this.notesController,
    this.musicalKey,
    required this.onMusicalKeyChanged,
    this.source,
    required this.onSourceChanged,
    this.difficulty,
    required this.onDifficultyChanged,
    this.instrumentation,
    required this.onInstrumentationChanged,
    this.epoch,
    required this.onEpochChanged,
    required this.tags,
    required this.selectedFiles,
    required this.filePickerService,
    this.onClose,
  });

  @override
  State<_AddSheetForm> createState() => _AddSheetFormState();
}

class _AddSheetFormState extends State<_AddSheetForm> {
  final _formKey = GlobalKey<FormState>();
  String _newTag = '';
  String? _selectedMusicalKey;
  String? _selectedSource;
  int? _selectedDifficulty;
  String? _selectedInstrumentation;
  String? _selectedEpoch;

  /// Track if user has manually edited the opus field.
  /// Once edited, we don't auto-populate anymore to respect user's input.
  bool _opusManuallyEdited = false;

  /// Auto-fill matcher for cross-field auto-fill from reference data.
  final AutoFillMatcher _autoFillMatcher = AutoFillMatcher();

  /// Provenance tracking for auto-fillable fields.
  final Map<String, FieldProvenance> _provenance = {
    'difficulty': FieldProvenance.empty,
    'instrumentation': FieldProvenance.empty,
    'epoch': FieldProvenance.empty,
  };

  /// Debounce timer for auto-fill matching.
  Timer? _autoFillDebounce;

  @override
  void dispose() {
    _autoFillDebounce?.cancel();
    super.dispose();
  }

  void _validateForm() {
    final cubit = context.read<AddSheetCubit>();
    cubit.validate(
      title: widget.titleController.text,
      composer: widget.composerController.text,
      opus: widget.opusController.text.isEmpty ? null : widget.opusController.text,
      musicalKey: _selectedMusicalKey,
      source: _selectedSource,
      difficulty: _selectedDifficulty,
      instrumentation: _selectedInstrumentation,
      epoch: _selectedEpoch,
      notes: widget.notesController.text,
      tags: widget.tags,
    );
  }

  /// Triggers debounced auto-fill matching.
  void _triggerAutoFill() {
    _autoFillDebounce?.cancel();
    _autoFillDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _runAutoFill();
    });
  }

  /// Runs the auto-fill matcher and updates fields.
  void _runAutoFill() {
    final criteria = MatchCriteria(
      composer: widget.composerController.text.isNotEmpty
          ? widget.composerController.text
          : null,
      title: widget.titleController.text.isNotEmpty
          ? widget.titleController.text
          : null,
      difficulty: _provenance['difficulty'] == FieldProvenance.manual
          ? _selectedDifficulty
          : null,
      instrumentation:
          _provenance['instrumentation'] == FieldProvenance.manual
              ? _selectedInstrumentation
              : null,
      epoch: _provenance['epoch'] == FieldProvenance.manual
          ? _selectedEpoch
          : null,
    );

    final result = _autoFillMatcher.findMatch(criteria);

    if (result.hasUniqueMatch) {
      final match = result.uniqueMatch!;
      setState(() {
        // Auto-fill difficulty if empty or previously auto-filled
        if (_provenance['difficulty'] != FieldProvenance.manual &&
            match.difficulty != null) {
          _selectedDifficulty = match.difficulty;
          _provenance['difficulty'] = FieldProvenance.autoFilled;
          widget.onDifficultyChanged(match.difficulty);
        }
        // Auto-fill instrumentation if empty or previously auto-filled
        if (_provenance['instrumentation'] != FieldProvenance.manual &&
            match.instrumentation != null) {
          _selectedInstrumentation = match.instrumentation;
          _provenance['instrumentation'] = FieldProvenance.autoFilled;
          widget.onInstrumentationChanged(match.instrumentation);
        }
        // Auto-fill epoch if empty or previously auto-filled
        if (_provenance['epoch'] != FieldProvenance.manual &&
            match.epoch != null) {
          _selectedEpoch = match.epoch;
          _provenance['epoch'] = FieldProvenance.autoFilled;
          widget.onEpochChanged(match.epoch);
        }
      });
    } else {
      // Clear any auto-filled fields when no unique match
      setState(() {
        if (_provenance['difficulty'] == FieldProvenance.autoFilled) {
          _selectedDifficulty = null;
          _provenance['difficulty'] = FieldProvenance.empty;
          widget.onDifficultyChanged(null);
        }
        if (_provenance['instrumentation'] == FieldProvenance.autoFilled) {
          _selectedInstrumentation = null;
          _provenance['instrumentation'] = FieldProvenance.empty;
          widget.onInstrumentationChanged(null);
        }
        if (_provenance['epoch'] == FieldProvenance.autoFilled) {
          _selectedEpoch = null;
          _provenance['epoch'] = FieldProvenance.empty;
          widget.onEpochChanged(null);
        }
      });
    }
    _validateForm();
  }

  /// Auto-populate opus field based on composer, unless user has edited it.
  void _onComposerChanged(String composer) {
    _validateForm();

    // Only auto-populate if opus field is empty or was auto-populated before
    if (!_opusManuallyEdited) {
      final prefix = getCatalogPrefixForComposer(composer);
      if (prefix != null) {
        widget.opusController.text = prefix;
      }
    }

    _triggerAutoFill();
  }

  /// Mark opus as manually edited when user types in it.
  void _onOpusChanged(String _) {
    _opusManuallyEdited = true;
    _validateForm();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      setState(() {
        widget.tags.add(tag);
      });
      _validateForm();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.tags.remove(tag);
    });
    _validateForm();
  }

  Future<void> _pickFiles() async {
    try {
      final files = await widget.filePickerService.pickMultipleFiles(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif'],
      );

      if (files.isNotEmpty && mounted) {
        setState(() {
          widget.selectedFiles.addAll(files);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} file(s) selected'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _getFilePickerErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFilePickerErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission denied. Please grant file access in settings.';
    } else if (errorString.contains('cancelled') || errorString.contains('cancel')) {
      return 'File selection cancelled.';
    } else if (errorString.contains('size') || errorString.contains('large')) {
      return 'File is too large. Please choose a smaller file.';
    } else if (errorString.contains('type') || errorString.contains('extension') || errorString.contains('supported')) {
      return 'Unsupported file type. Please select PDF, JPG, PNG, or GIF files.';
    } else if (errorString.contains('storage') || errorString.contains('disk')) {
      return 'Storage error. Please check your device storage.';
    } else if (errorString.contains('timeout')) {
      return 'File selection took too long. Please try again.';
    } else {
      return 'Unable to select files. Please try again.';
    }
  }

  void _removeFile(String filePath) {
    setState(() {
      widget.selectedFiles.remove(filePath);
    });
  }

  void _submitForm() {
    context.read<AddSheetCubit>().submitForm(
          title: widget.titleController.text,
          composer: widget.composerController.text,
          opus: widget.opusController.text.isEmpty ? null : widget.opusController.text,
          musicalKey: _selectedMusicalKey,
          source: _selectedSource,
          difficulty: _selectedDifficulty,
          instrumentation: _selectedInstrumentation,
          epoch: _selectedEpoch,
          notes: widget.notesController.text,
          tags: widget.tags,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SemanticIconButton(
          icon: Icons.close,
          label: 'Close',
          tooltip: 'Close add sheet music page',
          onPressed: widget.onClose ?? () => context.pop(),
          isDarkBackground: false,
        ),
        title: const Text('Add Sheet Music'),
        elevation: 0,
      ),
      body: BlocBuilder<AddSheetCubit, AddSheetState>(
        builder: (context, state) {
          final isSubmitting = state is AddSheetSubmitting;
          final errors = state is AddSheetInvalid ? state.errors : {};

          return SingleChildScrollView(
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
                          onChanged: (_) {
                            _validateForm();
                            _triggerAutoFill();
                          },
                          onWorkSelected: (title, difficulty, instrumentation) {
                            // Auto-fill difficulty and instrumentation from explicit selection
                            if (difficulty != null &&
                                _provenance['difficulty'] != FieldProvenance.manual) {
                              setState(() {
                                _selectedDifficulty = difficulty;
                                _provenance['difficulty'] = FieldProvenance.autoFilled;
                              });
                              widget.onDifficultyChanged(difficulty);
                            }
                            if (instrumentation != null &&
                                _provenance['instrumentation'] != FieldProvenance.manual) {
                              setState(() {
                                _selectedInstrumentation = instrumentation;
                                _provenance['instrumentation'] = FieldProvenance.autoFilled;
                              });
                              widget.onInstrumentationChanged(instrumentation);
                            }
                            _validateForm();
                            _triggerAutoFill();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: VoiceInputButton(
                          onDictationComplete: (text) {
                            widget.titleController.text = text;
                            _validateForm();
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
                          onChanged: _onComposerChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: VoiceInputButton(
                          onDictationComplete: (text) {
                            widget.composerController.text = text;
                            _validateForm();
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
                  // Auto-populated based on composer, but user can override
                  TextFormField(
                    controller: widget.opusController,
                    enabled: !isSubmitting,
                    onChanged: _onOpusChanged,
                    decoration: InputDecoration(
                      labelText: 'Opus/Catalog Number',
                      hintText: 'e.g., Op. 27, BWV 846, K. 331',
                      helperText: _opusManuallyEdited ? null : 'Auto-filled based on composer',
                      errorText: errors['opus'],
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Musical Key dropdown (optional)
                  MusicalKeyDropdown(
                    selectedValue: _selectedMusicalKey,
                    enabled: !isSubmitting,
                    errorText: errors['musicalKey'],
                    onChanged: (value) {
                      setState(() {
                        _selectedMusicalKey = value;
                      });
                      _validateForm();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Source dropdown (optional)
                  SourceDropdown(
                    selectedValue: _selectedSource,
                    enabled: !isSubmitting,
                    errorText: errors['source'],
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value;
                      });
                      widget.onSourceChanged(value);
                      _validateForm();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Difficulty selector (optional)
                  DifficultySelector(
                    selectedValue: _selectedDifficulty,
                    enabled: !isSubmitting,
                    errorText: errors['difficulty'],
                    isAutoFilled: _provenance['difficulty'] == FieldProvenance.autoFilled,
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value;
                        _provenance['difficulty'] = value != null
                            ? FieldProvenance.manual
                            : FieldProvenance.empty;
                      });
                      widget.onDifficultyChanged(value);
                      _validateForm();
                      _triggerAutoFill();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Instrumentation field (optional)
                  InstrumentationField(
                    selectedValue: _selectedInstrumentation,
                    enabled: !isSubmitting,
                    errorText: errors['instrumentation'],
                    isAutoFilled: _provenance['instrumentation'] == FieldProvenance.autoFilled,
                    onChanged: (value) {
                      setState(() {
                        _selectedInstrumentation = value;
                        _provenance['instrumentation'] = value != null
                            ? FieldProvenance.manual
                            : FieldProvenance.empty;
                      });
                      widget.onInstrumentationChanged(value);
                      _validateForm();
                      _triggerAutoFill();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Epoch dropdown (optional)
                  EpochDropdown(
                    selectedValue: _selectedEpoch,
                    enabled: !isSubmitting,
                    errorText: errors['epoch'],
                    isAutoFilled: _provenance['epoch'] == FieldProvenance.autoFilled,
                    onChanged: (value) {
                      setState(() {
                        _selectedEpoch = value;
                        _provenance['epoch'] = value != null
                            ? FieldProvenance.manual
                            : FieldProvenance.empty;
                      });
                      widget.onEpochChanged(value);
                      _validateForm();
                      _triggerAutoFill();
                    },
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
                          onChanged: (_) => _validateForm(),
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
                            widget.notesController.text = currentText.isEmpty ? text : '$currentText $text';
                            _validateForm();
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SemanticTextField(
                          label: 'Tag Name',
                          hint: 'Enter tag name',
                          onChanged: (value) {
                            _newTag = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                _addTag(_newTag);
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
                              onDeleted: isSubmitting ? null : () => _removeTag(tag),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),

                  // Quick actions - Scan and Library buttons
                  Row(
                    children: [
                      // Library button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSubmitting ? null : () => context.push('/browse'),
                          icon: const Icon(Icons.library_music),
                          label: const Text('Library'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Scan button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  // Navigate to scan camera page for OCR and await result
                                  debugPrint('[AddSheetPage] Navigating to /scan for OCR');
                                  final result = await context.push<Map<String, dynamic>>('/scan');

                                  // If OCR data was returned, populate the form
                                  if (result != null) {
                                    debugPrint('[AddSheetPage] Received OCR data: ${result.keys.join(", ")}');

                                    if (!mounted) {
                                      debugPrint('[AddSheetPage] Widget not mounted, cannot update form');
                                      return;
                                    }

                                    setState(() {
                                      if (result['title'] != null) {
                                        widget.titleController.text = result['title'] as String;
                                        debugPrint('[AddSheetPage] Set title: "${result['title']}"');
                                      }
                                      if (result['composer'] != null) {
                                        widget.composerController.text = result['composer'] as String;
                                        debugPrint('[AddSheetPage] Set composer: "${result['composer']}"');
                                      }
                                      if (result['notes'] != null) {
                                        widget.notesController.text = result['notes'] as String;
                                        debugPrint('[AddSheetPage] Set notes: "${result['notes']}"');
                                      }
                                      if (result['tags'] != null && result['tags'] is List) {
                                        widget.tags.clear();
                                        widget.tags.addAll((result['tags'] as List).cast<String>());
                                        debugPrint('[AddSheetPage] Set tags: ${widget.tags.join(", ")}');
                                      }
                                    });

                                    // Validate the form with the new data
                                    _validateForm();

                                    // Show success message
                                    if (mounted) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Form populated with scanned data'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    debugPrint('[AddSheetPage] Scan returned null (user cancelled)');
                                  }
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider with "OR" text
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // File picker section - using enhanced drop zone widget
                  FilePickerDropZone(
                    selectedFiles: widget.selectedFiles,
                    onPickFiles: _pickFiles,
                    onRemoveFile: _removeFile,
                    isSubmitting: isSubmitting,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          (isSubmitting || state is AddSheetInvalid || state is AddSheetInitial) ? null : _submitForm,
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
                        isSubmitting ? 'Adding...' : 'Add Sheet Music',
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
          );
        },
      ),
    );
  }
}
