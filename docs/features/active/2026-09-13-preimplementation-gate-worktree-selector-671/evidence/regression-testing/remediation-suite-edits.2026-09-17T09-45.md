# Remediation Suite Edits (issue #671, R1)

Timestamp: 2026-09-17T09-55
Task: [P3-T9]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/suitecheck.ps1` — per suite: `[System.Management.Automation.Language.Parser]::ParseFile(...)` error count, `@(Get-Content -LiteralPath <p>).Count` (D7), and the `Select-String -SimpleMatch` count of lines containing `@{ Label = 'issue #671 `.
EXIT_CODE: 0

| Suite | ParseFile errors | Lines (D7) | `@{ Label = 'issue #671 ` lines | SHA256 |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 0 | 431 | 45 | D5A41569453E16EE15176B87EA1F50090B6EA02541A1F17A9F4CA5E51145FAA8 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 0 | 438 | 45 | E794A7607E2B66B53CE1D51DDB9AA58D74C28B116BC02FD62CF834642CA2E691 |

Output Summary: both parse error counts are 0; both line counts are at most 500 (431 and 438); the `@{ Label = 'issue #671 ` count is 45 in each suite (7 allow + 18 deny + 5 empty-token + 15 predicate rows; the guard node is an `It` with no row). Edit placement verified by `Select-String -SimpleMatch` in [P3-T1]–[P3-T8]: L3a/L3b row lines carry the new commands (Claude L326/L327, Codex L333/L334); the RF-3 row sits directly after the L8 row (Claude L334→L335, Codex L341→L342); the two new Contexts and the guard `It` appear once in each suite; the Claude suite has no `Get-CodexExemptionDecisionForCommand` and the Codex suite has no `Get-ExemptionDecisionForCommand -Command`.
