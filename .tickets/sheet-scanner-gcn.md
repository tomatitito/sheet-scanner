---
id: sheet-scanner-gcn
status: closed
deps: []
links: []
created: 2025-12-27T16:36:40.914172+01:00
type: task
priority: 1
---
# Fix Whisper audio recording integration - need audio capture solution

Whisper speech recognition engine is now integrated but returns error when user attempts dictation: 'Whisper Engine requires an audio file input.'

PROBLEM:
- WhisperRecognitionServiceImpl.startListening() doesn't actually record audio
- It just returns an error message telling user to use device native speech recognition
- This is a blocker for Whisper functionality

SOLUTION NEEDED:
1. Find a stable audio recording package compatible with all platforms (iOS/Android)
   - Investigate: flutter_audio_recorder, just_audio_recorder, or platform channels
   - Must work offline and capture to temporary WAV/PCM file
   - Must capture at 16kHz (Whisper requirement)
   
2. Integrate audio recording with WhisperRecognitionServiceImpl:
   - Record audio in startListening()
   - Save to temporary file
   - Pass audio file to _whisper.transcribe()
   - Handle cleanup of temporary files
   
3. Test on iOS and Android devices:
   - Verify microphone permission handling
   - Test audio quality and transcription accuracy
   - Measure performance impact

ACCEPTANCE CRITERIA:
- User can tap microphone button and dictate
- Audio is recorded and transcribed using Whisper
- Whisper accuracy is noticeably better than device native API
- Works offline without internet
- No compilation errors on iOS/Android
- All tests pass


