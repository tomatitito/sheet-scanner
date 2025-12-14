# Voice Dictation Feature Specification

## Overview

Add voice input capability to the Sheet Scanner app, allowing users to dictate sheet music metadata (title, composer, notes) instead of typing. This feature enhances mobile usability and accessibility.

## Goals

- **Primary**: Enable hands-free voice input for metadata fields
- **Secondary**: Improve UX for mobile users and those with accessibility needs
- **Non-Goals**: Cloud-based transcription (local only), real-time transcription, multi-language support (v1)

## Tech Stack

- **Package**: `speech_to_text: ^7.3.0`
- **Platforms**: Android (Google Speech API), iOS (Speech Framework), Desktop (limited/unsupported)
- **Architecture**: Domain-driven design with clean architecture

## Feature Breakdown

### 1. Voice Input Service Layer (Data)

**File**: `lib/core/services/speech_to_text_service.dart`

Service wrapper around `speech_to_text` package with:
- Initialization and permission handling
- Recording start/stop/cancel
- Real-time transcription results
- Error handling
- Platform detection (mobile only)

```dart
abstract class SpeechRecognitionService {
  Future<void> initialize();
  Future<bool> isAvailable();
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String language = 'en_US',
  });
  Future<void> stopListening();
  Future<void> cancelListening();
  Stream<SpeechRecognitionEvent> get onSpeechEvent;
}
```

### 2. Domain Layer

**Entity**: `lib/features/sheet_music/domain/entities/dictation_result.dart`

```dart
class DictationResult {
  final String text;
  final double confidence; // 0.0 - 1.0
  final bool isFinal;
  final Duration duration;
}
```

**UseCase**: `lib/features/sheet_music/domain/usecases/transcribe_voice_use_case.dart`

```dart
class TranscribeVoiceUseCase implements UseCase<DictationResult, NoParams> {
  final SpeechRecognitionRepository _repository;
  
  Future<Either<Failure, DictationResult>> call();
}
```

### 3. Data Layer

**Repository Implementation**: `lib/features/sheet_music/data/repositories/speech_recognition_repository_impl.dart`

```dart
class SpeechRecognitionRepositoryImpl implements SpeechRecognitionRepository {
  final SpeechToTextService _speechService;
  
  Future<Either<Failure, DictationResult>> startVoiceInput() async {
    // Handle voice recording and transcription
  }
}
```

### 4. Presentation Layer

**Cubit**: `lib/features/sheet_music/presentation/cubit/dictation_cubit.dart`

```dart
class DictationCubit extends Cubit<DictationState> {
  Future<void> startDictation(String fieldName);
  Future<void> stopDictation();
  Future<void> cancelDictation();
  void clearTranscription();
}
```

**States**: `lib/features/sheet_music/presentation/cubit/dictation_state.dart`

```dart
@freezed
class DictationState with _$DictationState {
  const factory DictationState.idle() = _Idle;
  const factory DictationState.listening({
    required String currentTranscription,
    required Duration elapsedTime,
  }) = _Listening;
  const factory DictationState.processing({
    required String transcription,
  }) = _Processing;
  const factory DictationState.complete({
    required String finalText,
    required double confidence,
  }) = _Complete;
  const factory DictationState.error({
    required String message,
  }) = _Error;
}
```

### 5. UI Components

**Widget**: `lib/features/sheet_music/presentation/widgets/voice_input_button.dart`

- Floating action button for voice input
- Visual feedback during recording (microphone icon animation)
- Real-time transcription display
- Recording timer

**Integration Points**:
- AddSheetPage: Voice input for title, composer, notes
- EditSheetPage: Voice input for field updates
- Inline voice buttons next to text fields

## Implementation Plan

### Phase 1: Core Service (2 hours)

1. Create `SpeechRecognitionService` wrapper
2. Handle permissions (iOS, Android)
3. Platform detection and error handling
4. Basic start/stop recording

### Phase 2: Domain Layer (1 hour)

1. Create `DictationResult` entity
2. Create `SpeechRecognitionRepository` interface
3. Create `TranscribeVoiceUseCase`

### Phase 3: Data Layer (1 hour)

1. Implement `SpeechRecognitionRepositoryImpl`
2. Connect to service layer
3. Error mapping to failures

