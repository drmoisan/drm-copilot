# AC-2 Host-Path Search After Change (P2-T11, Issue #934)

Timestamp: 2026-10-16T01-17
Command: git grep -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts   (working directory: worktree root)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Output empty for both files: zero matching lines.
- Baseline (`evidence/baseline/ac2-hostpath-count.2026-10-16T00-12.md`) counts were greater than zero for each file; `evidence/baseline/regex-probe-negative.2026-10-16T00-14.md` showed the Option A templates do not match, and `evidence/baseline/regex-probe-positive.2026-10-16T00-14.md` showed the regex matches all three host-path shapes.
