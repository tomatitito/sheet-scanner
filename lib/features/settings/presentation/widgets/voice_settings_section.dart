import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/services/api_key_service.dart';
import 'package:sheet_scanner/core/services/dictation_post_processor.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service_factory.dart';

/// Settings section for voice recognition configuration.
class VoiceSettingsSection extends StatefulWidget {
  const VoiceSettingsSection({super.key});

  @override
  State<VoiceSettingsSection> createState() => _VoiceSettingsSectionState();
}

class _VoiceSettingsSectionState extends State<VoiceSettingsSection> {
  SpeechRecognitionEngine _currentEngine =
      SpeechRecognitionServiceFactory.currentEngine;
  bool _hasApiKey = false;
  bool _aiPostProcessingEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hasKey = await SpeechRecognitionServiceFactory.isApiKeyConfigured();
    final aiPostProcessing = await DictationPostProcessor.isEnabled();
    setState(() {
      _hasApiKey = hasKey;
      _aiPostProcessingEnabled = aiPostProcessing;
      _isLoading = false;
    });
  }

  Future<void> _onEngineChanged(SpeechRecognitionEngine? engine) async {
    if (engine == null) return;

    // If selecting OpenAI, require API key
    if (engine == SpeechRecognitionEngine.openaiWhisper && !_hasApiKey) {
      final configured = await _showApiKeyDialog();
      if (!configured) return;
    }

    // If selecting Hybrid and no API key, prompt but allow to proceed
    // (hybrid can fall back to local mode)
    if (engine == SpeechRecognitionEngine.hybrid && !_hasApiKey) {
      final configured = await _showApiKeyDialog(optional: true);
      // Update hasApiKey state if user configured it
      if (configured) {
        setState(() {
          _hasApiKey = true;
        });
      }
      // Continue regardless - hybrid works without API key (local fallback)
    }

    await SpeechRecognitionServiceFactory.setEngine(engine);
    setState(() {
      _currentEngine = engine;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Voice engine changed to ${SpeechRecognitionServiceFactory.getEngineName(engine)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _showApiKeyDialog({bool optional = false}) async {
    final controller = TextEditingController();
    final apiKeyService = getIt<ApiKeyService>();

    // Pre-fill with existing key if any
    final existingKey = await apiKeyService.getOpenAiApiKey();
    controller.text = existingKey;

    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: optional,
      builder: (dialogContext) => _ApiKeyDialog(
        controller: controller,
        optional: optional,
        onSave: (key) async {
          // For optional mode, allow empty key (skip configuration)
          if (optional && key.isEmpty) {
            return true;
          }

          final validationError = ApiKeyService.validateApiKey(key);
          if (validationError != null) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(validationError),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }

          await apiKeyService.setOpenAiApiKey(key);
          await SpeechRecognitionServiceFactory.refreshApiKey();
          return true;
        },
      ),
    );

    if (result == true) {
      setState(() {
        _hasApiKey = true;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Voice Recognition',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Engine selection
              ListTile(
                title: const Text('Recognition Engine'),
                subtitle: Text(SpeechRecognitionServiceFactory.getEngineName(
                    _currentEngine)),
                trailing: const Icon(Icons.mic),
                onTap: _showEngineSelectionSheet,
              ),

              // API Key configuration (for OpenAI and Hybrid modes)
              if (_currentEngine == SpeechRecognitionEngine.openaiWhisper ||
                  _currentEngine == SpeechRecognitionEngine.hybrid) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text('OpenAI API Key'),
                  subtitle: Text(_hasApiKey
                      ? 'Configured ✓'
                      : _currentEngine == SpeechRecognitionEngine.hybrid
                          ? 'Optional - using local mode'
                          : 'Not configured'),
                  trailing: Icon(
                    _hasApiKey
                        ? Icons.check_circle
                        : _currentEngine == SpeechRecognitionEngine.hybrid
                            ? Icons.info_outline
                            : Icons.warning,
                    color: _hasApiKey
                        ? Colors.green
                        : _currentEngine == SpeechRecognitionEngine.hybrid
                            ? Colors.blue
                            : Colors.orange,
                  ),
                  onTap: () => _showApiKeyDialog(
                    optional:
                        _currentEngine == SpeechRecognitionEngine.hybrid,
                  ),
                ),
              ],

              // AI Post-Processing toggle
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('AI Text Cleanup'),
                subtitle: Text(
                  _hasApiKey
                      ? 'Auto-fix punctuation, music terms, and composer names'
                      : 'Requires OpenAI API key for full AI cleanup',
                ),
                value: _aiPostProcessingEnabled,
                onChanged: _hasApiKey
                    ? (value) async {
                        final messenger = ScaffoldMessenger.of(context);
                        await DictationPostProcessor.setEnabled(value);
                        setState(() {
                          _aiPostProcessingEnabled = value;
                        });
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(value
                                  ? 'AI text cleanup enabled'
                                  : 'AI text cleanup disabled (using local rules)'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                secondary: Icon(
                  Icons.auto_fix_high,
                  color: _aiPostProcessingEnabled && _hasApiKey
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),

              // Engine description
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        SpeechRecognitionServiceFactory.getEngineDescription(
                            _currentEngine),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
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

  void _showEngineSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Voice Recognition Engine',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...SpeechRecognitionEngine.values.map((engine) {
              final isSelected = engine == _currentEngine;
              final needsApiKey =
                  engine == SpeechRecognitionEngine.openaiWhisper &&
                      !_hasApiKey;
              final optionalApiKey =
                  engine == SpeechRecognitionEngine.hybrid && !_hasApiKey;

              return ListTile(
                leading: Icon(
                  _getEngineIcon(engine),
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(
                  SpeechRecognitionServiceFactory.getEngineName(engine),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                    SpeechRecognitionServiceFactory.getEngineDescription(
                        engine)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (needsApiKey)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Needs API Key',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    if (optionalApiKey)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'API Key Optional',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _onEngineChanged(engine);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getEngineIcon(SpeechRecognitionEngine engine) {
    switch (engine) {
      case SpeechRecognitionEngine.deviceNative:
        return Icons.phone_android;
      case SpeechRecognitionEngine.whisperLocal:
        return Icons.offline_bolt;
      case SpeechRecognitionEngine.openaiWhisper:
        return Icons.cloud;
      case SpeechRecognitionEngine.hybrid:
        return Icons.cloud_sync;
    }
  }
}

/// Dialog for entering the OpenAI API key.
class _ApiKeyDialog extends StatefulWidget {
  final TextEditingController controller;
  final Future<bool> Function(String key) onSave;
  final bool optional;

  const _ApiKeyDialog({
    required this.controller,
    required this.onSave,
    this.optional = false,
  });

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  bool _obscureText = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('OpenAI API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.optional
                ? 'Add your OpenAI API key for high-quality cloud transcription, or skip to use local offline mode.'
                : 'Enter your OpenAI API key to use high-quality cloud transcription.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.optional ? 'API Key (optional)' : 'API Key',
              hintText: 'sk-...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 12),
          Text(
            'Your API key is stored securely on your device and never shared.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (widget.optional) ...[
            const SizedBox(height: 8),
            Text(
              'Without an API key, dictation uses local processing which works offline but may be less accurate.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (widget.optional)
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context, true),
            child: const Text('Skip'),
          )
        else
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        FilledButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final navigator = Navigator.of(context);

                  setState(() {
                    _isSaving = true;
                  });

                  final success =
                      await widget.onSave(widget.controller.text.trim());

                  if (!mounted) return;

                  setState(() {
                    _isSaving = false;
                  });

                  if (success) {
                    navigator.pop(true);
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