### Phase 4: State Management (1.5 hours)

1. Create `DictationCubit` with state transitions
2. Handle real-time updates
3. Timeout management
4. Cleanup on dispose

### Phase 5: UI (2 hours)

1. Create `VoiceInputButton` widget
2. Create real-time transcription display
3. Integration with AddSheetPage
4. Integration with EditSheetPage

### Phase 6: Testing & Polish (1 hour)

1. Unit tests for service and cubit
2. Widget tests for voice button
3. Error handling and edge cases
4. Accessibility improvements

## Dependency Injection

Add to `lib/core/di/injection.dart`:

```dart
// Speech Recognition Service
getIt.registerLazySingleton<SpeechRecognitionService>(
  () => SpeechRecognitionServiceImpl(),
);

// Repository
getIt.registerLazySingleton<SpeechRecognitionRepository>(
  () => SpeechRecognitionRepositoryImpl(
    speechService: getIt<SpeechRecognitionService>(),
  ),
);

// UseCase
getIt.registerLazySingleton<TranscribeVoiceUseCase>(
  () => TranscribeVoiceUseCase(
    repository: getIt<SpeechRecognitionRepository>(),
  ),
);

// Cubit
getIt.registerFactory<DictationCubit>(
  () => DictationCubit(
    transcribeVoiceUseCase: getIt<TranscribeVoiceUseCase>(),
  ),
);
```

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Supported | Uses native Speech Framework |
| Android | ✅ Supported | Uses Google Speech API |
| macOS | ⚠️ Limited | May work with iOS code, untested |
| Windows | ❌ Not Supported | No native support |
| Web | ❌ Not Supported | Would require different approach |
| Linux | ❌ Not Supported | No native support |

## Permissions

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to transcribe your voice input for sheet music metadata</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your voice</string>
```

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Features

### 1. Real-time Transcription Display

As user speaks:
- Display partial results in real-time
- Show confidence level (if available)
- Update text field with final result

### 2. Recording Indicator

Visual feedback:
- Animated microphone icon
- Recording duration timer
- Waveform animation (optional)

### 3. Noise Handling

- Auto-detect and skip silence
- Handle background noise gracefully
- Allow user to discard low-confidence results

### 4. Field-Specific Dictation

- Voice input for title field
- Voice input for composer field
- Voice input for notes field
- Append to existing text (optional)

### 5. Accessibility

- Voice dictation button always available
- Accessible labels and descriptions
- Keyboard shortcut support (desktop compatibility)

## Error Handling

| Error | Handling |
|-------|----------|
| Microphone not available | Show informative error, disable button |
| Permission denied | Guide user to settings |
| No speech detected | Prompt to try again |
| Network error (if applicable) | Show offline message |
| Service unavailable | Disable feature gracefully |

## Testing

### Unit Tests

- `SpeechRecognitionService` initialization
- `TranscribeVoiceUseCase` with mocked repository
- `DictationCubit` state transitions
- Error mapping

### Widget Tests

- `VoiceInputButton` appearance and interaction
- Transcription display
- Real-time updates

### Integration Tests (Future)

- End-to-end voice input → metadata save
- Permission flows
- Platform-specific behavior

## Future Enhancements

- Multi-language support (en, es, fr, de, etc.)
- Confidence threshold settings
- Voice command shortcuts ("Save", "Cancel")
- Offline transcription using local models (Whisper)
- Audio recording and playback (for review)
- Accent/dialect training
- Custom vocabulary for music terminology

## Configuration

User can configure in settings:
- Language selection
- Confidence threshold
- Auto-append behavior
- Microphone volume sensitivity

## Performance

- Lazy load speech service only when needed
- Dispose cubit and service on page close
- Cleanup recorded audio files
- No impact on existing features if voice disabled

## References

- [speech_to_text pub.dev](https://pub.dev/packages/speech_to_text)
- [Flutter speech recognition tutorial](https://pub.dev/packages/speech_to_text/example)
- [Apple Speech Framework docs](https://developer.apple.com/documentation/speech)
- [Google Speech-to-Text API](https://developers.google.com/web/updates/2013/02/voice-driven-web-apps-introduction-to-the-web-speech-api)
