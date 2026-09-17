# Final QA — PoshQC Test with Coverage (issue #671)

Timestamp: 2026-09-17T08-27
Task: [P6-T3]
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, full repository test set, coverage enabled by the runsettings) as the route-compliance step; then `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:27:34) and `artifacts/pester/powershell-coverage.xml` (LastWriteTime 2026-09-17T08:26:50) read by a scratchpad parser under pwsh 7.6.6, per governing paragraphs 2 and 4
EXIT_CODE: 8
Status: FAIL (condition (a) not met). Conditions (b), (c), and (d) are met.

Output Summary:
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 8.", with the same publish-verification stderr excerpt as the baseline run).
- JUnit root `testsuites`: tests=4597, failures=8, errors=0, disabled=9; passed = 4597 - 8 - 0 - 9 = 4580.
- Baseline, restated from [P0-T8]: tests=4547, failures=2, errors=0, disabled=9, passed=4536.
- Coverage, post-change: report-level `counter type="LINE"` covered=8970, missed=432 -> 8970 / 9402 = 95.41%.
- Coverage, baseline (restated from [P0-T8]): covered=8914, missed=422 -> 8914 / 9336 = 95.48%.
- Per-file `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`: covered=140, missed=11 -> 92.72% (baseline 112/118 = 94.92%). `.codex/hooks/...-helpers.ps1`: 140/151 = 92.72%.
- Helpers line counts: 433 on each of the four copies.

## Condition evaluation

- (a) **Not met.** Post-change `failures` is 8, above the baseline of 2 (`errors` is 0, not above the baseline of 0). Six failing nodes are attributable to this change: they sit in the two command-exemption suites and their names contain `issue #671`.
- (b) Met: 95.41 >= 85.
- (c) Met: both percentages are recorded with their `covered`/`missed` pairs.
- (d) Met: 433 <= 500 on all four copies.

## Failing-node enumeration (8, equals `failures`)

| # | name | classname (suffix) | status | Attributable to this change |
| --- | --- | --- | --- | --- |
| 1 | `enforce-orchestration-preimplementation-gate.ps1 command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | Failed | yes |
| 2 | `...issue #671 worktree selector deny cases.denies issue #671 LACS L3b - subcommand not immediately after the selector value` | same Claude suite | Failed | yes |
| 3 | `...issue #671 worktree selector deny cases.denies issue #671 LACS L8 - empty selector value` | same Claude suite | Failed | yes |
| 4 | `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Failed | no (baseline) |
| 5 | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | Failed | no (baseline) |
| 6 | `Codex enforce-orchestration-preimplementation-gate command exemption (issue #539).issue #671 worktree selector deny cases.denies issue #671 LACS L3a - selector with no subcommand after the value` | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | Failed | yes |
| 7 | `...denies issue #671 LACS L3b - subcommand not immediately after the selector value` | same Codex suite | Failed | yes |
| 8 | `...denies issue #671 LACS L8 - empty selector value` | same Codex suite | Failed | yes |

Cause of nodes 1-3 and 6-8, recorded in `evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md`:
- L3a and L3b: the fixture commands carry no `add`/`commit`, so the gate trigger never classifies them and the gate allows them without consulting the exemption. This is a spec-table fixture defect.
- L8: the pre-existing empty-token fail-open at helpers line 221. Closing it requires `[AllowEmptyString()]` on a line the plan does not permit editing.

Neither cause can be fixed within the approved plan's edit boundary, so the loop cannot close in this execution.

## Suite-level attributes from this run

| Suite | tests | failures | errors | skipped | disabled |
| --- | --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 83 | 3 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 83 | 3 | 0 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | 2 | 0 | 0 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | 0 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 | 0 | 0 | 0 |
