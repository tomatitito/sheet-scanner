---
id: sheet-scanner-5ew
status: closed
deps: []
links: []
created: 2025-12-27T18:00:30.748527+01:00
type: task
priority: 1
---
# Switch Whisper model from base to tiny for faster transcription

Whisper base model is too slow on Android - transcription takes 1-5+ minutes. Switch to tiny model (5-10x faster) which still provides reasonable accuracy. Update WhisperRecognitionServiceImpl to use WhisperModel.tiny instead of WhisperModel.base. Test transcription speed on Android device.


