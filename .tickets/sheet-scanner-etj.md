---
id: sheet-scanner-etj
status: closed
deps: [sheet-scanner-wjw]
links: []
created: 2026-01-10T16:23:36.430141+01:00
type: feature
priority: 2
---
# Add user settings for dictation quality preferences

Create settings UI allowing users to configure dictation behavior:
- Quality mode: Cloud (high quality) vs Local (fast, offline)
- Auto mode: Use cloud when online, local when offline
- API key management (show/hide, validate, clear)
- Usage statistics display (optional)

Scope:
- Add settings page/section for dictation
- Implement SharedPreferences for preference storage
- Add API key input with validation
- Create quality mode selector UI
- Add explainer text about tradeoffs

Dependencies: sheet-scanner-wjw (needs API implementation to configure)
Estimated effort: 2 hours


