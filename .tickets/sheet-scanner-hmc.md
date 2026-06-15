---
id: sheet-scanner-hmc
status: closed
deps: [sheet-scanner-wjw]
links: []
created: 2026-01-10T16:23:30.306395+01:00
type: feature
priority: 2
---
# Add hybrid speech service with cloud + local fallback

Implement hybrid approach that uses OpenAI Whisper API when online but falls back to local Whisper model when offline. Provides best user experience with high quality online and offline capability.

Scope:
- Create HybridSpeechRecognitionService wrapper
- Add internet connectivity detection
- Implement automatic fallback logic
- Add user notifications about quality mode (cloud vs local)
- Handle graceful degradation on network failures

Dependencies: sheet-scanner-wjw (OpenAI API implementation must exist first)
Estimated effort: 1-2 hours


