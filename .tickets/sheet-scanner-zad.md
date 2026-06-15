---
id: sheet-scanner-zad
status: closed
deps: []
links: []
created: 2025-12-27T15:39:18.56923+01:00
type: bug
priority: 1
---
# Dictation activates all microphone buttons and writes to all fields

When user taps the microphone button for the title field, dictation is activated for all fields simultaneously. The dictated text is written into all input fields instead of just the target field. This is a regression introduced in the recent German dictation fix.

## Notes

Fixed by changing DictationCubit from registerSingleton to registerFactory so each VoiceInputButton gets its own cubit instance instead of sharing a global singleton


