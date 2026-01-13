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
class WhisperRecognitionServiceImpl implements SpeechRecognitionService {
  late final Whisper _whisper;
  late final AudioRecorder _audioRecorder;
  bool _isListening = false;
  String? _currentAudioPath;
  
  /// Completer to track the ongoing transcription operation.
  /// This ensures we can await the full operation and properly handle errors.
  Completer<void>? _transcriptionCompleter;

  WhisperRecognitionServiceImpl() {
    _whisper = const Whisper(
      model: WhisperModel.tiny,
      downloadHost: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
    _audioRecorder = AudioRecorder();
  }

  @override
  Future<bool> initialize() async {
    try {
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
      
      debugPrint('[TRACE] Checking microphone availability...');
      if (!await isAvailable()) {
        debugPrint('ERROR: Microphone not available');
        onError('Microphone permission not granted');
        return;
      }
      debugPrint('[TRACE] Microphone available');

      _isListening = true;
      
      // Create a completer to track this transcription session
      _transcriptionCompleter = Completer<void>();

      debugPrint('[TRACE] Emitting listening started event');
      onResult('', false);

      debugPrint('[TRACE] Starting audio recording...');
      final audioPath = await _startAudioRecording();
      if (audioPath == null) {
        _isListening = false;
        _transcriptionCompleter?.completeError(Exception('Failed to start audio recording'));
        debugPrint('ERROR: _startAudioRecording returned null');
        onError('Failed to start audio recording');
        return;
      }

      // CRITICAL FIX: Verify recording actually started
      debugPrint('[TRACE] Verifying recording is active...');
      final isRecording = await _audioRecorder.isRecording();
      if (!isRecording) {
        _isListening = false;
        await _cleanupAudioFile();
        _transcriptionCompleter?.completeError(Exception('Audio recorder failed to start'));
        debugPrint('ERROR: Audio recorder is not recording despite start() returning');
        onError('Audio recording failed to start - microphone may be in use');
        return;
      }
      debugPrint('[TRACE] Recording verified active');

      _currentAudioPath = audioPath;
      debugPrint('[TRACE] Audio recording started, will auto-stop after ${listenFor.inSeconds}s');

      // CRITICAL FIX: Schedule auto-stop and track the Future
      // We no longer fire-and-forget - the caller should await startListening()
      // but we still handle errors via callbacks for backward compatibility
      _scheduleAutoStopAndTranscribe(listenFor, onResult, onError);
    } catch (e) {
      debugPrint('ERROR: Exception during startListening: $e');
      debugPrint('[STACK] Stack trace: ${StackTrace.current}');
      onError('Whisper error: ${e.toString()}');
      _isListening = false;
      _transcriptionCompleter?.completeError(e);
      await _cleanupAudioFile();
    }
  }

  /// Schedule auto-stop and transcription.
  /// This runs the full recording+transcription lifecycle and properly handles errors.
  void _scheduleAutoStopAndTranscribe(
    Duration listenFor,
    Function(String text, bool isFinal) onResult,
    Function(String error) onError,
  ) {
    debugPrint('[TRACE] Scheduling auto-stop in ${listenFor.inSeconds}s');
    final startTime = DateTime.now();
    
    Future.delayed(listenFor).then((_) async {
      final elapsed = DateTime.now().difference(startTime);
      debugPrint('[TRACE] Auto-stop firing after ${elapsed.inMilliseconds}ms');
      
      try {
        if (!_isListening) {
          debugPrint('[TRACE] Listening already stopped, skipping auto-transcribe');
          if (_transcriptionCompleter != null && !_transcriptionCompleter!.isCompleted) {
            _transcriptionCompleter!.complete();
          }
          return;
        }

        debugPrint('[TRACE] Stopping audio recorder...');
        _isListening = false;

        final recordingPath = await _audioRecorder.stop();
        if (recordingPath == null) {
          debugPrint('ERROR: Audio recorder stop() returned null');
          onError('Failed to stop audio recording');
          if (_transcriptionCompleter != null && !_transcriptionCompleter!.isCompleted) {
            _transcriptionCompleter!.completeError(Exception('Stop returned null'));
          }
          await _cleanupAudioFile();
          return;
        }

        debugPrint('[TRACE] Audio recording stopped at: $recordingPath');

        // Transcribe the recorded audio
        await _transcribeRecordedAudio(onResult, onError);
        
        if (_transcriptionCompleter != null && !_transcriptionCompleter!.isCompleted) {
          _transcriptionCompleter!.complete();
        }
      } catch (e) {
        debugPrint('ERROR: Exception in auto-stop/transcribe: $e');
        debugPrint('[STACK] Stack trace: ${StackTrace.current}');
        onError('Transcription error: ${e.toString()}');
        _isListening = false;
        if (_transcriptionCompleter != null && !_transcriptionCompleter!.isCompleted) {
          _transcriptionCompleter!.completeError(e);
        }
        await _cleanupAudioFile();
      }
    });
  }

  /// Start recording audio to a temporary WAV file at 16kHz (Whisper requirement).
  Future<String?> _startAudioRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioPath = '${tempDir.path}/whisper_recording_$timestamp.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 16000,
      );

