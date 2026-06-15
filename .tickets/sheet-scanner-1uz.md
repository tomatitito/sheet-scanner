---
id: sheet-scanner-1uz
status: closed
deps: []
links: []
created: 2025-12-27T16:11:25.106525+01:00
type: task
priority: 1
---
# Implement Whisper for improved voice dictation accuracy

Replace current speech_to_text plugin with OpenAI's Whisper for significantly improved voice dictation accuracy on sheet music metadata (titles, composers, notes).

Current Issues:
- speech_to_text plugin struggles with short utterances (titles)
- Poor handling of music terminology and technical terms
- Inconsistent accuracy across different accents and speech patterns
- Device-dependent quality (varies by phone manufacturer)

Whisper Advantages:
- Superior accuracy on short phrases and technical terms
- Handles musical terminology better
- Works offline (one-time model download)
- Consistent quality across all devices
- Better noise handling

Implementation Plan:
1. Evaluate flutter_whisper or similar packages for Dart/Flutter
2. Create SpeechRecognitionServiceWhisper as alternative implementation
3. Abstract service interface to support both old and new implementations
4. Add feature flag to switch between speech_to_text and Whisper
5. Update DictationCubit to work with new service
6. Test on actual device/emulator
7. Compare accuracy vs current implementation
8. Replace speech_to_text with Whisper as default

Acceptance Criteria:
- Whisper integration compiles without errors
- Title dictation accuracy > 95% on common titles
- Works offline without internet
- No breaking changes to existing UI
- Feature can be toggled via configuration


