---
id: sheet-scanner-5nn
status: closed
deps: []
links: []
created: 2025-12-26T18:18:13.954855+01:00
type: task
priority: 2
---
# Add cancel functionality to voice dictation for long-running recordings

When dictation is taking too long or doesn't seem to be working, users should be able to quickly cancel the operation instead of waiting for the timeout. Add a cancel button or gesture.

## Notes

Implemented cancel functionality for voice dictation:
1. Added Cancel button that appears during recording (orange button with close icon)
2. Button stops recording immediately and discards any transcribed text
3. Added _cancelRequested flag in DictationCubit to properly handle cancellation
4. When cancel is pressed, the cubit returns to idle state without emitting a result
5. Cancel button appears below the microphone listening indicator for easy access


