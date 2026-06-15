---
id: sheet-scanner-u08
status: closed
deps: []
links: []
created: 2025-12-27T15:20:44.085351+01:00
type: task
priority: 3
---
# Fix failing speech recognition repository tests

The following tests are failing due to mock setup issues:
- SpeechRecognitionRepositoryImpl startVoiceInput() returns DictationResult
- SpeechRecognitionRepositoryImpl startVoiceInput() returns failure when error occurs
- SpeechRecognitionRepositoryImpl startVoiceInput() passes correct language to service
- SpeechRecognitionRepositoryImpl startVoiceInput() respects listenFor duration
- All DictationResult property tests
- stopVoiceInput() and cancelVoiceInput() tests

Error: 'type Null is not a subtype of type Future<List<String>>'
The MockSpeechRecognitionService.availableLanguages mock is returning null instead of Future<List<String>>

These tests are not blocking functionality but should be fixed to properly mock the service interface.

## Notes

Fixed by setting up default mock for availableLanguages in setUp() to return Future<List<String>>. Added comment explaining the fix to prevent future regressions.


