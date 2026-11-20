# P0-T7 Pester Gate — Phase 0 baseline

Timestamp: 2026-11-16T01-04
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher pester suite: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root . over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 679.05s). From the merged artifacts/pester/pester-junit.xml: 27341 tests, 27323 passed, 0 failed, 0 errors, 18 skipped. Repo-wide line coverage from the merged artifacts/pester/powershell-coverage.xml: 96.04% (44785/46631). Per-file figures below; DevelopmentDocsRoot.psm1 is new and absent before the change. Pre-existing below-threshold files: .codex/scripts/epic-child-launch-runtime.ps1 (13.10%), .codex/hooks/authorize-root-epic-invocation.ps1 (54.00%), scripts/dev-tools/new-potential-entry.ps1 (80.46%), .codex/scripts/epic-child-launch-contract.ps1 (81.90%), scripts/dev-tools/link-feature-docs.ps1 (82.22%), .codex/hooks/enforce-completion-helpers.ps1 (83.58%). The final gate is compared with these figures.

Queue timeouts (not failures): three earlier launcher runs exited 75 with TEST_EXECUTION_QUEUE_TIMEOUT because another worktree's Pester suite held the machine test-suite lock; the gate was re-run after the holder finished, and the run above is the recorded baseline.

Tree state: the run started after four new, untracked TypeScript files of P1-T2 to P1-T4 (src/lib/development-docs/root.ts, feature-folder-name.ts and two tests) were written; no tracked file had changed, and no PowerShell, Python, configuration, or hook file had been added or edited.

| File | Line % |
| --- | --- |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | absent |
| .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 100.00 |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 97.96 |
| .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 | 100.00 |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 100.00 |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 100.00 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.57 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 98.21 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.55 |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 98.21 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 98.53 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.09 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.79 |
| .claude/hooks/validate-task-researcher-output.ps1 | 98.33 |
| .claude/hooks/enforce-completion-helpers.ps1 | 92.54 |
| .codex/hooks/enforce-completion-helpers.ps1 | 83.58 |
| .claude/hooks/enforce-completion-consistency.ps1 | 95.60 |
| .codex/hooks/enforce-completion-consistency.ps1 | 100.00 |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 100.00 |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 99.19 |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 96.67 |
| .claude/hooks/enforce-feature-folder-order.ps1 | 92.42 |
| .claude/hooks/validate-executor-output.ps1 | 100.00 |
| .claude/hooks/validate-feature-review-coverage-rules.ps1 | 98.99 |
| .claude/hooks/validate-feature-review-coverage.ps1 | 100.00 |
| .claude/hooks/feature-folder-resolution.ps1 | 99.15 |
| .codex/hooks/feature-folder-resolution.ps1 | 99.15 |
| .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 54.00 |
| .codex/hooks/record-subagent-routing-attestation.ps1 | 92.82 |
| .codex/hooks/feature-review-coverage-target.ps1 | 98.73 |
| .codex/scripts/epic-child-launch-runtime.ps1 | 13.10 |
| .codex/scripts/epic-child-launch-contract.ps1 | 81.90 |
| .claude/hooks/hook-docs-only-diff.ps1 | 98.46 |
| .codex/hooks/hook-docs-only-diff.ps1 | 97.69 |
| .claude/hooks/validate-required-artifact-output.ps1 | 98.73 |
| scripts/dev-tools/new-potential-entry.ps1 | 80.46 |
| scripts/dev-tools/link-feature-docs.ps1 | 82.22 |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 99.39 |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 92.64 |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 98.63 |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 99.44 |
| .claude/hooks/hook-epic-fan-in.ps1 | 100.00 |
| .codex/hooks/hook-epic-fan-in.ps1 | 100.00 |
| .claude/lib/epic-wave/EpicCrossDependency.psm1 | 98.03 |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 96.39 |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 100.00 |
| scripts/dev-tools/Get-StageTimingReport.ps1 | 100.00 |
| .claude/lib/blast-radius/BlastRadius.psm1 | 100.00 |
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 100.00 |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 98.15 |
