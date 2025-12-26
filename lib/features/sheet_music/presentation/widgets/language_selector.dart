import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';

/// Language selector dropdown for voice dictation.
///
/// Allows users to choose their preferred language for speech recognition.
/// Dynamically loads available languages from the device's speech recognition
/// service to ensure only supported locales are offered to the user.
class LanguageSelector extends StatefulWidget {
  /// Callback when language is changed
  final ValueChanged<String>? onLanguageChanged;

  /// Initial selected language
  final String initialLanguage;

  const LanguageSelector({
    super.key,
    this.onLanguageChanged,
    this.initialLanguage = 'en_US',
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _selectedLanguage;
  late DictationCubit _dictationCubit;
  late SpeechRecognitionService _speechService;
  List<String> _availableLocaleIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _dictationCubit = getIt<DictationCubit>();
    _speechService = getIt<SpeechRecognitionService>();
    _loadAvailableLanguages();
  }

  /// Load available languages from the device's speech recognition service
  Future<void> _loadAvailableLanguages() async {
    try {
      final locales = await _speechService.availableLanguages;
      if (mounted) {
        setState(() {
          _availableLocaleIds = locales;
          _isLoading = false;
        });
        // Initialize the cubit with available locales
        await _dictationCubit.initializeAvailableLanguages(locales);
      }
    } catch (e) {
      debugPrint('Error loading available languages: $e');
      // Fallback to English
      if (mounted) {
        setState(() {
          _availableLocaleIds = ['en_US', 'en_GB'];
          _isLoading = false;
        });
      }
    }
  }

  /// Map locale ID to human-readable language name
  String _getLanguageName(String localeId) {
    // Parse the locale ID (e.g., 'de-DE', 'de_DE', 'de')
    final parts = localeId.split(RegExp(r'[-_]'));
    final langCode = parts[0].toLowerCase();
    final countryCode = parts.length > 1 ? parts[1].toUpperCase() : '';

    // Map language codes to readable names
    final languageNames = {
      'en': 'English',
      'de': 'German',
      'es': 'Spanish',
      'fr': 'French',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ja': 'Japanese',
      'zh': 'Chinese',
      'ko': 'Korean',
      'nl': 'Dutch',
      'ru': 'Russian',
      'pl': 'Polish',
      'tr': 'Turkish',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'th': 'Thai',
      'vi': 'Vietnamese',
    };

    final country = {
      'US': '(US)',
      'GB': '(UK)',
      'DE': '(Germany)',
      'FR': '(France)',
      'ES': '(Spain)',
      'IT': '(Italy)',
      'BR': '(Brazil)',
      'CN': '(Simplified)',
      'TW': '(Traditional)',
      'MX': '(Mexico)',
      'IN': '(India)',
    };

    final baseName = languageNames[langCode] ?? langCode.toUpperCase();
    if (countryCode.isNotEmpty && country.containsKey(countryCode)) {
      return '$baseName ${country[countryCode]}';
    } else if (countryCode.isNotEmpty) {
      return '$baseName ($countryCode)';
    }
    return baseName;
  }

  void _onLanguageChanged(String? newLocaleId) {
    if (newLocaleId != null && newLocaleId != _selectedLanguage) {
      setState(() {
        _selectedLanguage = newLocaleId;
      });
      // Pass the actual device locale ID to the cubit
      _dictationCubit.setLanguage(newLocaleId);
      widget.onLanguageChanged?.call(newLocaleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 150,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_availableLocaleIds.isEmpty) {
      return Text(
        'No languages available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
      );
    }

    // Ensure selected language is in the available list, otherwise use first available
    if (!_availableLocaleIds.contains(_selectedLanguage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _availableLocaleIds.isNotEmpty) {
          final newSelection = _availableLocaleIds[0];
          setState(() {
            _selectedLanguage = newSelection;
          });
          _dictationCubit.setLanguage(newSelection);
        }
      });
    }

    return DropdownButton<String>(
      value: _selectedLanguage,
      onChanged: _onLanguageChanged,
      isExpanded: false,
      isDense: true,
      items: _availableLocaleIds
          .map<DropdownMenuItem<String>>(
            (String localeId) => DropdownMenuItem<String>(
              value: localeId,
              child: Text(_getLanguageName(localeId)),
            ),
          )
          .toList(),
    );
  }
}
