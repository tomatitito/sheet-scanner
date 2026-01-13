import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'openai_whisper_service.dart';
import 'speech_recognition_service.dart';
import 'whisper_service.dart';

/// Enum to indicate which mode the hybrid service is currently using.
enum HybridMode {
  cloud,
  local,
  unknown,
}

/// Callback type for mode change notifications.
typedef OnModeChanged = void Function(HybridMode mode, String reason);

/// Hybrid speech recognition service that automatically falls back between
/// cloud (OpenAI Whisper API) and local (whisper_flutter_new) based on
/// connectivity and API availability.
///
/// Strategy:
/// 1. Try cloud service first (better accuracy)
/// 2. Fall back to local on network errors, API errors, or no API key
/// 3. Notify user of which mode is active
class HybridSpeechRecognitionService implements SpeechRecognitionService {
  final OpenAIWhisperService _cloudService;
  final WhisperRecognitionServiceImpl _localService;
  final OnModeChanged? _onModeChanged;

  HybridMode _currentMode = HybridMode.unknown;
  bool _isListening = false;

  HybridSpeechRecognitionService({
    required OpenAIWhisperService cloudService,
    required WhisperRecognitionServiceImpl localService,
    OnModeChanged? onModeChanged,
  })  : _cloudService = cloudService,
        _localService = localService,
        _onModeChanged = onModeChanged;

  /// Get the current operating mode.
  HybridMode get currentMode => _currentMode;

  /// Check if we have internet connectivity.
  /// Uses a quick DNS lookup as a lightweight connectivity check.
  Future<bool> _hasInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('api.openai.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      debugPrint('[Hybrid] No internet - DNS lookup failed');
      return false;
    } on TimeoutException catch (_) {
      debugPrint('[Hybrid] No internet - DNS lookup timed out');
      return false;
    } catch (e) {
      debugPrint('[Hybrid] Connectivity check failed: $e');
      return false;
    }
  }

  void _setMode(HybridMode mode, String reason) {
    if (_currentMode != mode) {
      _currentMode = mode;
      debugPrint('[Hybrid] Mode changed to $mode: $reason');
      _onModeChanged?.call(mode, reason);
    }
  }

  @override
  Future<bool> initialize() async {
    debugPrint('[Hybrid] Initializing services...');
    
    // Initialize both services
    final cloudInit = await _cloudService.initialize();
    final localInit = await _localService.initialize();

    debugPrint('[Hybrid] Cloud initialized: $cloudInit, Local initialized: $localInit');

    // At least one service must be available
    return cloudInit || localInit;
  }

  @override
  Future<bool> isAvailable() async {
    // Check if at least one service is available
    final cloudAvailable = await _cloudService.isAvailable();
    final localAvailable = await _localService.isAvailable();

    debugPrint('[Hybrid] Cloud available: $cloudAvailable, Local available: $localAvailable');

    return cloudAvailable || localAvailable;
  }

  @override
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    String language = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    debugPrint('[Hybrid] startListening called');
    _isListening = true;

    // Check connectivity and cloud availability
    final hasInternet = await _hasInternetConnectivity();
    final cloudAvailable = hasInternet && await _cloudService.isAvailable();

    if (cloudAvailable) {
      debugPrint('[Hybrid] Using cloud service');
      _setMode(HybridMode.cloud, 'Online, API key configured');

      // Wrap cloud service to detect failures and fallback
      await _cloudService.startListening(
        onResult: onResult,
        onError: (error) async {
          debugPrint('[Hybrid] Cloud service error: $error');
          
          // Check if this is a recoverable error that warrants fallback
          if (_shouldFallbackToLocal(error)) {
            debugPrint('[Hybrid] Falling back to local service');
            _setMode(HybridMode.local, 'Cloud failed, using offline mode');
            
            // Cancel cloud and try local
            await _cloudService.cancelListening();
            
            // Retry with local service
            await _localService.startListening(
              onResult: onResult,
              onError: onError,
              language: language,
              listenFor: listenFor,
            );
          } else {
            // Non-recoverable error (e.g., microphone permission)
            onError(error);
          }
        },
        language: language,
        listenFor: listenFor,
      );
    } else {
      // Use local service
      final localAvailable = await _localService.isAvailable();
      if (!localAvailable) {
        _isListening = false;
        onError('Speech recognition not available. Check microphone permissions.');
        return;
      }

      debugPrint('[Hybrid] Using local service (offline mode)');
      _setMode(
        HybridMode.local,
        hasInternet ? 'No API key configured' : 'Offline mode',
      );

      await _localService.startListening(
        onResult: onResult,
        onError: onError,
        language: language,
        listenFor: listenFor,
      );
    }
  }

  /// Determine if an error should trigger fallback to local service.
  bool _shouldFallbackToLocal(String error) {
    final lowerError = error.toLowerCase();
    
    // Network errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('socket')) {
      return true;
    }

    // API errors
    if (lowerError.contains('api') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('rate limit') ||
        lowerError.contains('quota')) {
      return true;
    }

    // Service errors
    if (lowerError.contains('service unavailable') ||
        lowerError.contains('503') ||
        lowerError.contains('500')) {
      return true;
    }

    return false;
  }

  @override
  Future<String?> stopListening() async {
    _isListening = false;

    // Stop whichever service is active
    if (_currentMode == HybridMode.cloud) {
      return await _cloudService.stopListening();
    } else {
      return await _localService.stopListening();
    }
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;

    // Cancel both to be safe
    await _cloudService.cancelListening();
    await _localService.cancelListening();
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> get availableLanguages async {
    // Both services support the same languages (Whisper is multilingual)
    return await _cloudService.availableLanguages;
  }
}
