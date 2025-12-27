# Dictation Hang Investigation - sheet-scanner-5n3

## Issue Summary
User experiences dictation hanging with spinner on Android despite error handling. No error message appears, UI remains in "listening" state indefinitely.

## Investigation Results

### Code Execution Flow

```
User taps dictation button
↓
DictationCubit.startDictation() [line 42]
  ↓
  emit(listening state) 
  ↓
  _transcribeVoiceUseCase.call(params) [line 74] ← WAITS HERE if blocking occurs
  ↓
  SpeechRecognitionRepositoryImpl.startVoiceInput() [data/repositories/...]
    ↓
    Create _listenCompleter [line 69]
    ↓
    _speechService.startListening() [line 76-102] 
      ↓
      _audioRecorder.start(config, path) [line 186] ← POTENTIAL HANG POINT 1
        ↓ (returns path or null)
      ↓
      _autoStopAndTranscribeAsync() [line 98] - Schedules async work
        ↓ (immediately returns, doesn't block)
    ↓ (startListening() returns)
    ↓
    await _listenCompleter.future.timeout(...) [line 107-120] ← WAITS HERE for 31+ seconds
      ← Needs onResult(isFinal=true) or onError() or timeout
    ↓
    Return result
  ↓
  _stopElapsedTimer()
  ↓
  emit(complete/error state)
```

### Critical Blocking Points

#### **Point 1: `_audioRecorder.start()`** (whisper_service.dart:186)
```dart
await _audioRecorder.start(config, path: audioPath);
```

**Problem**: The `record` package (v6.1.2) may:
- Hang on Android Q+ devices during microphone initialization
- Fail silently if there's a device-specific audio system issue
- Block indefinitely if the audio recording process encounters a permission/system error

**Evidence**:
- No try-catch wrapper logs any stack trace if start() hangs
- If start() hangs, `startListening()` never returns
- If `startListening()` never returns, the repository's await (line 76) also never completes
- The cubit's await (line 74) blocks forever

**Current Logging**: Added trace logging to measure start() duration, but if it hangs, the logs never appear

---

#### **Point 2: `_whisper.transcribe()`** (whisper_service.dart:377)
```dart
final result = await _whisper.transcribe(
  transcribeRequest: TranscribeRequest(
    audio: audioPath,
    isTranslate: false,
    isNoTimestamps: true,
  ),
);
```

**Problem**: The `whisper_flutter_new` package may:
- Hang during model loading on first run
- Fail if audio file is corrupted or incompatible
- Block indefinitely if native code encounters an issue
- Not invoke the callback if an internal exception occurs

**Evidence**:
- `_autoStopAndTranscribeAsync()` is scheduled at line 98 but doesn't immediately block
- The async callback (lines 115-127) awaits `_autoStopAndTranscribe()` 
- If `_transcribeRecordedAudio()` calls `transcribeAudioFile()` (line 237), which then hangs on `_whisper.transcribe()`, the callback is suspended indefinitely
- The completer never receives `onResult()` or `onError()`, so it only resolves on timeout (31 seconds later)

**Current Logging**: Added trace logging around the transcribe() call

---

#### **Point 3: Callback Never Invoked**
If either `onResult()` or `onError()` is never called from the service, the completer will wait for the full timeout (31 seconds).

**Causes**:
- Exception thrown in `_autoStopAndTranscribeAsync()` but not caught (unlikely - we added try/catch)
- The async callback silently fails or throws an unhandled exception
- Audio file validation fails but onError() isn't called (unlikely - we check for this)

---

### Why Error Handling Doesn't Help

The error handling implementation in `whisper_service.dart` (added in previous fix) is comprehensive:

✅ `_autoStopAndTranscribeAsync()` has try/catch (line 115)  
✅ `_autoStopAndTranscribe()` has try/catch (line 135)  
✅ `_transcribeRecordedAudio()` has try/catch (line 203)  
✅ `stopListening()` has try/catch (line 275)  
✅ `transcribeAudioFile()` has try/catch (line 374)  

**BUT**, if the issue is at the lowest level (inside `_audioRecorder.start()` or `_whisper.transcribe()`), these callbacks hang and never reach the error handlers.

---

## Recommendations for Fix

### **Immediate Fixes** (address the hang without redesigning)

#### 1. **Add Explicit Recording Validation**
After calling `_audioRecorder.start()`, immediately check if recording actually started:

```dart
await _audioRecorder.start(config, path: audioPath);

// NEW: Verify recording actually started
final recordingStarted = await _audioRecorder.isRecording();
if (!recordingStarted) {
  _isListening = false;
  onError('Audio recording failed to start');
  return;
}
```

**Why**: This will catch if `start()` returns without actually initializing recording.

---

#### 2. **Add Timeout to Audio Recording Start**
Wrap the `start()` call in a timeout to catch hangs:

