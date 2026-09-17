# Remediation Baseline — PoshQC Test and Coverage (issue #671, R1)

Timestamp: 2026-09-17T09-44
Task: [P0-T7]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686` (coverage enabled by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), bracketed (D9) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/freshness.ps1`; reports read (D2, D4) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p0t7-parse.ps1` (dot-sources `reportlib.ps1`; `[xml](Get-Content -Raw -LiteralPath ...)`).
EXIT_CODE: 8
MCP disposition (D1): `ok: false`, summary `Command exited with code 8.` The stderr excerpt carried output from the release-publish verifier tests (lines beginning `Publish verification for tag 'mcp-server-v0.0.2' returned ...`); by D1 no value below is read from the MCP result.
Helpers hash at parse time: `5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1` (unmodified; equals [P0-T4]).

Output Summary:

D9 report freshness:

| Report | Pre-call `LastWriteTimeUtc` (captured 2026-09-17T13:40:49Z) | Post-call `LastWriteTimeUtc` (captured 2026-09-17T13:44:22Z) | Fresh |
| --- | --- | --- | --- |
| `artifacts/pester/pester-junit.xml` | 2026-09-17T12:27:34.6287954Z | 2026-09-17T13:44:17.1883893Z | yes |
| `artifacts/pester/powershell-coverage.xml` | 2026-09-17T12:26:50.9797579Z | 2026-09-17T13:43:31.3241259Z | yes |

JUnit root (D2): `tests=4597`, `failures=8`, `errors=0`, `disabled=9`.

Failed testcases (8 entries, equal to `failures`):

| # | name | classname (normalized, repository-relative suffix) | Classification |
| --- | --- | --- | --- |
| 1 | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | contains `issue #671` |
| 2 | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | contains `issue #671` |
| 3 | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | contains `issue #671` |
| 4 | `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Payload S11 baseline name 1 |
| 5 | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | Payload S11 baseline name 2 |
| 6 | `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value` | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | contains `issue #671` |
| 7 | `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value` | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | contains `issue #671` |
| 8 | `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value` | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | contains `issue #671` |

(The recorded `classname` values are absolute paths under `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686\`; the table shows the normalized repository-relative suffix.)

Coverage (D4):

- Report-level LINE: `covered=8970`, `missed=432`, percentage `95.4052%` (8970 / 9402).
- `.claude/hooks` helpers copy: `covered=140`, `missed=11`, percentage `92.7152%` (below the 112/118 = 94.92% baseline, as the review recorded).
- `.codex/hooks` helpers copy: `covered=140`, `missed=11`, percentage `92.7152%`.
- `.claude/hooks` zero-hit lines: `[180,253,254,258,259,299,319,348,354,406,423]`.

`ci` of the `.claude/hooks` copy at the listed lines:

| Line | ci |
| --- | --- |
| 180 | 0 |
| 253 | 0 |
| 254 | 0 |
| 258 | 0 |
| 259 | 0 |
| 319 | 0 |

Acceptance: D9 freshness holds for both reports; every value is numeric; the failing-node enumeration has exactly 8 entries (= `failures`); lines 253, 254, 258, 259, and 319 record `ci` 0 as expected; every `Failed` testcase is one of the two Payload S11 baseline names or contains `issue #671`. Phase 1 is not blocked by [P0-T7].

Note: the first parse attempt printed `covered=0 missed=0` for the per-file entry because the scratchpad reader returned a single `XmlElement` through the pipeline, which unrolled it. The reader was corrected to return arrays with `Write-Output -NoEnumerate`, and the values above come from the corrected re-parse of the same, unchanged report files.
