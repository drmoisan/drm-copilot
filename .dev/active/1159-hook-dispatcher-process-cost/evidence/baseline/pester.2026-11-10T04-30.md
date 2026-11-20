# Phase 0 baseline Pester gate ([P0-T5])

Timestamp: 2026-11-10T04-30
Command: sh SCRATCH/issue-1159-pester.sh (pwsh 7: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <repository root>`; the launcher exits with the returned `ExitCode`); counts read from `artifacts/pester/pester-junit.xml` and line coverage from `artifacts/pester/powershell-coverage.xml` by `sh SCRATCH/issue-1159-pester-report.sh`
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 1672.06s, exit code 0. JUnit: 21311 tests, 0 failures, 0 errors, 10 skipped, 714 suites. Repo-wide line coverage 95.80% (37558 covered, 1645 missed, 393 files). Every D6- and D13-set file and DiscoveryCapability.psm1 is at or above 85% (lowest: .claude/hooks/enforce-evidence-locations.ps1 89.13%). No sub-85% file to report.

## Per-file line coverage (DiscoveryCapability.psm1, D6 set, D13 set)

| File | Line coverage | Covered/total |
|---|---|---|
| `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | 99.46% | 183/184 |
| `.claude/hooks/validate-bash.ps1` | 94.23% | 98/104 |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.42% | 61/66 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 91.23% | 52/57 |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 98.44% | 63/64 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.32% | 157/163 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 97.66% | 125/128 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 98.63% | 144/146 |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 93.62% | 44/47 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 93.90% | 77/82 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94.92% | 112/118 |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 96.23% | 51/53 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 95.58% | 108/113 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 94.12% | 80/85 |
| `.claude/hooks/enforce-worktree-poetry-venv.ps1` | 100.00% | 35/35 |
| `.claude/hooks/check-python-test-purity.ps1` | 93.94% | 62/66 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 94.08% | 143/152 |
| `.claude/hooks/check-powershell-test-purity.ps1` | 93.44% | 57/61 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 94.08% | 143/152 |
| `.claude/hooks/enforce-evidence-locations.ps1` | 89.13% | 41/46 |
| `.claude/hooks/enforce-file-size-limit.ps1` | 100.00% | 71/71 |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 92.42% | 61/66 |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 96.00% | 96/100 |
| `.claude/hooks/enforce-completion-consistency.ps1` | 95.33% | 143/150 |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 94.12% | 80/85 |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 100.00% | 33/33 |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 96.97% | 96/99 |
| `.claude/hooks/enforce-discovery-planning-gate.ps1` | 100.00% | 27/27 |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 98.02% | 99/101 |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 95.70% | 89/93 |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | 90.79% | 69/76 |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 97.56% | 80/82 |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 97.52% | 118/121 |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | 100.00% | 68/68 |
| `.codex/hooks/enforce-discovery-artifact-gate.ps1` | 100.00% | 55/55 |
| `.codex/hooks/enforce-discovery-planning-gate.ps1` | 100.00% | 48/48 |
| `.codex/hooks/enforce-evidence-locations.ps1` | 100.00% | 47/47 |
| `.codex/hooks/enforce-file-size-limit.ps1` | 100.00% | 83/83 |

Note: the run's test population was fixed when the shards started; the Phase 0 tooling files authored for [P0-T8] and [P0-T9] during the run (`scripts/dev-tools/HookProcessCost.psm1`, `scripts/dev-tools/Measure-HookProcessCost.ps1` and their tests) are not in this JUnit (no test case named `*HookCost*`), so the baseline reflects the tree as merged at [P0-T1].
