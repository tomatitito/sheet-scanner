import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'speech_recognition_service.dart';

/// Implementation of speech recognition using OpenAI's Whisper API.
///
/// Uses the cloud-based Whisper Large V3 model for high-accuracy transcription.
/// Requires an OpenAI API key to be configured.
class OpenAIWhisperService implements SpeechRecognitionService {
  static const String _apiUrl =
      'https://api.openai.com/v1/audio/transcriptions';
  static const String _model = 'whisper-1';

  final String Function() _getApiKey;
  final AudioRecorder _audioRecorder;
  final http.Client _httpClient;

  bool _isListening = false;
  String? _currentAudioPath;
  Timer? _autoStopTimer;

  OpenAIWhisperService({
    required String Function() getApiKey,
    AudioRecorder? audioRecorder,
    http.Client? httpClient,
  })  : _getApiKey = getApiKey,
        _audioRecorder = audioRecorder ?? AudioRecorder(),
        _httpClient = httpClient ?? http.Client();

  @override
  Future<bool> initialize() async {
    try {
      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        debugPrint('OpenAI Whisper: No API key configured');
        return false;
      }
      debugPrint('OpenAI Whisper: Initialized with API key');
      return true;
    } catch (e) {
      debugPrint('Error initializing OpenAI Whisper: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Check API key first
      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        debugPrint('OpenAI Whisper unavailable: No API key configured');
        return false;
      }

      // Check microphone permission
      final micStatus = await Permission.microphone.request();
      if (micStatus.isDenied) {
        debugPrint('Microphone permission denied by user');
        return false;
      } else if (micStatus.isPermanentlyDenied) {
        debugPrint('Microphone permission permanently denied');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking OpenAI Whisper availability: $e');
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    String language = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    try {
      debugPrint(
          '[OpenAI] startListening called with listenFor=${listenFor.inSeconds}s');

      // Verify availability before attempting to listen
      if (!await isAvailable()) {
        final apiKey = _getApiKey();
        if (apiKey.isEmpty) {
          onError(
              'OpenAI API key not configured. Please add your API key in Settings.');
        } else {
          onError('Microphone permission not granted');
        }
        return;
      }

      _isListening = true;

      // Emit listening started event (empty partial result)
      onResult('', false);

      // Start recording audio to a temporary file
      final audioPath = await _startAudioRecording();
      if (audioPath == null) {
        _isListening = false;
        onError('Failed to start audio recording');
        return;
      }

      _currentAudioPath = audioPath;
      debugPrint('[OpenAI] Audio recording started at: $audioPath');

      // Schedule auto-stop after listen duration
      _autoStopTimer = Timer(listenFor, () async {
        debugPrint(
            '[OpenAI] Auto-stop timer fired after ${listenFor.inSeconds}s');
        if (_isListening) {
          await _stopAndTranscribe(onResult, onError, language);
        }
      });
    } catch (e) {
      debugPrint('ERROR: Exception during OpenAI startListening: $e');
      onError('OpenAI Whisper error: ${e.toString()}');
      _isListening = false;
      await _cleanupAudioFile();
    }
  }

  Future<String?> _startAudioRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // OpenAI supports multiple formats; using mp3 for smaller file size
      final audioPath = '${tempDir.path}/openai_whisper_$timestamp.mp3';

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc, // AAC for better compression
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 64000,
      );

