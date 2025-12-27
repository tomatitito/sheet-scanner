# Dictation Hang Analysis - sheet-scanner-3pb

## Issue Summary
Whisper dictation hangs on Android with no response when user attempts to dictate.

## Root Causes Identified

### 1. **Fire-and-Forget Future Pattern (PRIMARY ISSUE)**
**Location**: `WhisperRecognitionServiceImpl.startListening()`, lines 96-100

```dart
Future.delayed(listenFor).then((_) async {
  if (_isListening) {
    await _autoStopAndTranscribe(onResult, onError);
  }
});
```

**Problem**: 
- This Future is not awaited or tracked
- Returns control to caller immediately without waiting for transcription
- The `_autoStopAndTranscribe()` async operation is spawned but not awaited
- If an exception occurs in the delayed callback, it's lost (no error handler)
- The completer in `SpeechRecognitionRepositoryImpl` waits indefinitely for a result that may never come

**Impact**: 
- The Cubit waits forever on line 74 of `dictation_cubit.dart`: `final result = await _transcribeVoiceUseCase.call(params);`
- UI becomes unresponsive because the state never transitions from `listening` to `complete`/`error`

### 2. **Android Audio Recording Initialization Issues (SECONDARY)**
**Location**: `WhisperRecognitionServiceImpl._startAudioRecording()`, line 155

```dart
await _audioRecorder.start(config, path: audioPath);
```

**Potential Issues**:
- The `record` package may fail silently on Android due to:
  - Permission runtime check passing but audio recording still failing
  - Microphone unavailable at recording time
  - AudioRecord API issues (Android Q+ scoped storage, device-specific issues)
  - WAV encoding not properly supported on the specific Android device
- No try-catch verification that recording actually started

**Impact**: 
- Recording fails but `isAvailable()` passes (permissions check)
- Audio file never gets created
- Auto-stop transcription has no file to process
- Completer never resolves

### 3. **Missing Error Propagation**
**Location**: Multiple locations in `whisper_service.dart`

- Errors in the `Future.delayed().then()` callback are not propagated to the `onError` callback
- If recording fails, there's no way to know about it from the async callback

## Code Flow Analysis

```
startListening()
  ↓ [async, not awaited]
Future.delayed(listenFor).then((_) async {
  ↓ [if recording failed, this has no audio file]
_autoStopAndTranscribe()
  ↓
_transcribeRecordedAudio()
  ↓ [audio file doesn't exist, fails validation]
onError() callback (but only if completer exists)
```

```
Repository Flow:
startVoiceInput()
  ↓
_speechService.startListening() [returns immediately]
  ↓
await _listenCompleter!.future.timeout(...) [BLOCKS FOREVER if completer never resolves]
```

## Symptoms

1. **User Experience**: 
   - Taps dictation button
   - Button shows listening state (pulsing animation)
   - After 30 seconds: nothing happens
   - No error message, no result
   - Must manually cancel

2. **Expected Behavior**: 
   - Should transcribe after 30 seconds and show result
   - Or show error if microphone failed

## Solution

### Fix 1: Remove Fire-and-Forget Pattern
Track the auto-stop Future and ensure errors are properly handled.

### Fix 2: Add Recording Validation
Verify that audio recording actually started before returning from `_startAudioRecording()`.

### Fix 3: Ensure Error Callbacks Work
Make sure all error paths invoke the `onError` callback that completes the completer.

### Fix 4: Add Comprehensive Logging
Add debug logging to track state changes throughout the recording/transcription lifecycle.
