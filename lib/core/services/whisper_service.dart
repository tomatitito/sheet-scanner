import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

import 'speech_recognition_service.dart';

/// Implementation of speech recognition using OpenAI's Whisper model.
///
/// Works offline using whisper.cpp for improved accuracy on short phrases
/// and technical terms (like music metadata).
class WhisperRecognitionServiceImpl implements SpeechRecognitionService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late final Whisper _whisper;

  String? _recordingPath;
  bool _isListening = false;

  WhisperRecognitionServiceImpl() {
    _whisper = const Whisper(
      model: WhisperModel.base, // Balance between accuracy and size
      downloadHost: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
  }

  @override
  Future<bool> initialize() async {
    try {
      // Check if Whisper is available
      final version = await _whisper.getVersion();
      debugPrint('Whisper version: $version');
      return true;
    } catch (e) {
      debugPrint('Error initializing Whisper: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
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
      debugPrint('Error checking Whisper availability: $e');
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
      // Verify availability before attempting to listen
      if (!await isAvailable()) {
        onError('Microphone permission not granted');
        return;
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/whisper_recording.wav';

      _isListening = true;

      // Start recording with RecordConfig
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000, // Whisper expects 16kHz
        ),
        path: _recordingPath!,
      );

      debugPrint('Recording started at: $_recordingPath');

      // Emit listening started event
      onResult('', false);

      // Wait for the specified listen duration
      await Future.delayed(listenFor);

      // Stop recording
      await _audioRecorder.stop();
      _isListening = false;

      debugPrint('Recording stopped');

      // Transcribe the recorded audio
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: _recordingPath!,
          isTranslate: false, // Keep original language
          isNoTimestamps: true,
        ),
      );

      debugPrint('Whisper result: ${result.text}');

      // Extract text from the response object
      final transcribedText = result.text.trim();

      // Emit final result
      onResult(transcribedText, true);

      // Clean up the recording file
      await _deleteRecordingFile();
    } catch (e) {
      debugPrint('Error during Whisper listening: $e');
      onError('Whisper transcription failed: ${e.toString()}');
      _isListening = false;
      await _deleteRecordingFile();
    }
  }

  @override
  Future<String?> stopListening() async {
    try {
      if (!_isListening) {
        return null;
      }

      _isListening = false;
      final stopped = await _audioRecorder.stop();
      debugPrint('Recording stopped, path: $stopped');

      if (stopped == null || _recordingPath == null) {
        return null;
      }

      // Transcribe immediately
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: _recordingPath!,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      );

      final transcribedText = result.text.trim();

      // Clean up
      await _deleteRecordingFile();

      return transcribedText;
    } catch (e) {
      debugPrint('Error stopping Whisper listening: $e');
      await _deleteRecordingFile();
      return null;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      _isListening = false;
      await _audioRecorder.stop();
      await _deleteRecordingFile();
    } catch (e) {
      debugPrint('Error canceling Whisper listening: $e');
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> get availableLanguages async {
    // Whisper supports 99 languages, but we'll return common ones
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
    ];
  }

  /// Delete the temporary recording file.
  Future<void> _deleteRecordingFile() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted recording file: $_recordingPath');
        }
      }
      _recordingPath = null;
    } catch (e) {
      debugPrint('Error deleting recording file: $e');
    }
  }
}
