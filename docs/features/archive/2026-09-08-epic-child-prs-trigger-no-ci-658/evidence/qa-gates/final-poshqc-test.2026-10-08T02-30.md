# Final PoshQC Test with Coverage ([P2-T3])

Timestamp: 2026-10-08T02-30 (UTC)
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/workflows"
Route: ci-evidence
Deviation: DEV-CI-BASELINE (full-repository scope arithmetic), DEV-PWSH-ROUTE, DEV-CI-FINALQC
ExecutedCommand: none locally; values read from workflow_dispatch CI run 37717224700, job 113116383126 "poshqc / PowerShell QC"
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37717224700/job/113116383126 (workflow CI, event workflow_dispatch, head 8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7, conclusion success)
EXIT_CODE: 0
Output Summary:
- Scope: full repository (config/poshqc-scan.json test scan folders), matching the [P0-T18] baseline scope.
- Counts line (log line 1268, ANSI codes stripped): `Tests Passed: 6521, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- FinalPassed: 6521
- FinalFailed: 0
- Coverage headline (log line 1270, ANSI codes stripped): `Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.`
- FinalCoverage: 84.32
- Acceptance arithmetic: FinalPassed 6521 = BaselinePassed 6519 + 2; FinalFailed 0 = BaselineFailed 0.
- `[-]` lines naming a test in tests/scripts/workflows/CiWorkflow.Tests.ps1: none (`[-]` lines in the whole log: 0). Per-file line (log line 1263): `[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 40ms (5ms|18ms)`.
- BaselineArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md
