# Pester gate — main-sync cycle 1 ([P1-T9])

Timestamp: 2026-11-14T07-45
Command: sh SCRATCH/issue-1159-pester.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <repository root>; exit with the returned ExitCode), started 2026-11-14T07-30. Counts and coverage are read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1159-pester-report.ps1 against the [P0-T5] coverage copy (SCRATCH/issue-1159-p0t5-coverage.xml)
EXIT_CODE: 0
Output Summary: workers=8, all 8 shards exit 0, wall-clock 856.2s, exit code 0. JUnit: 24357 tests, 0 failures, 0 errors, 16 skipped, 769 suites. Phase 0 baseline [P0-T5]: 21311 tests, 0 failures, 10 skipped, 714 suites. Greatest pre-cycle gate pester.2026-11-14T06-25.md: 23977 tests, 0 failures, 16 skipped, 757 suites. Repo-wide line coverage: 95.99% (40789/42491, 425 files), against 95.80% (37558/39203, 393 files) at the Phase 0 baseline and 95.96% at the pre-cycle gate. All 48 listed files are at or above 85% with no drop against the baseline. The 48 files are the 47 production PowerShell files the approved plan created or changed, plus .claude/hooks/enforce-model-routing-receipt-docs.ps1, which this cycle changed. That file is absent from both the [P0-T5] baseline and the pre-cycle gate, so it is judged against the threshold: 95.06% (77/81). No new failing test.

## Skipped 'has parity envelopes for <Leaf>' rows (JUnit)
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-model-routing-receipt.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-docs-role-write-scope.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).claude registry envelopes.has parity envelopes for enforce-owner-directive-pass-down.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-epic-root-invocation.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-codex-model-routing.ps1
- PreToolUse dispatcher per-hook parity (issue #1159).codex registry envelopes.has parity envelopes for enforce-epic-planning-only.ps1

The [P1-T5] hooks appear here only as enforce-model-routing-receipt.ps1, which has a recorded NoEnvelope reason. The skipped set equals the [P1-T1] task-check set.

## Per-file line coverage (baseline = [P0-T5]; "new" = absent from the baseline)
| File | Baseline % | Now % | Covered/Lines | Result |
|---|---|---|---|---|
| `.claude/hooks/check-powershell-test-purity.ps1` | 93.44 | 93.44 | 57/61 | ok |
| `.claude/hooks/check-python-test-purity.ps1` | 93.94 | 93.94 | 62/66 | ok |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 96.00 | 96.00 | 96/100 | ok |
| `.claude/hooks/enforce-completion-consistency.ps1` | 95.33 | 95.60 | 152/159 | ok |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 100.00 | 100.00 | 33/33 | ok |
| `.claude/hooks/enforce-discovery-planning-gate.ps1` | 100.00 | 100.00 | 27/27 | ok |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 93.90 | 95.00 | 114/120 | ok |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | 100.00 | 100.00 | 68/68 | ok |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | 90.79 | 90.79 | 69/76 | ok |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 93.62 | 93.62 | 44/47 | ok |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 98.63 | 98.63 | 144/146 | ok |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 98.02 | 100.00 | 103/103 | ok |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 96.23 | 96.55 | 56/58 | ok |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94.92 | 95.24 | 120/126 | ok |
| `.claude/hooks/enforce-evidence-locations.ps1` | 89.13 | 89.13 | 41/46 | ok |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 92.42 | 92.42 | 61/66 | ok |
| `.claude/hooks/enforce-file-size-limit.ps1` | 100.00 | 100.00 | 79/79 | ok |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 94.12 | 94.12 | 80/85 | ok |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 95.70 | 96.00 | 96/100 | ok |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 97.66 | 97.66 | 125/128 | ok |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.32 | 96.47 | 164/170 | ok |
| `.claude/hooks/enforce-owner-directive-pass-down.ps1` | new | 91.41 | 149/163 | ok |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 94.12 | 94.12 | 80/85 | ok |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 97.56 | 100.00 | 84/84 | ok |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 97.52 | 99.19 | 122/123 | ok |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 95.58 | 95.93 | 118/123 | ok |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 94.08 | 94.08 | 143/152 | ok |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 98.44 | 98.44 | 63/64 | ok |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 91.23 | 91.23 | 52/57 | ok |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 96.97 | 96.97 | 96/99 | ok |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.42 | 92.42 | 61/66 | ok |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 94.08 | 94.08 | 143/152 | ok |
| `.claude/hooks/enforce-worktree-poetry-venv.ps1` | 100.00 | 100.00 | 35/35 | ok |
| `.claude/hooks/invoke-pretooluse-dispatch.ps1` | new | 100.00 | 37/37 | ok |
| `.claude/hooks/subagentstop-target-worktree.ps1` | 100.00 | 100.00 | 99/99 | ok |
| `.claude/hooks/validate-bash.ps1` | 94.23 | 94.23 | 98/104 | ok |
| `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | 99.46 | 99.48 | 193/194 | ok |
| `.claude/lib/hook-dispatch/HookDispatch.psm1` | new | 100.00 | 107/107 | ok |
| `.claude/lib/hook-dispatch/HookDispatchRunner.psm1` | new | 98.82 | 84/85 | ok |
| `.codex/hooks/enforce-discovery-artifact-gate.ps1` | 100.00 | 100.00 | 57/57 | ok |
| `.codex/hooks/enforce-discovery-planning-gate.ps1` | 100.00 | 100.00 | 50/50 | ok |
| `.codex/hooks/enforce-evidence-locations.ps1` | 100.00 | 100.00 | 49/49 | ok |
| `.codex/hooks/enforce-file-size-limit.ps1` | 100.00 | 100.00 | 96/96 | ok |
| `.codex/hooks/hook-dispatch.ps1` | new | 99.35 | 154/155 | ok |
| `.codex/hooks/invoke-pretooluse-dispatch.ps1` | new | 100.00 | 35/35 | ok |
| `scripts/dev-tools/HookProcessCost.psm1` | new | 99.44 | 176/177 | ok |
| `scripts/dev-tools/Measure-HookProcessCost.ps1` | new | 86.36 | 38/44 | ok |
| `.claude/hooks/enforce-model-routing-receipt-docs.ps1` | new | 95.06 | 77/81 | ok |
