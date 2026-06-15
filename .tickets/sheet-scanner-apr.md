---
id: sheet-scanner-apr
status: closed
deps: []
links: []
created: 2025-12-26T17:22:30.079637+01:00
type: task
priority: 2
---
# Improve speech recognition error messages and availability checks

ISSUE:
When speech recognition fails on Android, users see cryptic error messages like 'speech recognition isn't available on this device'. This doesn't help users understand WHY it's unavailable.

SUGGESTED IMPROVEMENTS:
1. Enhance SpeechRecognitionServiceImpl.isAvailable() to differentiate between:
   - Service not available (Google Play Services issue)
   - Manifest permissions missing
   - Runtime permission denied
   - Permanently denied permission

2. Provide specific error messages for each case:
   - 'Microphone permission required. Please enable in app settings.'
   - 'Google Play Services speech recognition not available.'
   - 'This device does not support speech recognition.'

3. Add a method to check if speech recognition is theoretically available (manifest + service)
   vs. runtime permission granted

4. Log detailed debug information about what check failed

ACCEPTANCE CRITERIA:
- Users get actionable error messages
- Voice button shows specific error when tapped (not just silent failure)
- Logs help developers diagnose issues quickly


