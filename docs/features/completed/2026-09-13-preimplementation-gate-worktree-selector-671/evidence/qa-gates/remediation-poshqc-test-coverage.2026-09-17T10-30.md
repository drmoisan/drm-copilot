# Remediation Final QA — PoshQC Test and Coverage (issue #671, R1)

Timestamp: 2026-09-17T10-09
Task: [P6-T3] (final QA loop, pass 1)
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686` (coverage enabled by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), bracketed (D9) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/freshness.ps1`; reports read (D2, D4) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p6-parse.ps1`.
EXIT_CODE: 2
ExpectedExitCode: 2
MCP disposition (D1): `ok: false`, summary `Command exited with code 2.` The two failing nodes are both Payload S11 baseline names, so the expected exit code is 2.
Helpers hash at parse time: `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989`

Output Summary:

D9 report freshness:

| Report | Pre-call (captured 2026-09-17T14:05:04Z) | Post-call (captured 2026-09-17T14:08:55Z) | Fresh |
| --- | --- | --- | --- |
| `artifacts/pester/pester-junit.xml` | 2026-09-17T13:59:36.3702124Z | 2026-09-17T14:08:49.7997201Z | yes |
| `artifacts/pester/powershell-coverage.xml` | 2026-09-17T13:58:50.2241850Z | 2026-09-17T14:08:04.6398181Z | yes |

JUnit root (D2): `tests=4641`, `failures=2`, `errors=0`, `disabled=9`.

Failed testcases (2):

| name | classname (repository-relative suffix) |
| --- | --- |
| `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` |
| `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` |

Coverage (D4):

| Measure | [P0-T7] baseline (restated) | Post-change |
| --- | --- | --- |
| Report-level LINE covered / missed | 8970 / 432 | 8986 / 418 |
| Report-level LINE percentage | 95.4052% | 95.5551% |
| `.claude/hooks` helpers covered / missed | 140 / 11 (92.7152%) | 147 / 5 (96.7105%) |
| `.codex/hooks` helpers covered / missed | 140 / 11 (92.7152%) | 147 / 5 (96.7105%) |

Post-change `.claude/hooks` zero-hit lines: `[301,350,356,408,425]`. All five are lines that were already unexecuted before this change (pre-change 180 is now covered; 299/348/354/406/423 moved to 301/350/356/408/425), and none is in the [P5-T2] changed-line set.

`ci` of the `.claude/hooks` copy at the [P2-T4] K1–K7 lines:

| Id | Line | ci |
| --- | --- | --- |
| K1 | 255 | 1 |
| K2 | 256 | 1 |
| K3 | 260 | 1 |
| K4 | 261 | 1 |
| K5 | 321 | 1 |
| K6 | 180 | 1 |
| K7 | 438 | 1 |

Acceptance:
- (0) D9 freshness holds for both reports: PASS.
- (a) `errors` is 0; both failing nodes' names equal the two Payload S11 baseline names; no failing node's name contains `issue #671`: PASS.
- (b) Report-level LINE percentage 95.5551% >= 85: PASS.
- (c) `.claude/hooks` ratio 147/152 = 0.96711 >= 112/118 = 0.94915 (147 × 118 = 17346 >= 112 × 152 = 17024); `.codex/hooks` ratio identical: PASS.
- (d) Each K1–K7 line has `ci` > 0: PASS.

No restart was required.
