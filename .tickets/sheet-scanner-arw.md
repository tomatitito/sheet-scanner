---
id: sheet-scanner-arw
status: closed
deps: []
links: []
created: 2025-12-26T17:22:21.007075+01:00
type: task
priority: 1
---
# Add microphone and internet permissions to Android manifest

ISSUE DIAGNOSIS:
The speech_to_text plugin requires Android permissions to be declared in AndroidManifest.xml. Without these permissions, the speech recognition service fails to initialize and reports 'speech recognition isn't available on this device' error.

REQUIRED CHANGES:
1. Add the following permissions to android/app/src/main/AndroidManifest.xml (outside the <application> block):
   - android.permission.RECORD_AUDIO (required for microphone access)
   - android.permission.INTERNET (required for Google Speech API)

CURRENT STATE:
- AndroidManifest.xml has no audio/internet permission declarations
- speech_to_text service checks for these permissions during initialization
- Permission handler checks for runtime permissions but manifest permissions are a prerequisite

IMPACT:
- User cannot use the dictation feature on Android
- Voice input buttons are present but non-functional
- Error is displayed when user tries to record audio


