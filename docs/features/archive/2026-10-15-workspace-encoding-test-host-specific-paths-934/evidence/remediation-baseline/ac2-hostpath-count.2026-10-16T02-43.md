# AC-2 Baseline: HOSTPATH-REGEX on Both Test Files (P0-T9, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T02-43
Command: git grep -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Empty output; zero matching lines in either file. The cycle-0 fix holds before this cycle's edit.
- Non-vacuity of the regex on these files is recorded in `FEATURE/evidence/baseline/ac2-hostpath-count.2026-10-16T00-12.md` and `FEATURE/evidence/baseline/regex-probe-positive.2026-10-16T00-14.md`.
