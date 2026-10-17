# AC-2 Host-Path Count Baseline (P0-T8, Issue #934)

Timestamp: 2026-10-16T00-12
Command: git grep -c -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts
EXIT_CODE: 0
Output Summary:
- extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts:3
- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts:35
- Both files report a count > 0 (WE-TEST 35, STR-TEST 3), matching the planner's static reading; the AC-2 search is non-vacuous on each file. No regex error (exit code was not 128).
