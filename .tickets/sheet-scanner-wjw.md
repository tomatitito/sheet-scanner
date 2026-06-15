---
id: sheet-scanner-wjw
status: closed
deps: []
links: []
created: 2026-01-10T16:23:24.381356+01:00
type: feature
priority: 1
---
# Implement OpenAI Whisper API for high-quality dictation

Replace local Whisper Tiny model with OpenAI Whisper API (Large V3) to achieve 95%+ accuracy matching Wispr Flow quality. Current tiny model has poor accuracy making dictation practically unusable.

Scope:
- Add OpenAI API client with proper error handling
- Create API key configuration UI with SecureStorage
- Implement cloud-based WhisperRecognitionService
- Add network error handling and user feedback
- Update dependency injection to use new service
- Add settings toggle for quality mode preference

Dependencies: None
Estimated effort: 2-3 hours


