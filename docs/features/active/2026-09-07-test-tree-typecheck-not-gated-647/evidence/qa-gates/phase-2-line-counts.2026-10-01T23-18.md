# Phase 2 line counts (#647)

Timestamp: 2026-10-01T23-18
Command: grep -c '' <each of the 11 Phase 2 paths>
EXIT_CODE: 0

| Path | Lines |
|---|---|
| extensions/drm-copilot/test/lib/executable-resolver.test.ts | 241 |
| extensions/drm-copilot/test/lib/file-system.test.ts | 184 |
| extensions/drm-copilot/test/lib/new-active-feature-folder/models.test.ts | 300 |
| extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts | 262 |
| extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts | 494 |
| extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts | 263 |
| extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts | 212 |
| extensions/drm-copilot/test/lib/resolve/file-prompt-core.test.ts | 244 |
| extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts | 416 |
| extensions/drm-copilot/test/lib/resolve/hard-lock-prompt.test.ts | 345 |
| extensions/drm-copilot/test/lib/resolve/resolve-prompts-service-call.test.ts | 241 |

Output Summary: every count is at most 500 (maximum 494, claude-config-carriage.test.ts, 488 + 6 for the two guards).
