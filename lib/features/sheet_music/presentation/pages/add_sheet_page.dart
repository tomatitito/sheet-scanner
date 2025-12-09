import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/data/services/file_picker_service.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/file_picker_drop_zone.dart';

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
    _filePickerService = FilePickerServiceImpl();
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
              Navigator.pop(context);
            }
          } else if (state is AddSheetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.failure.toString()}'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose ?? () => Navigator.pop(context),
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
                  // Title field
                  TextFormField(
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
                  const SizedBox(height: 16),

                  // Composer field
                  TextFormField(
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
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
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
