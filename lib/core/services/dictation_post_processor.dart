import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for post-processing dictation text using AI or local rules.
/// 
/// Features:
/// - Automatic punctuation and capitalization correction
/// - Music terminology normalization (Opus, BWV, K., etc.)
/// - Composer name capitalization
/// - Number formatting for catalog numbers
class DictationPostProcessor {
  static const String _aiPostProcessingKey = 'dictation_ai_post_processing';
  static const String _openAiChatUrl = 'https://api.openai.com/v1/chat/completions';
  
  final String Function() _getApiKey;
  final http.Client _httpClient;
  
  DictationPostProcessor({
    required String Function() getApiKey,
    http.Client? httpClient,
  }) : _getApiKey = getApiKey,
       _httpClient = httpClient ?? http.Client();
  
  /// Check if AI post-processing is enabled in settings.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiPostProcessingKey) ?? false;
  }
  
  /// Enable or disable AI post-processing.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiPostProcessingKey, enabled);
  }
  
  /// Process the transcribed text to clean it up.
  /// 
  /// If AI post-processing is enabled and API key is available, uses GPT.
  /// Otherwise, applies local rule-based corrections.
  Future<String> processText(String text) async {
    if (text.isEmpty) return text;
    
    final enabled = await isEnabled();
    final apiKey = _getApiKey();
    
    if (enabled && apiKey.isNotEmpty) {
      try {
        return await _processWithAI(text, apiKey);
      } catch (e) {
        debugPrint('AI post-processing failed, falling back to local rules: $e');
        return _processWithLocalRules(text);
      }
    }
    
    return _processWithLocalRules(text);
  }
  
  /// Process text using OpenAI's GPT model.
  Future<String> _processWithAI(String text, String apiKey) async {
    final response = await _httpClient.post(
      Uri.parse(_openAiChatUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '''You are a text post-processor for a sheet music cataloging app. 
Your task is to clean up dictated text for music metadata fields.

Rules:
1. Fix punctuation and capitalization
2. Normalize music terminology:
   - "opus" → "Op."
   - "opus number" → "Op."
   - "bach werkverzeichnis" or "BWV" → "BWV"
   - "köchel" or "koechel" → "K."
   - "hoboken" → "Hob."
3. Capitalize composer names properly
4. Format catalog numbers: "opus 27 number 2" → "Op. 27, No. 2"
5. Keep the meaning and content identical - only fix formatting
6. Respond with ONLY the corrected text, no explanations'''
          },
          {
            'role': 'user',
            'content': text,
          }
        ],
        'temperature': 0.1,
        'max_tokens': 500,
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          debugPrint('AI post-processed: "$text" → "$content"');
          return content.trim();
        }
      }
    }
    
    debugPrint('AI post-processing returned status ${response.statusCode}');
    return text;
  }
  
  /// Apply local rule-based corrections for music terminology.
  String _processWithLocalRules(String text) {
    var result = text;
    
    // Capitalize first letter
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }
    
    // Music terminology normalization (case-insensitive replacements)
    final replacements = <RegExp, String>{
      // Opus formats
      RegExp(r'\bopus\s+number\s+', caseSensitive: false): 'Op. ',
      RegExp(r'\bopus\s+', caseSensitive: false): 'Op. ',
      RegExp(r'\bop\s+', caseSensitive: false): 'Op. ',
      
      // Catalog systems
      RegExp(r'\bbach\s+werkverzeichnis\s+', caseSensitive: false): 'BWV ',
      RegExp(r'\bbwv\s+', caseSensitive: false): 'BWV ',
      RegExp(r'\bköchel\s+', caseSensitive: false): 'K. ',
      RegExp(r'\bkoechel\s+', caseSensitive: false): 'K. ',
      RegExp(r'\bhoboken\s+', caseSensitive: false): 'Hob. ',
      RegExp(r'\bdeutsch\s+', caseSensitive: false): 'D. ',
      
      // Number formatting
      RegExp(r'\bnumber\s+', caseSensitive: false): 'No. ',
      RegExp(r'\bno\s+', caseSensitive: false): 'No. ',
      RegExp(r'\bnr\s+', caseSensitive: false): 'No. ',
      
      // Key signatures
      RegExp(r'\bflat\b', caseSensitive: false): '♭',
      RegExp(r'\bsharp\b', caseSensitive: false): '♯',
      RegExp(r'\bmajor\b', caseSensitive: false): 'major',
      RegExp(r'\bminor\b', caseSensitive: false): 'minor',
    };
    
    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    
    // Common composer name capitalizations
    final composers = [
      'Bach', 'Mozart', 'Beethoven', 'Chopin', 'Liszt', 'Brahms',
      'Schumann', 'Schubert', 'Debussy', 'Ravel', 'Rachmaninoff',
      'Prokofiev', 'Shostakovich', 'Tchaikovsky', 'Haydn', 'Handel',
      'Vivaldi', 'Mendelssohn', 'Grieg', 'Dvorak', 'Sibelius',
    ];
    
    for (final composer in composers) {
      result = result.replaceAllMapped(
        RegExp('\\b${composer.toLowerCase()}\\b', caseSensitive: false),
        (match) => composer,
      );
    }
    
    // Clean up multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Ensure proper spacing after punctuation
    result = result.replaceAll(RegExp(r'\.(?=[A-Za-z])'), '. ');
    result = result.replaceAll(RegExp(r',(?=[A-Za-z])'), ', ');
    
    debugPrint('Local post-processed: "$text" → "$result"');
    return result;
  }
}
