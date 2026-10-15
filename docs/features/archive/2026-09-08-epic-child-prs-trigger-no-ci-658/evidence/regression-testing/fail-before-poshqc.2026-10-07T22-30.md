# Fail-Before, PoshQC Test Against Unmodified ci.yml ([P1-T5] [expect-fail])

Timestamp: 2026-10-07T22-30
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/workflows"
Route: ci-evidence
Deviation: DEV-CI-FAILBEFORE, DEV-CI-BASELINE, DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from workflow_dispatch CI run 37715960709, job 113112343480 "poshqc / PowerShell QC" (Invoke-PoshQCTest, full-repository scan per config/poshqc-scan.json)
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37715960709/job/113112343480 (workflow CI, event workflow_dispatch, head 632fe595199cc75e7e1560f010acc3a0e611aab2, conclusion failure)
EXIT_CODE: 1
ExpectedExitCode: 1
BaselineArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md
Output Summary:
- Precondition: [P0-T18] recorded `BaselineFailed: 0` (and `BaselinePassed: 6519`), so the expected exit code of 1 applies.
- ci.yml unmodified at head 632fe595: `git diff --numstat origin/main...632fe595 -- .github/workflows/ci.yml` printed nothing.
- Counts line (log line 1263, ANSI codes stripped): `Tests Passed: 6520, Failed: 1, Skipped: 10, Inconclusive: 0, NotRun: 0`
- Arithmetic check: 6520 = BaselinePassed 6519 + 1; 1 = BaselineFailed 0 + 1. Matches the acceptance condition.
- Every `[-]` line (one in the whole log; log line 1253, `##[error]` annotation prefix stripped): `[-] ci.yml workflow triggers.lists main, development, and epic/** in the pull_request branch filter 7ms (7ms|0ms)`
- Coverage headline (log line 1265): `Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.`
- Job end (log line 1266): `Process completed with exit code 1.` (the CI step's exit code; equals the failed-test count).
- Format step in the same job (log line 802): `Already formatted: <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1`