```dart
try {
  await _audioRecorder.start(config, path: audioPath).timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      throw TimeoutException('Audio recorder start() timeout after 5 seconds');
    },
  );
} catch (e) {
  _isListening = false;
  onError('Failed to start audio recording: ${e.toString()}');
  return;
}
```

---

#### 3. **Add Timeout to Whisper Transcription**
The `transcribeAudioFile()` call may block indefinitely during model loading:

```dart
final transcription = await transcribeAudioFile(audioPath).timeout(
  const Duration(minutes: 2),
  onTimeout: () {
    throw TimeoutException('Whisper transcription timeout after 2 minutes');
  },
);
```

**Why**: Prevents infinite hangs if Whisper model initialization fails.

---

#### 4. **Improved Logging at Critical Boundaries**
Ensure we log when entering/exiting potentially blocking operations:

```dart
debugPrint('[CRITICAL] About to call _audioRecorder.start()...');
final recordStart = DateTime.now();
await _audioRecorder.start(config, path: audioPath);
final recordDuration = DateTime.now().difference(recordStart);
debugPrint('[CRITICAL] _audioRecorder.start() completed in ${recordDuration.inSeconds}s');

if (recordDuration.inSeconds > 3) {
  debugPrint('[WARNING] Audio recording start took ${recordDuration.inSeconds}s, may indicate issue');
}
```

---

### **Diagnostic Approach**

To identify exactly where the hang occurs, use the comprehensive logging added to the code:

```
[CUBIT-TRACE] startDictation called
  ↓
[CUBIT-TRACE] Calling _transcribeVoiceUseCase.call()...
  ↓
[REPO-TRACE] startVoiceInput called with listenFor=30s
[REPO-TRACE] Checking if service is available...
[REPO-TRACE] Service is available
[REPO-TRACE] Initializing service...
[REPO-TRACE] Service initialized
[REPO-TRACE] Calling _speechService.startListening()...
  ↓
[TRACE] startListening called with listenFor=30s
[TRACE] Checking microphone availability...
[TRACE] Microphone available
[TRACE] Emitting listening started event
[TRACE] Starting audio recording...
[TRACE] Calling _audioRecorder.start()...
  ↓ IF HANG: Logs stop here ← `_audioRecorder.start()` is blocking
  ↓ IF OK: 
[TRACE] _audioRecorder.start() completed in XXms
[TRACE] Audio recording initiated at: /path/to/file.wav
[TRACE] _autoStopAndTranscribeAsync scheduled: will fire in 30s
  ↓ (wait 30+ seconds)
[TRACE] _autoStopAndTranscribeAsync firing after ~30000ms
[TRACE] _isListening=true, calling _autoStopAndTranscribe
[TRACE] Auto-stop triggered: stopping audio recorder
  ↓ IF HANG: Logs stop here ← Next operation is blocking
  ↓ IF OK:
[TRACE] Calling Whisper transcribe on: /path/to/file.wav
[TRACE] Calling _whisper.transcribe()...
  ↓ IF HANG: Logs stop here ← `_whisper.transcribe()` is blocking
  ↓ IF OK:
[TRACE] _whisper.transcribe() completed in XXs
[TRACE] Transcription result length: NNN chars
✓ Whisper transcription complete: "..."
  ↓
[REPO-TRACE] onResult callback: text="...", isFinal=true
[REPO-TRACE] isFinal=true, completing completer with text="..."
[REPO-TRACE] Completer future resolved after XXs
[CUBIT-TRACE] _transcribeVoiceUseCase.call() returned after XXs
[CUBIT-TRACE] Got success result: "..."
  ↓
emit(complete state)
```

---

## Test Plan

### Setup
1. Build app with enhanced logging: `fvm flutter run -d <device>`
2. Connect to device via ADB
3. Start logcat: `adb logcat flutter:V | grep "\[TRACE\]\|\[ERROR\]"`
4. Navigate to Add Sheet Music form
5. Tap dictation button
6. Speak clearly for 3-5 seconds
7. Wait for result or timeout

### Expected Behavior (with fix)
- Logs show each step
- If hang occurs, logs pinpoint exact location
- With timeout fixes: Hang replaced with timeout error message

### Current Behavior (without fix)
- If hang occurs, logs stop at blocking point
- UI spinner shows for 30+ seconds
- No error message appears

---

## Files Modified (This Session)

1. `lib/core/services/whisper_service.dart` - Added detailed [TRACE] logging
2. `lib/features/sheet_music/data/repositories/speech_recognition_repository_impl.dart` - Added [REPO-TRACE] logging  
3. `lib/features/sheet_music/presentation/cubit/dictation_cubit.dart` - Added [CUBIT-TRACE] logging

---

## Next Steps

1. **Run diagnostic test** on device with logging enabled to identify exact blocking point
2. **Implement timeout fixes** based on where hang is detected
3. **Add fallback handling** for Whisper model initialization failures
4. **Test on multiple Android devices** (API 28-36) to identify device-specific issues
5. **Consider alternative audio recording package** if record package is unreliable on Android
