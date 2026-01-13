import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/ocr_review_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/ocr_review_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/composer_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/title_autocomplete_field.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/musical_key_dropdown.dart';

/// Page for reviewing and editing OCR-detected sheet music metadata
///
/// Displays OCR-detected title and composer with a confidence indicator,
/// allowing users to correct any misdetections before saving.
/// Also provides options to add tags and notes.
class OCRReviewPage extends StatefulWidget {
  final String detectedTitle;
  final String detectedComposer;
  final double confidence;
  final File capturedImage;
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;

  const OCRReviewPage({
    super.key,
    required this.detectedTitle,
    required this.detectedComposer,
    required this.confidence,
    required this.capturedImage,
    this.onSuccess,
    this.onClose,
  });

  @override
  State<OCRReviewPage> createState() => _OCRReviewPageState();
}

class _OCRReviewPageState extends State<OCRReviewPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _composerController;
  late final TextEditingController _opusController;
  late final TextEditingController _notesController;
  String? _selectedMusicalKey;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.detectedTitle);
    _composerController = TextEditingController(text: widget.detectedComposer);
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
    context.read<OCRReviewCubit>().validate(
          title: value,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onComposerChanged(String value) {
    context.read<OCRReviewCubit>().validate(
          title: _titleController.text,
          composer: value,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onOpusChanged(String value) {
    context.read<OCRReviewCubit>().validate(
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
    context.read<OCRReviewCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: value,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _onNotesChanged(String value) {
    context.read<OCRReviewCubit>().validate(
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
      context.read<OCRReviewCubit>().validate(
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
    context.read<OCRReviewCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );
  }

  void _submitForm() {
    // Validate the form first
    context.read<OCRReviewCubit>().validate(
          title: _titleController.text,
          composer: _composerController.text,
          opus: _opusController.text.isEmpty ? null : _opusController.text,
          musicalKey: _selectedMusicalKey,
          notes: _notesController.text,
          tags: _tags,
        );

    // Return the OCR data to the previous page
    final isValid = context.read<OCRReviewCubit>().state.maybeWhen(
          initialized: (dTitle, dComposer, conf, image, eTitle, eComposer,
                  eNotes, tags, isValid, errors, isSubmitting, error) =>
              isValid,
          orElse: () => false,
        );

    if (isValid) {
      // Pop with OCR data to return to previous page (ScanCameraPage or AddSheetPage)
      final result = {
        'title': _titleController.text.trim(),
        'composer': _composerController.text.trim(),
        'opus':
            _opusController.text.isEmpty ? null : _opusController.text.trim(),
        'musicalKey': _selectedMusicalKey,
        'notes':
            _notesController.text.isEmpty ? null : _notesController.text.trim(),
        'tags': List<String>.from(_tags),
      };

      if (mounted) {
        context.pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OCRReviewCubit>()
        ..initializeWithOCRResult(
          detectedTitle: widget.detectedTitle,
          detectedComposer: widget.detectedComposer,
          confidence: widget.confidence,
          capturedImage: widget.capturedImage,
        ),
      child: _OCRReviewForm(
        capturedImage: widget.capturedImage,
        confidence: widget.confidence,
        titleController: _titleController,
        composerController: _composerController,
        opusController: _opusController,
        notesController: _notesController,
        musicalKey: _selectedMusicalKey,
        onMusicalKeyChanged: _onMusicalKeyChanged,
        tags: _tags,
        onTitleChanged: _onTitleChanged,
        onComposerChanged: _onComposerChanged,
        onOpusChanged: _onOpusChanged,
        onNotesChanged: _onNotesChanged,
        onAddTag: _addTag,
        onRemoveTag: _removeTag,
        onSubmit: _submitForm,
        onClose: widget.onClose,
      ),
    );
  }
}

class _OCRReviewForm extends StatefulWidget {
  final File capturedImage;
  final double confidence;
  final TextEditingController titleController;
  final TextEditingController composerController;
  final TextEditingController opusController;
  final TextEditingController notesController;
  final String? musicalKey;
  final ValueChanged<String?> onMusicalKeyChanged;
  final List<String> tags;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onComposerChanged;
  final ValueChanged<String> onOpusChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;
  final VoidCallback onSubmit;
  final VoidCallback? onClose;

  const _OCRReviewForm({
    required this.capturedImage,
    required this.confidence,
    required this.titleController,
    required this.composerController,
    required this.opusController,
    required this.notesController,
    this.musicalKey,
    required this.onMusicalKeyChanged,
    required this.tags,
    required this.onTitleChanged,
    required this.onComposerChanged,
    required this.onOpusChanged,
    required this.onNotesChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSubmit,
    this.onClose,
  });

  @override
  State<_OCRReviewForm> createState() => _OCRReviewFormState();
}

class _OCRReviewFormState extends State<_OCRReviewForm> {
  String _newTag = '';

  /// Get confidence badge color and icon
  Map<String, dynamic> _getConfidenceStyle(double confidence) {
    if (confidence > 0.9) {
      return {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'label': 'Looks good!',
      };
    } else if (confidence > 0.7) {
      return {
        'color': Colors.orange,
        'icon': Icons.warning,
        'label': 'Please verify',
      };
    } else {
      return {
        'color': Colors.red,
        'icon': Icons.error,
        'label': 'Check carefully',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose ?? () => context.pop(),
        ),
        title: const Text('Review & Edit'),
        actions: [
          BlocBuilder<OCRReviewCubit, OCRReviewState>(
            builder: (context, state) {
              final isValid = state.maybeWhen(
                initialized: (dTitle, dComposer, conf, image, eTitle, eComposer,
                        eNotes, tags, isValid, errors, isSubmitting, error) =>
                    isValid,
                orElse: () => false,
              );
              return TextButton(
                onPressed: !isValid ? null : widget.onSubmit,
                child: const Text('Use These Values'),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: BlocBuilder<OCRReviewCubit, OCRReviewState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            initialized: (
              detectedTitle,
              detectedComposer,
              confidence,
              capturedImage,
              editedTitle,
              editedComposer,
              editedNotes,
              tags,
              isValid,
              errors,
              isSubmitting,
              error,
            ) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: isSmallScreen
                    ? _buildMobileLayout(
                        context,
                        errors,
                        isSubmitting,
                        widget.confidence,
                      )
                    : _buildDesktopLayout(
                        context,
                        errors,
                        isSubmitting,
                        widget.confidence,
                      ),
              );
            },
            success: (_, __) => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Sheet music saved successfully!'),
              ),
            ),
            error: (message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error: $message'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, String> errors,
    bool isSubmitting,
    double confidence,
  ) {
    final confidenceStyle = _getConfidenceStyle(confidence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover image preview
        GestureDetector(
          onTap: () => _showImagePreview(context),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Image.file(
              widget.capturedImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title field with autocomplete (based on composer)
        Text(
          'Title',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TitleAutocompleteField(
          controller: widget.titleController,
          composerName: widget.composerController.text,
          enabled: !isSubmitting,
          errorText: errors['title'],
          onChanged: widget.onTitleChanged,
        ),
        const SizedBox(height: 16),

        // Composer field with autocomplete
        Text(
          'Composer',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ComposerAutocompleteField(
          controller: widget.composerController,
          enabled: !isSubmitting,
          errorText: errors['composer'],
          onChanged: widget.onComposerChanged,
        ),
        const SizedBox(height: 16),

        // Opus/Catalog number field (optional)
        Text(
          'Opus/Catalog Number',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.opusController,
          enabled: !isSubmitting,
          onChanged: widget.onOpusChanged,
          decoration: InputDecoration(
            hintText: 'e.g., Op. 27, BWV 846, K. 331',
            errorText: errors['opus'],
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Musical Key dropdown (optional)
        Text(
          'Musical Key',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        MusicalKeyDropdown(
          selectedValue: widget.musicalKey,
          enabled: !isSubmitting,
          errorText: errors['musicalKey'],
          onChanged: widget.onMusicalKeyChanged,
        ),
        const SizedBox(height: 16),

        // Tags section
        Text(
          'Tags',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted:
                        isSubmitting ? null : () => widget.onRemoveTag(tag),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),

        // Notes field
        Text(
          'Notes (optional)',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.notesController,
          enabled: !isSubmitting,
          onChanged: widget.onNotesChanged,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes about the piece...',
            errorText: errors['notes'],
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Confidence indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (confidenceStyle['color'] as Color).withAlpha(51),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: confidenceStyle['color'] as Color, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                confidenceStyle['icon'] as IconData,
                color: confidenceStyle['color'] as Color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OCR Confidence: ${(widget.confidence * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      confidenceStyle['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSubmitting
                    ? null
                    : (widget.onClose ?? () => context.pop()),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onSubmit,
                icon: const Icon(Icons.check),
                label: const Text('Use These Values'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, String> errors,
    bool isSubmitting,
    double confidence,
  ) {
    final confidenceStyle = _getConfidenceStyle(confidence);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Image preview
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImagePreview(context),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Image.file(
                    widget.capturedImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          // Go back to scan page to capture a new image
                          context.go('/scan');
                        },
                  child: const Text('Change Image'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Right column: Form fields
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Text(
                'Title *',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.titleController,
                enabled: !isSubmitting,
                onChanged: widget.onTitleChanged,
                decoration: InputDecoration(
                  hintText: 'Enter sheet music title',
                  errorText: errors['title'],
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Composer field
              Text(
                'Composer *',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.composerController,
                enabled: !isSubmitting,
                onChanged: widget.onComposerChanged,
                decoration: InputDecoration(
                  hintText: 'Enter composer name',
                  errorText: errors['composer'],
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Opus/Catalog number field (optional)
              Text(
                'Opus/Catalog Number',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.opusController,
                enabled: !isSubmitting,
                onChanged: widget.onOpusChanged,
                decoration: InputDecoration(
                  hintText: 'e.g., Op. 27, BWV 846, K. 331',
                  errorText: errors['opus'],
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Musical Key dropdown (optional)
              Text(
                'Musical Key',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              MusicalKeyDropdown(
                selectedValue: widget.musicalKey,
                enabled: !isSubmitting,
                errorText: errors['musicalKey'],
                onChanged: widget.onMusicalKeyChanged,
              ),
              const SizedBox(height: 16),

              // Tags section
              Text(
                'Tags',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.tags.isNotEmpty) ...[
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
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              _newTag = value;
                            },
                            enabled: !isSubmitting,
                            decoration: const InputDecoration(
                              hintText: 'Add tag',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  widget.onAddTag(_newTag);
                                  _newTag = '';
                                },
                          child: const Text('+ Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes field
              Text(
                'Notes',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.notesController,
                enabled: !isSubmitting,
                onChanged: widget.onNotesChanged,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Optional notes about the piece...',
                  errorText: errors['notes'],
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Confidence indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (confidenceStyle['color'] as Color).withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: confidenceStyle['color'] as Color, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      confidenceStyle['icon'] as IconData,
                      color: confidenceStyle['color'] as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OCR Confidence: ${(widget.confidence * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            confidenceStyle['label'] as String,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(widget.capturedImage),
      ),
    );
  }
}
