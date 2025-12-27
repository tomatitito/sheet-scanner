import 'dart:async';
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
      model: WhisperModel.tiny, // Tiny model for 5-10x faster transcription on Android
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
      debugPrint('[TRACE] startListening called with listenFor=${listenFor.inSeconds}s');
      
      // Verify availability before attempting to listen
      debugPrint('[TRACE] Checking microphone availability...');
      if (!await isAvailable()) {
        debugPrint('ERROR: Microphone not available');
        onError('Microphone permission not granted');
        return;
      }
      debugPrint('[TRACE] Microphone available');

      _isListening = true;

      // Emit listening started event
      debugPrint('[TRACE] Emitting listening started event');
      onResult('', false);

      // Start recording audio to a temporary file
      debugPrint('[TRACE] Starting audio recording...');
      final audioPath = await _startAudioRecording();
      if (audioPath == null) {
        _isListening = false;
        debugPrint('ERROR: _startAudioRecording returned null');
        onError('Failed to start audio recording');
        return;
      }

      _currentAudioPath = audioPath;
      debugPrint('[TRACE] Audio recording started, will auto-stop after ${listenFor.inSeconds}s');

      // Auto-stop and transcribe after the listen duration
      // Use unawaited to avoid blocking, but handle errors properly
      _autoStopAndTranscribeAsync(listenFor, onResult, onError);
    } catch (e) {
      debugPrint('ERROR: Exception during startListening: $e');
      debugPrint('[STACK] Stack trace: ${StackTrace.current}');
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
   debugPrint('[TRACE] _autoStopAndTranscribeAsync scheduled: will fire in ${listenFor.inSeconds}s');
   final delayStartTime = DateTime.now();
   Future.delayed(listenFor).then((_) async {
     final delayDuration = DateTime.now().difference(delayStartTime);
     debugPrint('[TRACE] _autoStopAndTranscribeAsync firing after ${delayDuration.inMilliseconds}ms');
     try {
       if (_isListening) {
         debugPrint('[TRACE] _isListening=true, calling _autoStopAndTranscribe');
         await _autoStopAndTranscribe(onResult, onError);
         debugPrint('[TRACE] _autoStopAndTranscribe completed');
       } else {
         debugPrint('[TRACE] Listening already stopped, skipping auto-transcribe');
       }
     } catch (e) {
       debugPrint('ERROR: Exception in async auto-stop/transcribe: $e');
       debugPrint('[STACK] Stack trace: ${StackTrace.current}');
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

      debugPrint('[TRACE] Starting audio recording to: $audioPath');
      debugPrint('[TRACE] Config: encoder=WAV, sampleRate=16000Hz, channels=1');

      // Start recording to file (returns void, path is handled by the recorder)
      debugPrint('[TRACE] Calling _audioRecorder.start()...');
      final recordingStartTime = DateTime.now();
      try {
        // Add a timeout to catch potential hangs in the record package
        await _audioRecorder.start(config, path: audioPath).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            throw TimeoutException('Audio recorder start() timed out after 8 seconds');
          },
        );
      } catch (e) {
        if (e is TimeoutException) {
          debugPrint('ERROR: ${e.toString()}');
        }
        rethrow;
      }
      final recordingStartDuration = DateTime.now().difference(recordingStartTime);
      debugPrint('[TRACE] _audioRecorder.start() completed in ${recordingStartDuration.inMilliseconds}ms');

      // Check if recording actually started by verifying the recorder is active
      // The record package will write to the specified audioPath
      debugPrint('[TRACE] Audio recording initiated at: $audioPath');
      return audioPath;
    } catch (e) {
      debugPrint('ERROR: Exception starting audio recording: $e');
      debugPrint('[STACK] Stack trace: ${StackTrace.current}');
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
      debugPrint('[TRACE] Calling Whisper transcribe on: $audioPath');
      debugPrint('[TRACE] File exists: ${await File(audioPath).exists()}');
      
      final transcribeStartTime = DateTime.now();
      debugPrint('[TRACE] Calling _whisper.transcribe()...');
      
      // Add timeout to catch Whisper hanging during model loading or processing
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      ).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw TimeoutException('Whisper transcription timed out after 2 minutes');
        },
      );
      
      final transcribeDuration = DateTime.now().difference(transcribeStartTime);
      debugPrint('[TRACE] _whisper.transcribe() completed in ${transcribeDuration.inSeconds}s');

      final transcribedText = result.text.trim();
      debugPrint('[TRACE] Transcription result length: ${transcribedText.length} chars');
      debugPrint('✓ Whisper transcription complete: "$transcribedText"');
      return transcribedText;
    } catch (e) {
      debugPrint('ERROR: Whisper transcription failed: $e');
      debugPrint('[STACK] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
