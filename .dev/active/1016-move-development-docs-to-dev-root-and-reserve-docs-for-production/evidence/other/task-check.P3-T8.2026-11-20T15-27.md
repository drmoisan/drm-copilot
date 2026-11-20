# Task Check [P3-T8]

Timestamp: 2026-11-20T15-27
Command: sh SCRATCH/issue-1016-tc-p3t8.sh (launcher pytest -n auto, launcher pester -TestPath, launcher jest-extension --testPathPatterns=orchestrator-state-issue-adoption)
EXIT_CODE: 0
Output Summary: pytest 132 passed, 0 failed; Pester 138 tests, 0 failures, 0 errors; Jest 4 suites, 149 tests passed.

## Changed files

- `tests/fixtures/orchestrator_state_issue_adoption/waives-feature-folder-path-outside-dev-active.json` (new static JSON fixture; no format, lint or type stage applies to fixture JSON).

## Selection and rule

Contract tests that read the changed fixture folder (the three parity suites `OrchestratorStateIssueAdoption.Parity.Tests.ps1`, `test_orchestrator_state_issue_adoption_parity.py`, `orchestrator-state-issue-adoption-parity.test.ts`), plus the task's named suites: the three feature-folder unit suites (`OrchestratorStateFeatureFolderRecord.Tests.ps1`, `test_orchestrator_state_issue_adoption_feature_folder.py`, `orchestrator-state-issue-adoption-feature-folder.test.ts`), `test_orchestrator_state_issue_adoption.py`, `Get-StageTimingReport.Tests.ps1` and `StageTiming.Tests.ps1`.