      debugPrint('[TRACE] Starting audio recording to: $audioPath');
      debugPrint('[TRACE] Config: encoder=WAV, sampleRate=16000Hz, channels=1');

      debugPrint('[TRACE] Calling _audioRecorder.start()...');
      final recordingStartTime = DateTime.now();
      
      // CRITICAL: Timeout on start() to catch Android audio system hangs
      try {
        await _audioRecorder.start(config, path: audioPath).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Audio recorder start() timed out after 5 seconds');
          },
        );
      } on TimeoutException catch (e) {
        debugPrint('ERROR: ${e.message}');
        return null;
      }
      
      final recordingStartDuration = DateTime.now().difference(recordingStartTime);
      debugPrint('[TRACE] _audioRecorder.start() completed in ${recordingStartDuration.inMilliseconds}ms');

      if (recordingStartDuration.inSeconds > 2) {
        debugPrint('[WARNING] Audio start took ${recordingStartDuration.inSeconds}s - may indicate device issues');
      }

      debugPrint('[TRACE] Audio recording initiated at: $audioPath');
      return audioPath;
    } catch (e) {
      debugPrint('ERROR: Exception starting audio recording: $e');
      debugPrint('[STACK] Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Transcribe the recorded audio using Whisper.
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
      debugPrint('[TRACE] Transcribing recorded audio: $audioPath');

      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        debugPrint('ERROR: Audio file does not exist at: $audioPath');
        onError('Audio file was not created');
        return;
      }

      final fileSize = await audioFile.length();
      debugPrint('[TRACE] Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        debugPrint('ERROR: Audio file too small ($fileSize bytes)');
        onError('Audio recording too short or empty');
        await _cleanupAudioFile();
        return;
      }

      debugPrint('[TRACE] Starting Whisper transcription of $fileSize byte audio file');

      final transcription = await transcribeAudioFile(audioPath);

      if (transcription.isNotEmpty) {
        debugPrint('✓ Transcription successful: "$transcription"');
        onResult(transcription, true);
      } else {
        debugPrint('ERROR: Whisper returned empty transcription');
        onError('Transcription returned empty result');
      }

      await _cleanupAudioFile();
    } catch (e) {
      debugPrint('ERROR: Exception during transcription: $e');
      onError('Transcription error: ${e.toString()}');
      await _cleanupAudioFile();
    }
  }

  Future<void> _cleanupAudioFile() async {
    if (_currentAudioPath == null) return;

    try {
      final file = File(_currentAudioPath!);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[TRACE] Cleaned up audio file: $_currentAudioPath');
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
      debugPrint('[TRACE] Manual stop requested: stopping audio recorder');

      final recordingPath = await _audioRecorder.stop();
      if (recordingPath == null) {
        debugPrint('ERROR: Audio recorder stop() returned null');
        await _cleanupAudioFile();
        return null;
      }

      debugPrint('[TRACE] Audio recording stopped at: $recordingPath');

      final audioFile = File(recordingPath);
      if (!await audioFile.exists()) {
        debugPrint('ERROR: Audio file does not exist after recording');
        return null;
      }

      final fileSize = await audioFile.length();
      debugPrint('[TRACE] Audio file size: $fileSize bytes');

      if (fileSize < 1000) {
        debugPrint('ERROR: Audio recording too short ($fileSize bytes)');
        await _cleanupAudioFile();
        return null;
      }

      try {
        debugPrint('[TRACE] Starting transcription of manually stopped recording');
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
      await _audioRecorder.cancel();
      await _cleanupAudioFile();
      debugPrint('[TRACE] Audio recording canceled');
      
      if (_transcriptionCompleter != null && !_transcriptionCompleter!.isCompleted) {
        _transcriptionCompleter!.completeError(Exception('Cancelled'));
      }
    } catch (e) {
      debugPrint('Error canceling Whisper listening: $e');
      await _cleanupAudioFile();
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> get availableLanguages async {
    return [
      'en_US',
      'es_ES',
      'fr_FR',
      'de_DE',
      'it_IT',
      'pt_BR',
      'ja_JP',
      'zh_CN',
      'zh_TW',
    ];
  }

  /// Transcribe an audio file using Whisper.
  Future<String> transcribeAudioFile(String audioPath) async {
    try {
      debugPrint('[TRACE] Calling Whisper transcribe on: $audioPath');
      debugPrint('[TRACE] File exists: ${await File(audioPath).exists()}');
      
      final transcribeStartTime = DateTime.now();
      debugPrint('[TRACE] Calling _whisper.transcribe()...');
      
      // CRITICAL: Timeout to catch Whisper hanging during model loading
      // Reduced from 2 minutes to 90 seconds for better UX
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw TimeoutException('Whisper transcription timed out after 90 seconds');
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
