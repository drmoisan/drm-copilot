# P2-T2 [expect-fail] - TypeScript adapter suite against the unfixed adapter

Timestamp: 2026-10-10T08-16
Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Test Suites: 1 failed, 1 total`; `Tests:       3 failed, 25 passed, 28 total` (planned: 3 failed, 25 passed, 28 total). The suite compiled and ran (no "Test suite failed to run").
- Failing tests (exactly T1, T2, T3 of Appendix C8):
  - `ExcludingFileSystem › excludes .claude/state files from enumeration` (received adds `/repo/.claude/state/budget.json`, `/repo/.claude/state/session/id.txt`)
  - `ExcludingFileSystem › excludes .claude/worktrees files from enumeration` (received adds `/repo/.claude/worktrees/wt/.claude/settings.json`, `/repo/.claude/worktrees/wt/README.md`)
  - `ExcludingFileSystem › excludes runtime directories even when the published set lists them` (received adds `/repo/.claude/state/budget.json`)
- T4 "retains lookalike paths outside the runtime directories" and T5 "passes a path outside the source root through the runtime-directory filter" passed, as did the 23 pre-existing tests.
- Result: PASS (planned red split observed exactly).
