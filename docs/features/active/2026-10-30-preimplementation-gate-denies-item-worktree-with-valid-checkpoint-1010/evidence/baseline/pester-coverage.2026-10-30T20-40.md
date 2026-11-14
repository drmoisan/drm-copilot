# Baseline Pester With Coverage (Issue #1010, P0-T7)

Timestamp: 2026-10-30T20-40
Command: sh SCRATCH/issue-1010-run.sh issue-1010-pester.ps1 -ListFile SCRATCH/issue-1010-suites.txt (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCTest in one process over the existing touched suites, with Run.Exit off and the coverage population set to the four edited repository production files; counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: 16 existing touched suites (suites 1 and 12 do not exist yet and are omitted). JUnit total 1550, passed 1550, failed 0, errors 0, skipped 0. Line coverage: Claude gate 93.08%, Claude -epic-scope 98.53%, Codex gate 88.30%, Codex -epic-scope 98.18%.

## Per-Suite Counts (JUnit)

| Suite | Tests | Failures |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | 11 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` | 85 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` | 16 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` | 22 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` | 22 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` | 3 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 36 | 0 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` | 10 | 0 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` | 413 | 0 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` | 22 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | 54 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` | 23 | 0 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 36 | 0 |
| `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` | 83 | 0 |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 671 | 0 |

## Per-File Line Coverage (powershell-coverage.xml)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 148 | 11 | 93.08% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 67 | 1 | 98.53% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 151 | 20 | 88.30% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 54 | 1 | 98.18% |
