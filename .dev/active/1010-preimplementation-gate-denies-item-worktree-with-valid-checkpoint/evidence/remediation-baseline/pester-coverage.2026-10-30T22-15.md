# Baseline Pester With Coverage (Issue #1010, remediation cycle 1, P0-T5)

Timestamp: 2026-10-30T22-15
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-suites.txt (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCTest in one process over the existing touched suites, Run.Exit off, coverage population the Claude and Codex gate and `-epic-scope` files; counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: 17 existing touched suites (suite 3 does not exist yet and is omitted). JUnit total 1314, passed 1314, failed 0, errors 0, skipped 0. Line coverage of the edited repository production files: Claude `-epic-scope` 86.96% (80 covered, 12 missed); Codex `-epic-scope` 96.40% (107 covered, 4 missed).

## Per-Suite Counts (JUnit)

| Suite | Tests | Failures |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` | 26 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` | 30 | 0 |
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

## Per-File Line Coverage (powershell-coverage.xml)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 80 | 12 | 86.96% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 107 | 4 | 96.40% |

The two gate files were also in the measured population (Claude gate 80.50%, Codex gate 88.17%); they are not edited by this cycle and are recorded for information only.
