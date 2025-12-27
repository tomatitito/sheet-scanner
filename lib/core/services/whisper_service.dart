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
///
/// Note: This implementation serves as a foundation for Whisper integration.
/// Recording is currently delegated to platform-specific implementations or
/// future integration with a stable audio recording package.
class WhisperRecognitionServiceImpl implements SpeechRecognitionService {
  late final Whisper _whisper;
  late final AudioRecorder _audioRecorder;
  bool _isListening = false;
  String? _currentAudioPath;

  WhisperRecognitionServiceImpl() {
    _whisper = const Whisper(
      model: WhisperModel.base, // Balance between accuracy and size
      downloadHost: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
    _audioRecorder = AudioRecorder();
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

      _isListening = true;

      // Emit listening started event
      onResult('', false);

      // Start recording audio to a temporary file
      final audioPath = await _startAudioRecording();
      if (audioPath == null) {
        _isListening = false;
        onError('Failed to start audio recording');
        return;
      }

      _currentAudioPath = audioPath;

      // Auto-stop and transcribe after the listen duration
      // This runs in the background without blocking
      Future.delayed(listenFor).then((_) async {
        if (_isListening) {
          await _autoStopAndTranscribe(onResult, onError);
        }
      });
    } catch (e) {
      debugPrint('Error during Whisper listening: $e');
      onError('Whisper error: ${e.toString()}');
      _isListening = false;
      await _cleanupAudioFile();
    }
  }

  /// Auto-stop recording and transcribe (called after listen duration).
  Future<void> _autoStopAndTranscribe(
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
  ) async {
    try {
      if (!_isListening) return;

      _isListening = false;

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        onError('Failed to stop audio recording');
        await _cleanupAudioFile();
        return;
      }

      // Transcribe the recorded audio
      await _transcribeRecordedAudio(onResult, onError);
    } catch (e) {
      debugPrint('Error during auto-stop transcription: $e');
      onError('Auto-stop error: ${e.toString()}');
      await _cleanupAudioFile();
    }
  }

  /// Start recording audio to a temporary WAV file at 16kHz (Whisper requirement).
  /// Returns the file path if successful, null otherwise.
  Future<String?> _startAudioRecording() async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioPath =
          '${tempDir.path}/whisper_recording_$timestamp.wav';

      // Configure recording for Whisper: WAV format at 16kHz mono
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // Whisper requirement
        numChannels: 1, // Mono for better Whisper accuracy
        bitRate: 16000, // Bitrate matches sample rate for 16-bit PCM
      );

      // Start recording to file
      await _audioRecorder.start(config, path: audioPath);

      debugPrint('Started audio recording at: $audioPath');
      return audioPath;
    } catch (e) {
      debugPrint('Error starting audio recording: $e');
      return null;
    }
  }

  /// Stop recording and transcribe the audio using Whisper.
  Future<void> _transcribeRecordedAudio(
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
  ) async {
    try {
      if (_currentAudioPath == null) {
        onError('No audio file to transcribe');
        return;
      }

      final audioPath = _currentAudioPath!;

      // Verify audio file exists and has content
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        onError('Audio file was not created');
        return;
      }

      final fileSize = await audioFile.length();
      if (fileSize < 1000) {
        // Minimum ~1KB of audio data
        onError('Audio recording too short or empty');
        await _cleanupAudioFile();
        return;
      }

      debugPrint('Transcribing audio file: $audioPath ($fileSize bytes)');

      // Transcribe using Whisper
      final transcription = await transcribeAudioFile(audioPath);

      if (transcription.isNotEmpty) {
        debugPrint('Transcription successful: $transcription');
        onResult(transcription, true);
      } else {
        onError('Transcription returned empty result');
      }

      // Cleanup temporary file
      await _cleanupAudioFile();
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      onError('Transcription error: ${e.toString()}');
      await _cleanupAudioFile();
    }
  }

  /// Clean up the temporary audio file.
  Future<void> _cleanupAudioFile() async {
    if (_currentAudioPath == null) return;

    try {
      final file = File(_currentAudioPath!);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Cleaned up audio file: $_currentAudioPath');
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
        return null;
      }

      _isListening = false;

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint('Failed to stop audio recording');
        await _cleanupAudioFile();
        return null;
      }

      debugPrint('Audio recording stopped at: $recordingPath');

      // Verify audio file exists and has content
      final audioFile = File(recordingPath);
      if (!await audioFile.exists()) {
        debugPrint('Audio file does not exist after recording');
        return null;
      }

      final fileSize = await audioFile.length();
      debugPrint('Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        // Minimum ~1KB of audio data
        debugPrint('Audio recording too short');
        await _cleanupAudioFile();
        return null;
      }

      // Transcribe the recorded audio
      try {
        final transcription = await transcribeAudioFile(recordingPath);
        debugPrint('Transcription result: $transcription');
        await _cleanupAudioFile();
        return transcription;
      } catch (e) {
        debugPrint('Error during transcription: $e');
        await _cleanupAudioFile();
        return null;
      }
    } catch (e) {
      debugPrint('Error stopping Whisper listening: $e');
      await _cleanupAudioFile();
      return null;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      _isListening = false;

      // Stop the audio recorder
      await _audioRecorder.cancel();

      // Cleanup temporary audio file
      await _cleanupAudioFile();

      debugPrint('Audio recording canceled');
    } catch (e) {
      debugPrint('Error canceling Whisper listening: $e');
      await _cleanupAudioFile();
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

  /// Transcribe an audio file using Whisper.
  ///
  /// This method can be called directly when you have an audio file path
  /// (e.g., from native recording or other sources).
  Future<String> transcribeAudioFile(String audioPath) async {
    try {
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      );

      debugPrint('Whisper result: ${result.text}');
      return result.text.trim();
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      rethrow;
    }
  }
}
