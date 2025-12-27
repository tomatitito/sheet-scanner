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
      debugPrint(
          'Audio recording started, will auto-stop after ${listenFor.inSeconds}s');

      // Auto-stop and transcribe after the listen duration
      // Use unawaited to avoid blocking, but handle errors properly
      _autoStopAndTranscribeAsync(listenFor, onResult, onError);
    } catch (e) {
      debugPrint('Error during Whisper listening: $e');
      onError('Whisper error: ${e.toString()}');
      _isListening = false;
      await _cleanupAudioFile();
    }
  }

  /// Schedule auto-stop and transcription without blocking.
  /// This method uses a background task to ensure errors are properly handled.
  void _autoStopAndTranscribeAsync(
    Duration listenFor,
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
  ) {
    Future.delayed(listenFor).then((_) async {
      try {
        if (_isListening) {
          await _autoStopAndTranscribe(onResult, onError);
        } else {
          debugPrint('Listening already stopped, skipping auto-transcribe');
        }
      } catch (e) {
        debugPrint('Error in async auto-stop/transcribe: $e');
        onError('Auto-transcribe error: ${e.toString()}');
        _isListening = false;
        await _cleanupAudioFile();
      }
    });
  }

  /// Auto-stop recording and transcribe (called after listen duration).
  Future<void> _autoStopAndTranscribe(
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
  ) async {
    try {
      if (!_isListening) {
        debugPrint('Skipping auto-transcribe: not listening');
        return;
      }

      _isListening = false;
      debugPrint('Auto-stop triggered: stopping audio recorder');

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint(
            'ERROR: Audio recorder stop() returned null. Recording path lost.');
        onError('Failed to stop audio recording');
        await _cleanupAudioFile();
        return;
      }

      debugPrint('Audio recording stopped at: $recordingPath');

      // Transcribe the recorded audio
      await _transcribeRecordedAudio(onResult, onError);
    } catch (e) {
      debugPrint('ERROR: Exception during auto-stop transcription: $e');
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
      final audioPath = '${tempDir.path}/whisper_recording_$timestamp.wav';

      // Configure recording for Whisper: WAV format at 16kHz mono
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // Whisper requirement
        numChannels: 1, // Mono for better Whisper accuracy
        bitRate: 16000, // Bitrate matches sample rate for 16-bit PCM
      );

      debugPrint('Starting audio recording to: $audioPath');
      debugPrint('Config: encoder=WAV, sampleRate=16000Hz, channels=1');

      // Start recording to file (returns void, path is handled by the recorder)
      await _audioRecorder.start(config, path: audioPath);

      // Check if recording actually started by verifying the recorder is active
      // The record package will write to the specified audioPath
      debugPrint('Audio recording initiated at: $audioPath');
      return audioPath;
    } catch (e) {
      debugPrint('ERROR: Exception starting audio recording: $e');
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
        debugPrint('ERROR: No audio file path stored for transcription');
        onError('No audio file to transcribe');
        return;
      }

      final audioPath = _currentAudioPath!;
      debugPrint('Transcribing recorded audio: $audioPath');

      // Verify audio file exists and has content
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        debugPrint(
            'ERROR: Audio file does not exist at: $audioPath. Recording may have failed.');
        onError('Audio file was not created');
        return;
      }

      final fileSize = await audioFile.length();
      debugPrint('Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        // Minimum ~1KB of audio data
        debugPrint(
            'ERROR: Audio file too small ($fileSize bytes). Recording may have been too quiet or failed.');
        onError('Audio recording too short or empty');
        await _cleanupAudioFile();
        return;
      }

      debugPrint('Starting Whisper transcription of $fileSize byte audio file');

      // Transcribe using Whisper
      final transcription = await transcribeAudioFile(audioPath);

      if (transcription.isNotEmpty) {
        debugPrint('✓ Transcription successful: "$transcription"');
        onResult(transcription, true);
      } else {
        debugPrint('ERROR: Whisper returned empty transcription');
        onError('Transcription returned empty result');
      }

      // Cleanup temporary file
      await _cleanupAudioFile();
    } catch (e) {
      debugPrint('ERROR: Exception during transcription: $e');
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
        debugPrint('stopListening called but not currently listening');
        return null;
      }

      _isListening = false;
      debugPrint('Manual stop requested: stopping audio recorder');

      // Stop audio recording
      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint('ERROR: Audio recorder stop() returned null');
        await _cleanupAudioFile();
        return null;
      }

      debugPrint('Audio recording stopped at: $recordingPath');

      // Verify audio file exists and has content
      final audioFile = File(recordingPath);
      if (!await audioFile.exists()) {
        debugPrint(
            'ERROR: Audio file does not exist after recording at: $recordingPath');
        return null;
      }

      final fileSize = await audioFile.length();
      debugPrint('Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        // Minimum ~1KB of audio data
        debugPrint(
            'ERROR: Audio recording too short ($fileSize bytes). Recording failed.');
        await _cleanupAudioFile();
        return null;
      }

      // Transcribe the recorded audio
      try {
        debugPrint('Starting transcription of manually stopped recording');
        final transcription = await transcribeAudioFile(recordingPath);
        debugPrint('✓ Transcription result: "$transcription"');
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
      debugPrint('Calling Whisper transcribe on: $audioPath');

      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      );

      final transcribedText = result.text.trim();
      debugPrint('✓ Whisper transcription complete: "$transcribedText"');
      return transcribedText;
    } catch (e) {
      debugPrint('ERROR: Whisper transcription failed: $e');
      rethrow;
    }
  }
}
