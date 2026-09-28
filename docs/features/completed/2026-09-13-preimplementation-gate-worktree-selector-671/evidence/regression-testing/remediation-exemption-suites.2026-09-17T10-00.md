# Remediation Exemption Suites — Targeted Verification (issue #671, R1)

Timestamp: 2026-09-17T09-59
Task: [P4-T1]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686`, bracketed (D9) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/freshness.ps1`; the JUnit report is read (D2) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p4-parse.ps1`.
EXIT_CODE: 2
MCP disposition (D1): `ok: false`, summary `Command exited with code 2.` No value below is read from the MCP result.
Helpers hash at parse time: `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989` (post-edit; equals [P2-T9])

Output Summary:

D9 report freshness:

| Report | Pre-call (captured 2026-09-17T13:56:08Z) | Post-call (captured 2026-09-17T13:59:41Z) | Fresh |
| --- | --- | --- | --- |
| `artifacts/pester/pester-junit.xml` | 2026-09-17T13:44:17.1883893Z | 2026-09-17T13:59:36.3702124Z | yes |
| `artifacts/pester/powershell-coverage.xml` | 2026-09-17T13:43:31.3241259Z | 2026-09-17T13:58:50.2241850Z | yes |

Run context: JUnit root `tests=4641`, `failures=2`, `errors=0`, `disabled=9`. The two failures are the Payload S11 baseline names (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`; `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`), which accounts for exit code 2.

Per-suite values:

| Value | Claude suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | Codex suite `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` |
| --- | --- | --- |
| `testsuite` elements matched | 1 | 1 |
| `tests` | 105 | 105 |
| `failures` | 0 | 0 |
| `errors` | 0 | 0 |
| `skipped` | 0 | 0 |
| `disabled` | 0 | 0 |
| `testcase` names containing `.issue #671 ` | 46 | 46 |
| of those, `Passed` | 46 | 46 |

Named nodes (D2 node selection: classname ends with the suite path and name ends with `.` + It text):

| Node | Claude matches / status | Codex matches / status |
| --- | --- | --- |
| `denies issue #671 LACS L8 - empty selector value` | 1 / Passed | 1 / Passed |
| `denies issue #671 selector followed by an unmodelled subcommand` | 1 / Passed | 1 / Passed |
| `denies issue #671 empty token beside a non-exempt operand` | 1 / Passed | 1 / Passed |
| `denies issue #671 empty token after the separator beside a non-exempt operand` | 1 / Passed | 1 / Passed |
| `denies issue #671 trailing empty token after a non-exempt operand` | 1 / Passed | 1 / Passed |
| `denies issue #671 empty commit message beside a non-exempt operand` | 1 / Passed | 1 / Passed |
| `allows issue #671 empty commit message beside an exempt operand` | 1 / Passed | 1 / Passed |
| `denies issue #671 LACS L3a - selector with no subcommand after the value` | 1 / Passed | 1 / Passed |
| `denies issue #671 LACS L3b - subcommand not immediately after the selector value` | 1 / Passed | 1 / Passed |
| `returns false when segment classification raises an error` | 1 / Passed | 1 / Passed |

Acceptance: D9 freshness holds for both reports; in each suite `tests` is 105, `failures` 0, `errors` 0; the `.issue #671 ` count is 46 with all 46 Passed; each of the ten named nodes matches exactly one Passed testcase. PASS. No restart was required.