      debugPrint('[OpenAI] Starting audio recording to: $audioPath');
      await _audioRecorder.start(config, path: audioPath).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException(
              'Audio recorder start() timed out after 8 seconds');
        },
      );

      return audioPath;
    } catch (e) {
      debugPrint('ERROR: Exception starting audio recording: $e');
      return null;
    }
  }

  Future<void> _stopAndTranscribe(
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
    String language,
  ) async {
    try {
      _autoStopTimer?.cancel();
      _autoStopTimer = null;

      if (!_isListening) return;
      _isListening = false;

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint('ERROR: Audio recorder stop() returned null');
        onError('Failed to stop audio recording');
        await _cleanupAudioFile();
        return;
      }

      debugPrint('[OpenAI] Audio recording stopped at: $recordingPath');

      // Verify audio file exists and has content
      final audioFile = File(recordingPath);
      if (!await audioFile.exists()) {
        debugPrint('ERROR: Audio file does not exist at: $recordingPath');
        onError('Audio file was not created');
        return;
      }

      final fileSize = await audioFile.length();
      debugPrint('[OpenAI] Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        debugPrint('ERROR: Audio file too small ($fileSize bytes)');
        onError('Audio recording too short or empty');
        await _cleanupAudioFile();
        return;
      }

      // Transcribe using OpenAI API
      final transcription =
          await _transcribeWithOpenAI(recordingPath, language);

      if (transcription != null && transcription.isNotEmpty) {
        debugPrint('✓ OpenAI transcription successful: "$transcription"');
        onResult(transcription, true);
      } else {
        debugPrint('ERROR: OpenAI returned empty transcription');
        onError('Transcription returned empty result');
      }

      await _cleanupAudioFile();
    } catch (e) {
      debugPrint('ERROR: Exception during stop and transcribe: $e');
      onError('Transcription error: ${e.toString()}');
      await _cleanupAudioFile();
    }
  }

  Future<String?> _transcribeWithOpenAI(
      String audioPath, String language) async {
    try {
      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        throw Exception('OpenAI API key not configured');
      }

      // Convert language code to ISO-639-1 (e.g., en_US -> en)
      final languageCode = language.split('_').first.toLowerCase();

      debugPrint('[OpenAI] Sending audio to Whisper API...');
      final startTime = DateTime.now();

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.headers['Authorization'] = 'Bearer $apiKey';

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));
      request.fields['model'] = _model;
      request.fields['language'] = languageCode;
      request.fields['response_format'] = 'json';

      // Send request with timeout
      final streamedResponse = await _httpClient.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException(
              'OpenAI API request timed out after 60 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      final duration = DateTime.now().difference(startTime);
      debugPrint(
          '[OpenAI] API response received in ${duration.inMilliseconds}ms');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final text = jsonResponse['text'] as String?;
        return text?.trim();
      } else {
        final errorBody = response.body;
        debugPrint(
            'ERROR: OpenAI API returned ${response.statusCode}: $errorBody');

        // Parse error message if available
        try {
          final errorJson = json.decode(errorBody) as Map<String, dynamic>;
          final errorMessage = errorJson['error']?['message'] as String?;
          if (errorMessage != null) {
            throw Exception(errorMessage);
          }
        } catch (_) {
          // Fall through to generic error
        }

        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ERROR: OpenAI transcription failed: $e');
      rethrow;
    }
  }

  Future<void> _cleanupAudioFile() async {
    if (_currentAudioPath == null) return;

    try {
      final file = File(_currentAudioPath!);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[OpenAI] Cleaned up audio file: $_currentAudioPath');
      }
    } catch (e) {
      debugPrint('Error cleaning up audio file: $e');
    } finally {
      _currentAudioPath = null;
    }
  }

  @override
  Future<String?> stopListening() async {
    try {
      if (!_isListening) {
        debugPrint('stopListening called but not currently listening');
        return null;
      }

      _autoStopTimer?.cancel();
      _autoStopTimer = null;
      _isListening = false;

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint('ERROR: Audio recorder stop() returned null');
        await _cleanupAudioFile();
        return null;
      }

      // Verify audio file
      final audioFile = File(recordingPath);
      if (!await audioFile.exists()) {
        debugPrint('ERROR: Audio file does not exist after recording');
        return null;
      }

      final fileSize = await audioFile.length();
      if (fileSize < 1000) {
        debugPrint('ERROR: Audio recording too short ($fileSize bytes)');
        await _cleanupAudioFile();
        return null;
      }

      // Transcribe
      try {
        final transcription =
            await _transcribeWithOpenAI(recordingPath, 'en_US');
        await _cleanupAudioFile();
        return transcription;
      } catch (e) {
        debugPrint('ERROR: Exception during manual transcription: $e');
        await _cleanupAudioFile();
        return null;
      }
    } catch (e) {
      debugPrint('ERROR: Exception in stopListening: $e');
      await _cleanupAudioFile();
      return null;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      _autoStopTimer?.cancel();
      _autoStopTimer = null;
      _isListening = false;

      await _audioRecorder.cancel();
      await _cleanupAudioFile();

      debugPrint('[OpenAI] Audio recording canceled');
    } catch (e) {
      debugPrint('Error canceling OpenAI Whisper listening: $e');
      await _cleanupAudioFile();
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> get availableLanguages async {
    // OpenAI Whisper supports 99 languages
    return [
      'en_US', // English
      'es_ES', // Spanish
      'fr_FR', // French
      'de_DE', // German
      'it_IT', // Italian
      'pt_BR', // Portuguese
      'ja_JP', // Japanese
      'zh_CN', // Chinese Simplified
      'zh_TW', // Chinese Traditional
      'ko_KR', // Korean
      'ru_RU', // Russian
      'ar_SA', // Arabic
      'nl_NL', // Dutch
      'pl_PL', // Polish
      'sv_SE', // Swedish
    ];
  }

  /// Dispose resources when no longer needed.
  void dispose() {
    _autoStopTimer?.cancel();
    _httpClient.close();
  }
}
