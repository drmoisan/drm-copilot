# Final Pester gate, run 2 ([P7-T4])

Timestamp: 2026-11-14T06-11
Command: sh SCRATCH/issue-1159-pester.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <repository root>); counts and coverage read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1159-pester-report.ps1 against the [P0-T5] coverage copy
EXIT_CODE: 0
Output Summary: workers=8, wall-clock 886.88s, exit code 0. JUnit 23970 tests, 0 failures, 0 errors, 16 skipped, 757 suites (baseline 21311 tests, 0 failures, 10 skipped). Repo-wide line coverage 95.89% (40143/41865, 418 files) against baseline 95.80% (37558/39203, 393 files). Acceptance NOT met: .claude/hooks/invoke-pretooluse-dispatch.ps1 84.21% and .codex/hooks/invoke-pretooluse-dispatch.ps1 80.56% (new files below 85%), and seven D13-tail hooks below their baseline (enforce-epic-wave-barrier 98.02 -> 95.19, enforce-parallel-cohort-barrier 97.56 -> 94.12, enforce-parallel-drift-gate 97.52 -> 95.16, Codex discovery-artifact, discovery-planning, evidence-locations and file-size 100 -> 98.28/98.04/98.00/98.97). Fix and loop restart recorded below.

## Skipped 'has parity envelopes for <hook leaf>' rows (JUnit)
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-model-routing-receipt.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-docs-role-write-scope.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-owner-directive-pass-down.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-epic-root-invocation.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-codex-model-routing.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-epic-planning-only.ps1

## Per-file line coverage (changed production PowerShell files; baseline = [P0-T5])
| File | Baseline % | Now % | Covered/total | Flag |
|---|---|---|---|---|
| `.claude/hooks/check-powershell-test-purity.ps1` | 93.44 | 93.44 | 57/61 | ok |
| `.claude/hooks/check-python-test-purity.ps1` | 93.94 | 93.94 | 62/66 | ok |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 96.00 | 96.00 | 96/100 | ok |
| `.claude/hooks/enforce-completion-consistency.ps1` | 95.33 | 95.60 | 152/159 | ok |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 100.00 | 100.00 | 33/33 | ok |
| `.claude/hooks/enforce-discovery-planning-gate.ps1` | 100.00 | 100.00 | 27/27 | ok |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 93.90 | 94.57 | 87/92 | ok |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | 100.00 | 100.00 | 68/68 | ok |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | 90.79 | 90.79 | 69/76 | ok |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 93.62 | 93.62 | 44/47 | ok |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 98.63 | 98.63 | 144/146 | ok |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 98.02 | 95.19 | 99/104 | DROP |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 96.23 | 96.55 | 56/58 | ok |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94.92 | 95.24 | 120/126 | ok |
| `.claude/hooks/enforce-evidence-locations.ps1` | 89.13 | 89.13 | 41/46 | ok |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 92.42 | 92.42 | 61/66 | ok |
| `.claude/hooks/enforce-file-size-limit.ps1` | 100.00 | 100.00 | 79/79 | ok |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 94.12 | 94.12 | 80/85 | ok |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 95.70 | 95.70 | 89/93 | ok |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 97.66 | 97.66 | 125/128 | ok |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.32 | 96.43 | 162/168 | ok |
| `.claude/hooks/enforce-owner-directive-pass-down.ps1` | new | 91.41 | 149/163 | ok |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 94.12 | 94.12 | 80/85 | ok |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 97.56 | 94.12 | 80/85 | DROP |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 97.52 | 95.16 | 118/124 | DROP |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 95.58 | 95.93 | 118/123 | ok |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 94.08 | 94.08 | 143/152 | ok |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 98.44 | 98.44 | 63/64 | ok |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 91.23 | 91.23 | 52/57 | ok |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 96.97 | 96.97 | 96/99 | ok |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.42 | 92.42 | 61/66 | ok |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 94.08 | 94.08 | 143/152 | ok |
| `.claude/hooks/enforce-worktree-poetry-venv.ps1` | 100.00 | 100.00 | 35/35 | ok |
| `.claude/hooks/invoke-pretooluse-dispatch.ps1` | new | 84.21 | 32/38 | BELOW-85 |
| `.claude/hooks/subagentstop-target-worktree.ps1` | 100.00 | 100.00 | 99/99 | ok |
| `.claude/hooks/validate-bash.ps1` | 94.23 | 94.23 | 98/104 | ok |
| `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | 99.46 | 99.48 | 193/194 | ok |
| `.claude/lib/hook-dispatch/HookDispatch.psm1` | new | 100.00 | 107/107 | ok |
| `.claude/lib/hook-dispatch/HookDispatchRunner.psm1` | new | 98.82 | 84/85 | ok |
| `.codex/hooks/enforce-discovery-artifact-gate.ps1` | 100.00 | 98.28 | 57/58 | DROP |
| `.codex/hooks/enforce-discovery-planning-gate.ps1` | 100.00 | 98.04 | 50/51 | DROP |
| `.codex/hooks/enforce-evidence-locations.ps1` | 100.00 | 98.00 | 49/50 | DROP |
| `.codex/hooks/enforce-file-size-limit.ps1` | 100.00 | 98.97 | 96/97 | DROP |
| `.codex/hooks/hook-dispatch.ps1` | new | 99.35 | 154/155 | ok |
| `.codex/hooks/invoke-pretooluse-dispatch.ps1` | new | 80.56 | 29/36 | BELOW-85 |
| `scripts/dev-tools/HookProcessCost.psm1` | new | 99.44 | 176/177 | ok |
| `scripts/dev-tools/Measure-HookProcessCost.ps1` | new | 86.36 | 38/44 | ok |

## Cause and fix
The uncovered lines are script tails that no suite ran in-process: the D13 tail added by [P1-T2] (`$entryPointResult = @(...)`, the `Count -gt 1` branch, `exit`) and the dispatcher tails and default seams. For the four Codex hooks the branch is unreachable (they write decisions through [Console]::Out, so the entry point returns only the exit code). Fix: the tail of the seven D13 hooks and both dispatcher entry scripts emits `$entryPointResult | Select-Object -SkipLast 1 | Write-Output` without a branch (same output and exit code); in-process whole-script rows were added to the wave-barrier, cohort-barrier and drift-gate suites and to both dispatcher suites (plus a default trace-writer row each); bundle copies refreshed. The affected suites passed 2042 of 2042 (task check, not evidence). The loop restarts from [P7-T2].
