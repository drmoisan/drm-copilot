# PowerShell Analyzer Baseline (Issue #847)

Timestamp: 2026-10-09T23-46
Task: [P0-T4]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P0-T4 / P7-T2 analyze"), the plan's per-file `Invoke-ScriptAnalyzer` loop is replaced by the CI `Analyze PowerShell` step of the baseline FULL_RUN job, which throws on any finding and otherwise logs `PSScriptAnalyzer passed: no findings under <root>`. The BASE5 file set and settings file (`scripts/powershell/PoshQC/settings/pssa.settings.psd1`) are unchanged. PSScriptAnalyzer availability: job log line 201 `PSScriptAnalyzer 1.25.0 already present.`
Command: CI run 38005028184, job `poshqc / PowerShell QC` (id 114071725598), step `Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCAnalyze -Root "<root>"` on `main` at 460cd755de560b733be0c471d1d144e553fbe0e5 (BASE_SHA). Log read from `artifacts/ci/run-38005028184/poshqc-job.log`.
EXIT_CODE: 0
Output Summary:
scripts/dev-tools/bootstrap-host.ps1 errors=0 warnings=0 information=0
scripts/dev-tools/verify-host.ps1 errors=0 warnings=0 information=0
scripts/dev-tools/publish-sideloaded-extension.ps1 errors=0 warnings=0 information=0
scripts/dev-tools/bootstrap-host.helpers.ps1 errors=0 warnings=0 information=0
tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 errors=0 warnings=0 information=0

## Source observation

- Job log line 832: `PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot`
- The per-file counts above are derived from that whole-root line: the analyzer reported no findings for any file under the root, which includes all five BASE5 files. The CI line does not distinguish severities; `information=0` relies on the "no findings" wording and is recorded as derived rather than separately observed.
