import 'package:flutter/material.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';

/// Language selector dropdown for voice dictation.
///
/// Allows users to choose their preferred language for speech recognition.
/// Integrates with the DictationCubit to set the language.
class LanguageSelector extends StatefulWidget {
  /// Callback when language is changed
  final ValueChanged<String>? onLanguageChanged;

  /// Available languages to display (language codes like 'en_US', 'es_ES')
  final List<String> availableLanguages;

  /// Initial selected language
  final String initialLanguage;

  const LanguageSelector({
    super.key,
    this.onLanguageChanged,
    this.availableLanguages = const [
      'en_US',
      'en_GB',
      'es_ES',
      'es_MX',
      'fr_FR',
      'de_DE',
      'it_IT',
      'pt_BR',
      'ja_JP',
      'zh_CN',
      'zh_TW',
      'ko_KR',
    ],
    this.initialLanguage = 'en_US',
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _selectedLanguage;
  late DictationCubit _dictationCubit;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _dictationCubit = getIt<DictationCubit>();
  }

  /// Map language codes to human-readable names
  String _getLanguageName(String languageCode) {
    final languageNames = {
      'en_US': 'English (US)',
      'en_GB': 'English (UK)',
      'es_ES': 'Spanish (Spain)',
      'es_MX': 'Spanish (Mexico)',
      'fr_FR': 'French',
      'de_DE': 'German',
      'it_IT': 'Italian',
      'pt_BR': 'Portuguese (Brazil)',
      'ja_JP': 'Japanese',
      'zh_CN': 'Chinese (Simplified)',
      'zh_TW': 'Chinese (Traditional)',
      'ko_KR': 'Korean',
    };
    return languageNames[languageCode] ?? languageCode;
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage != null && newLanguage != _selectedLanguage) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
      _dictationCubit.setLanguage(newLanguage);
      widget.onLanguageChanged?.call(newLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedLanguage,
      onChanged: _onLanguageChanged,
      isExpanded: false,
      items: widget.availableLanguages
          .map<DropdownMenuItem<String>>(
            (String language) => DropdownMenuItem<String>(
              value: language,
              child: Text(_getLanguageName(language)),
            ),
          )
          .toList(),
    );
  }
}
