import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/accessibility/semantic_widgets.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/data/services/file_picker_service.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/file_picker_drop_zone.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/voice_input_button.dart';

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
  late final TextEditingController _notesController;
  final List<String> _tags = [];
  final List<String> _selectedFiles = [];
  late final FilePickerService _filePickerService;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _composerController = TextEditingController();
    _notesController = TextEditingController();
    _filePickerService = getIt<FilePickerService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _composerController.dispose();
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
                content: Text(
                    'Sheet music "${state.sheetMusic.title}" added successfully'),
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
          notesController: _notesController,
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
  final TextEditingController notesController;
  final List<String> tags;
  final List<String> selectedFiles;
  final FilePickerService filePickerService;
  final VoidCallback? onClose;

  const _AddSheetForm({
    required this.titleController,
    required this.composerController,
    required this.notesController,
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

  void _validateForm() {
    final cubit = context.read<AddSheetCubit>();
    cubit.validate(
      title: widget.titleController.text,
      composer: widget.composerController.text,
      notes: widget.notesController.text,
      tags: widget.tags,
    );
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
                  // Title field with voice input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.titleController,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            hintText: 'Enter sheet music title',
                            errorText: errors['title'],
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.title),
                          ),
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

                  // Composer field with voice input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.composerController,
                          enabled: !isSubmitting,
                          onChanged: (_) => _validateForm(),
                          decoration: InputDecoration(
                            labelText: 'Composer *',
                            hintText: 'Enter composer name',
                            errorText: errors['composer'],
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                          ),
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
                            widget.notesController.text = currentText.isEmpty
                                ? text
                                : '$currentText $text';
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                              onDeleted:
                                  isSubmitting ? null : () => _removeTag(tag),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),

                  // Scan button - OCR text recognition
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              // Navigate to scan camera page for OCR and await result
                              debugPrint(
                                  '[AddSheetPage] Navigating to /scan for OCR');
                              final result = await context
                                  .push<Map<String, dynamic>>('/scan');

                              // If OCR data was returned, populate the form
                              if (result != null) {
                                debugPrint(
                                    '[AddSheetPage] Received OCR data: ${result.keys.join(", ")}');

                                if (!mounted) {
                                  debugPrint(
                                      '[AddSheetPage] Widget not mounted, cannot update form');
                                  return;
                                }

                                setState(() {
                                  if (result['title'] != null) {
                                    widget.titleController.text =
                                        result['title'] as String;
                                    debugPrint(
                                        '[AddSheetPage] Set title: "${result['title']}"');
                                  }
                                  if (result['composer'] != null) {
                                    widget.composerController.text =
                                        result['composer'] as String;
                                    debugPrint(
                                        '[AddSheetPage] Set composer: "${result['composer']}"');
                                  }
                                  if (result['notes'] != null) {
                                    widget.notesController.text =
                                        result['notes'] as String;
                                    debugPrint(
                                        '[AddSheetPage] Set notes: "${result['notes']}"');
                                  }
                                  if (result['tags'] != null &&
                                      result['tags'] is List) {
                                    widget.tags.clear();
                                    widget.tags.addAll((result['tags'] as List)
                                        .cast<String>());
                                    debugPrint(
                                        '[AddSheetPage] Set tags: ${widget.tags.join(", ")}');
                                  }
                                });

                                // Validate the form with the new data
                                _validateForm();

                                // Show success message
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Form populated with scanned data'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                debugPrint(
                                    '[AddSheetPage] Scan returned null (user cancelled)');
                              }
                            },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Sheet Music'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider with "OR" text
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
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
                      onPressed: (isSubmitting ||
                              state is AddSheetInvalid ||
                              state is AddSheetInitial)
                          ? null
                          : _submitForm,
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
