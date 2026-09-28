# Remediation Regression Guards (issue #671, R1)

Timestamp: 2026-09-17T09-59
Task: [P4-T2]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p4-parse.ps1` — reads (D2) the `artifacts/pester/pester-junit.xml` written by the [P4-T1] `mcp__drm-copilot__run_poshqc_test` call (post-call LastWriteTimeUtc 2026-09-17T13:59:36.3702124Z).
EXIT_CODE: 0

Output Summary:

| Value | Claude command-exemption suite | Codex command-exemption suite |
| --- | --- | --- |
| testcases whose name contains `.issue #539 fail-closed rule table deny cases.` | 45 | 45 |
| of those, Passed | 45 | 45 |
| testcases whose name contains `.issue #539 orchestration-tree staging exemption allow cases.` | 8 | 8 |
| of those, Passed | 8 | 8 |
| `denies D4 row 14b - a directory-relocating option before the subcommand` | 1 match / Passed | 1 match / Passed |
| `denies D4 row 14c - a git-dir option before the subcommand` | 1 match / Passed | 1 match / Passed |
| `denies D4 row 14d - a work-tree option before the subcommand` | 1 match / Passed | 1 match / Passed |

Parity suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`:
- `testsuite`: `tests=2`, `failures=0`, `errors=0`, `skipped=0`, `disabled=0` (1 element matched).
- `keeps all four surface copies of the helpers module byte-identical by SHA256 hash`: 1 match / Passed.
- `keeps every surface copy of the helpers module under the 500-line cap`: 1 match / Passed.

Acceptance: 45 of 45 deny rows and 8 of 8 allow rows are Passed in each command-exemption suite; each D4 row 14 node matches exactly one Passed testcase; the parity suite has tests 2 and failures 0 with both nodes Passed. PASS.
