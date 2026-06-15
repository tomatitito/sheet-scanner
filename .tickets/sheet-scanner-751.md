---
id: sheet-scanner-751
status: closed
deps: [sheet-scanner-wjw]
links: []
created: 2026-01-10T16:23:50.6777+01:00
type: feature
priority: 3
---
# Add AI post-processing for dictation text cleanup

Enhance dictation quality further by adding optional AI post-processing to clean up transcribed text, similar to Wispr Flow's auto-editing feature.

Features:
- Automatic punctuation correction
- Grammar improvements
- Music terminology normalization (e.g., 'opus' vs 'Opus')
- Composer name capitalization
- Number formatting (Op. 27, K. 331, etc.)

Implementation options:
- Use GPT-4 API for text cleanup (add toggle in settings)
- Local rule-based post-processing for common music terms
- Configurable aggressiveness (light/medium/heavy editing)

Dependencies: sheet-scanner-wjw (needs working transcription first)
Estimated effort: 3-4 hours


