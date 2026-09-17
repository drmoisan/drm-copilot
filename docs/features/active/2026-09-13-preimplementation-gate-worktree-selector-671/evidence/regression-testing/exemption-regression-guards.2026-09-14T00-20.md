# Retained Regression Guards (issue #671)

Timestamp: 2026-09-17T08-13
Task: [P3-T6]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]); then `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:13:12) read by a scratchpad parser under pwsh 7.6.6. Selections are scoped to `classname` ending with each suite path (forward-slash normalized), with Context-scoped `name` containment.
EXIT_CODE: 8
ExpectedExitCode: 8

Output Summary:
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 8."). The eight failing nodes are the three new-row failures per suite (L3a, L3b, L8; see [P3-T3] and [P3-T5]) plus the two baseline failures from [P0-T8]. No retained guard failed.
- Both suite `testsuite` elements are present (1 match each).
- Retained regression guards, per suite:
  - `.issue #539 fail-closed rule table deny cases.`: Claude count=45 (45 Passed); Codex count=45 (45 Passed).
  - `.issue #539 orchestration-tree staging exemption allow cases.`: Claude count=8 (8 Passed); Codex count=8 (8 Passed).
- D4 row-14 guards: each matches exactly one testcase per suite, status `Passed`. No assertion was reversed.

## D4 row-14 guard nodes

| Suite | It label | Matches | status |
| --- | --- | --- | --- |
| Claude | `denies D4 row 14b - a directory-relocating option before the subcommand` | 1 | Passed |
| Claude | `denies D4 row 14c - a git-dir option before the subcommand` | 1 | Passed |
| Claude | `denies D4 row 14d - a work-tree option before the subcommand` | 1 | Passed |
| Codex | `denies D4 row 14b - a directory-relocating option before the subcommand` | 1 | Passed |
| Codex | `denies D4 row 14c - a git-dir option before the subcommand` | 1 | Passed |
| Codex | `denies D4 row 14d - a work-tree option before the subcommand` | 1 | Passed |

Suite element attributes: Claude `tests=83 failures=3 errors=0 skipped=0 disabled=0`; Codex `tests=83 failures=3 errors=0 skipped=0 disabled=0`. The failures are the three new LACS rows only.
