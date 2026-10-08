# Pass-After Through PoshQC Against Fixed ci.yml ([P1-T9])

Timestamp: 2026-10-08T02-30 (UTC)
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/workflows"
Route: ci-evidence
Deviation: DEV-CI-BASELINE (full-repository scope arithmetic), DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from workflow_dispatch CI run 37717224700, job 113116383126 "poshqc / PowerShell QC" (the CI test step is Invoke-PoshQCTest over config/poshqc-scan.json scan folders, which include tests/scripts)
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37717224700/job/113116383126 (workflow CI, event workflow_dispatch, head 8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7, conclusion success)
EXIT_CODE: 0
Output Summary:
- Counts line (log line 1268, ANSI codes stripped): `Tests Passed: 6521, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- Arithmetic: BaselinePassed 6519 + 2 = 6521 (matches); BaselineFailed 0 = Failed 0 (matches).
- tests/scripts/workflows per-file lines (log lines 1263-1267, root redacted): `[+]` for CiWorkflow.Tests.ps1, PoshQcWorkflow.Tests.ps1, PublishMcpNpmWorkflow.Tests.ps1, VerifyPublishedReleasesWorkflow.Tests.ps1.
- `[-]` lines naming a test in tests/scripts/workflows/CiWorkflow.Tests.ps1: none (`[-]` lines in the whole log: 0).
- Coverage headline (log line 1270): `Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.`
- BaselineArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md
