# PowerShell Test Gate (P9-T8)

Timestamp: 2026-11-17T11-20
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (sh SCRATCH/issue-1035-p9t8-run.sh; the launcher pester suite runs one Invoke-PoshQCParallelTest from scripts/powershell/PoshQC/PoshQC.psd1 over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded; the same form as the Phase 0 baseline). Figures read from the merged artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml (copied to SCRATCH/final-pester/) by sh SCRATCH/issue-1035-p9t8-figures.sh, compared with the Phase 0 coverage XML.
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest ExitCode 0 (workers 8, wall-clock 664.75 s). Merged JUnit: 27678 tests, 0 failures, 0 errors, 22 disabled. FileSizePolicy.RepoGate.Tests.ps1 ran in this gate and passed. Repo-wide line coverage from the merged coverage XML: 96.09% (45052/46884); baseline 96.04% (44785/46631).

## Coverage comparison and fixes

The first P9-T8 run (27667 tests, 0 failures, ExitCode 0) left eleven changed PowerShell files below their Phase 0 line coverage. Each missed line was read from the coverage XML:
- Eight Codex importers (`enforce-completion-consistency.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-planning-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `record-subagent-routing-attestation.ps1`, `validate-feature-review-coverage.ps1` under `.codex/hooks/`, and `.codex/scripts/epic-child-launch-contract.ps1`): the one new missed line in each was the D-P16 probe branch that imports `../lib/development-docs/DevelopmentDocsRoot.psm1`, which the repository layout never takes. New tests drive that branch with a filtered `Test-Path` mock and a recording `Import-Module` mock and assert that the sibling path is imported, the repository fallback is not, and no dependency failure is recorded: `X4: <Hook> imports the development-docs module from the bundle-layout sibling lib when it is present` (five registered hooks; the gate row also loads the epic-scope file) in tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, and `imports the development-docs module from the bundle-layout sibling lib in <RuntimeFile> when it is present (issue #1035)` (the attestation hook and the launch contract) in tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1.
- The two byte-identical `enforce-orchestration-preimplementation-gate-helpers.ps1` copies: the same three pre-existing `return $false` lines were missed before and after the change, and the drop came from the denominator. tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 gained `denies an empty command text` and `denies a segment that holds only the command name` for both surfaces.

The changed suites, with the EpicStateIsolation discovery guard, passed before the restart (sh SCRATCH/issue-1035-p9t8-fix-run.sh: 615, 124, 14 and 80 passed, 0 failed); the first form of the runtime-contracts case failed once because Pester requires a default Test-Path mock, and a pass-through default was added. The PowerShell loop then restarted from formatting (powershell-static.2026-11-17T11-20.md) and this gate ran once.

| File | Line % | Baseline line % | Status |
| --- | --- | --- | --- |
| .claude/hooks/enforce-completion-consistency.ps1 | 95.62 | 95.60 | ok |
| .claude/hooks/enforce-completion-helpers.ps1 | 92.54 | 92.54 | ok |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 98.64 | 98.63 | ok |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 99.39 | 99.39 | ok |
| .claude/hooks/enforce-feature-folder-order.ps1 | 92.54 | 92.42 | ok |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.61 | 96.57 | ok |
| .claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1 | 100.00 | 100.00 | ok |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.81 | 97.79 | ok |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 99.39 | 98.21 | ok |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.56 | 98.55 | ok |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 100.00 | 100.00 | ok |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 99.23 | 99.19 | ok |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 98.63 | 96.67 | ok |
| .claude/hooks/feature-folder-resolution.ps1 | 99.16 | 99.15 | ok |
| .claude/hooks/hook-docs-only-diff.ps1 | 98.47 | 98.46 | ok |
| .claude/hooks/hook-epic-fan-in.ps1 | 100.00 | 100.00 | ok |
| .claude/hooks/validate-executor-output.ps1 | 100.00 | 100.00 | ok |
| .claude/hooks/validate-feature-review-coverage.ps1 | 100.00 | 100.00 | ok |
| .claude/hooks/validate-feature-review-coverage-rules.ps1 | 99.00 | 98.99 | ok |
| .claude/hooks/validate-required-artifact-output.ps1 | 98.75 | 98.73 | ok |
| .claude/hooks/validate-task-researcher-output.ps1 | 98.43 | 98.33 | ok |
| .claude/lib/blast-radius/BlastRadius.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 98.20 | 98.15 | ok |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 97.09 | absent (new; threshold 85) | new |
| .claude/lib/epic-wave/EpicCrossDependency.psm1 | 98.09 | 98.03 | ok |
| .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 96.51 | 96.39 | ok |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 100.00 | 100.00 | ok |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 98.00 | 97.96 | ok |
| .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 100.00 | 100.00 | ok |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 55.66 | 54.00 | ok |
| .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | 100.00 | ok |
| .codex/hooks/enforce-completion-helpers.ps1 | 83.58 | 83.58 | ok |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 99.45 | 99.44 | ok |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 92.64 | 92.64 | ok |
| .codex/hooks/enforce-epic-planning-only.ps1 | 95.93 | 95.86 | ok |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | 100.00 | ok |
| .codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1 | 100.00 | 100.00 | ok |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.12 | 98.09 | ok |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 99.39 | 98.21 | ok |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.54 | 98.53 | ok |
| .codex/hooks/feature-folder-resolution.ps1 | 99.16 | 99.15 | ok |
| .codex/hooks/feature-review-coverage-target.ps1 | 98.81 | 98.73 | ok |
| .codex/hooks/hook-docs-only-diff.ps1 | 97.71 | 97.69 | ok |
| .codex/hooks/hook-epic-fan-in.ps1 | 100.00 | 100.00 | ok |
| .codex/hooks/record-subagent-routing-attestation.ps1 | 93.06 | 92.82 | ok |
| .codex/hooks/validate-feature-review-coverage.ps1 | 100.00 | 100.00 | ok |
| .codex/scripts/epic-child-launch-contract.ps1 | 82.20 | 81.90 | ok |
| .codex/scripts/epic-child-launch-runtime.ps1 | 20.69 | 13.10 | ok |
| scripts/dev-tools/Get-StageTimingReport.ps1 | 100.00 | 100.00 | ok |
| scripts/dev-tools/link-feature-docs.ps1 | 82.61 | 82.22 | ok |
| scripts/dev-tools/new-potential-entry.ps1 | 82.42 | 80.46 | ok |

Pre-existing below-threshold files, each at or above its baseline: .codex/scripts/epic-child-launch-runtime.ps1 (20.69%), .codex/hooks/authorize-root-epic-invocation.ps1 (55.66%), .codex/scripts/epic-child-launch-contract.ps1 (82.20%), scripts/dev-tools/new-potential-entry.ps1 (82.42%), scripts/dev-tools/link-feature-docs.ps1 (82.61%), .codex/hooks/enforce-completion-helpers.ps1 (83.58%).
