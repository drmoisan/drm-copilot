# PowerShell Format Baseline (Issue #847)

Timestamp: 2026-10-09T23-46
Task: [P0-T3]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P0-T3 / P7-T1 format"), the plan's local `Invoke-Formatter` loop is replaced by the CI `Format PowerShell` step of the baseline FULL_RUN job. The thresholds and BASE5 file set are unchanged.
Command: CI run 38005028184, job `poshqc / PowerShell QC` (id 114071725598), step `Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCFormat -Root "<root>"; $diff = git status --porcelain; if ($diff) { Write-Error "PowerShell files were reformatted. ..." }` on `main` at 460cd755de560b733be0c471d1d144e553fbe0e5 (BASE_SHA). Log read from `artifacts/ci/run-38005028184/poshqc-job.log`.
EXIT_CODE: 0
Output Summary:
FORMAT_CLEAN scripts/dev-tools/bootstrap-host.ps1
FORMAT_CLEAN scripts/dev-tools/verify-host.ps1
FORMAT_CLEAN scripts/dev-tools/publish-sideloaded-extension.ps1
FORMAT_CLEAN scripts/dev-tools/bootstrap-host.helpers.ps1
FORMAT_CLEAN tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1

## Source observations

- Job log line 514: `Already formatted: D:\a\drm-copilot\drm-copilot\scripts\dev-tools\bootstrap-host.ps1`
- Job log line 537: `Already formatted: D:\a\drm-copilot\drm-copilot\scripts\dev-tools\verify-host.ps1`
- Job log line 530: `Already formatted: D:\a\drm-copilot\drm-copilot\scripts\dev-tools\publish-sideloaded-extension.ps1`
- Job log line 513: `Already formatted: D:\a\drm-copilot\drm-copilot\scripts\dev-tools\bootstrap-host.helpers.ps1`
- Job log line 805: `Already formatted: D:\a\drm-copilot\drm-copilot\tests\scripts\dev-tools\publish-sideloaded-extension.Tests.ps1`
- Zero log lines match `Formatted: D:` (no file rewritten by the format step); zero `##[error]` lines in the job log. The step completed and the job concluded `success`.
- EXIT_CODE 0 is the step disposition (step succeeded; the step writes an error when any file is reformatted).
