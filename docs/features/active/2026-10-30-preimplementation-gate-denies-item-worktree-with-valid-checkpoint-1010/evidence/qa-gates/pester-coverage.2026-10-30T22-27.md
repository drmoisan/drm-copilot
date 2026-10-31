# QA Pester With Coverage (Issue #1010, remediation cycle 1, P3-T4)

Timestamp: 2026-10-30T22-27
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-suites.txt (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCTest in one process over all 18 touched suites, Run.Exit off, coverage population the Claude and Codex gate and `-epic-scope` files; counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: Loop pass 3. 18 suites; JUnit total 1353, passed 1353, failed 0, errors 0, skipped 0. Line coverage: Claude `-epic-scope` 89.57% (103 covered, 12 missed); Codex `-epic-scope` 97.01% (130 covered, 4 missed). Both are at or above 85%. Suite 11 passed with 0 failures, including `keeps <File> at or under 500 lines in the repository and the bundle` and `keeps <File> byte-identical to its bundle copy`.

## Loop History

- Pass 2 (after the P3-T3 analyzer fix): 1351 passed, 0 failed; Claude `-epic-scope` 88.70%, Codex `-epic-scope` 96.27%. One changed line, the bare-redirection target skip in the walk, was not executed by any row, and the Codex file's percentage was 0.13 points below its baseline. A row `B15 skips a redirection and its target and collects the absolute pathspec after them` was added to suites 1 and 2 (`git commit -m msg 2> <other root>/err.txt <item root>/scripts/Sample.ps1`, asserting that only the item path is returned), and the loop restarted from P3-T2.
- Pass 3: the results in the summary above.

## Per-Suite Counts (JUnit, pass 3)

| Suite | Tests | Failures |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` | 43 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` | 47 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` | 5 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | 11 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` | 93 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 36 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` | 22 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` | 22 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 120 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1` | 3 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | 54 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` | 23 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 60 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` | 61 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1` | 3 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 36 | 0 |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 671 | 0 |

## Per-File Line Coverage (powershell-coverage.xml, pass 3)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 103 | 12 | 89.57% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 130 | 4 | 97.01% |
