# Baseline PoshQC Test with Coverage ([P0-T18])

Timestamp: 2026-10-07T21-58
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/workflows"
Route: ci-evidence
Deviation: DEV-CI-BASELINE, DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from CI run 37645267440, job 112874273719 "poshqc / PowerShell QC"
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37645267440/job/112874273719 (workflow CI, event push, head 08ee030d9584bf15882fbb3654c8e38f34c7c359, conclusion success)
EXIT_CODE: 0
Output Summary:
- Scope: full repository (config/poshqc-scan.json test scan folders `scripts`, `tests/powershell`, `tests/scripts`), not tests/scripts/workflows alone. Arithmetic in [P1-T5], [P1-T9], [P2-T3] is applied to these full-repository counts.
- (a) Counts line (log line 1274, ANSI codes stripped): `Tests Passed: 6519, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- (b) BaselinePassed: 6519
- (b) BaselineFailed: 0
- (c) Coverage headline (log line 1276, ANSI codes stripped): `Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.`
- (d) BaselineCoverage: 84.32
- tests/scripts/workflows suites in that run (log lines 1270-1272): `[+]` for PoshQcWorkflow.Tests.ps1, PublishMcpNpmWorkflow.Tests.ps1, VerifyPublishedReleasesWorkflow.Tests.ps1.
- Item branch differs from 08ee030d only in documentation files under docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/.
