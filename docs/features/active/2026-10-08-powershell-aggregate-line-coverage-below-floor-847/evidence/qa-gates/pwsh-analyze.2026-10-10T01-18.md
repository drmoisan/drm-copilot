# Final QA: PowerShell Analyze (Issue #847)

Timestamp: 2026-10-10T01-18
Task: [P7-T2] (loop iteration 1)
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P0-T4 / P7-T2 analyze"), the per-file local `Invoke-ScriptAnalyzer` runs are replaced by `mcp__drm-copilot__run_poshqc_analyze` (call disposition) plus the CI `Analyze PowerShell` step, which throws on any finding and logs `PSScriptAnalyzer passed: no findings under <root>` otherwise. The acceptance condition (19 lines, each `errors=0 warnings=0`) is unchanged.
Command: (1) `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = the agent worktree and `scan_folders` = `["scripts/dev-tools", "tests/scripts/dev-tools"]`; (2) CI `Analyze PowerShell` step of run 38011932558 (`Invoke-PoshQCAnalyze -Root "${{ github.workspace }}"`; `.github/workflows/_poshqc.yml` lines 32-36), read from `artifacts/ci/run-38011932558/poshqc-job.log`.
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` over both scan folders (EXIT_CODE 0 records the call disposition; the tool returns `ok: false` when the analyzer reports any issue, as observed during Phase 4).
- CI analyzer line (run 38011932558, job `PowerShell QC` 114093650487, head `1c3d1a4c6d0cc741081f45511c3ab6c5adf2d184`): `poshqc-job.log` line 832 `PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot`.
- Per-file lines (19; derived, see Derivation): every CPFS file `errors=0 warnings=0 information=0`.
- PSAvoidGlobalVars fallback: not triggered. PSShouldProcess contingency: not triggered.
- Result: PASS. The loop proceeds to P7-T3.

## Derivation of the per-file lines

The CI step does not print per-file counts. They are derived as follows, and the derivation is mechanical:

1. `Invoke-PoshQCAnalyze` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:83-185`) runs `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` (line 101; settings default `$script:PssaSettings` from `PoshQC.psm1:2`) for every `.ps1`/`.psm1` file returned by `Get-PoshQCFileList`, accumulates all records, and throws `PSScriptAnalyzer reported N issue(s).` when the total is above zero (line 183). It logs `PSScriptAnalyzer passed: no findings under <root>` only when the total is zero (line 185).
2. `Invoke-PoshQCFormat` uses the same `Get-PoshQCFileList` call with the same default exclusions (`PoshQC.Analyzer.psm1:28` and `:98`). The Format step of the same run logged `Already formatted:` for all 19 CPFS files (see `pwsh-format.2026-10-10T01-18.md`), so all 19 files are in the analyzer's population.
3. A zero total over a population that contains a file implies zero Error, ParseError, Warning, and Information records for that file. Each of the 19 CPFS files therefore has `errors=0 warnings=0 information=0` (the plan gates only errors and warnings; information is listed and is also zero).

## Per-file lines

- scripts/dev-tools/HostTooling.psm1 errors=0 warnings=0 information=0
- scripts/dev-tools/HostBootstrapWorkspace.psm1 errors=0 warnings=0 information=0
- scripts/dev-tools/HostBootstrap.psm1 errors=0 warnings=0 information=0
- scripts/dev-tools/HostVerification.psm1 errors=0 warnings=0 information=0
- scripts/dev-tools/SideloadedExtensionPublish.psm1 errors=0 warnings=0 information=0
- scripts/dev-tools/bootstrap-host.ps1 errors=0 warnings=0 information=0
- scripts/dev-tools/verify-host.ps1 errors=0 warnings=0 information=0
- scripts/dev-tools/publish-sideloaded-extension.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostTooling.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostBootstrap.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostVerification.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/bootstrap-host.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/verify-host.Tests.ps1 errors=0 warnings=0 information=0
- tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 errors=0 warnings=0 information=0

The CI run analyzed the same blobs as the worktree: every CPFS `git hash-object` value equals its `git ls-tree HEAD` blob at `1c3d1a4c6` (recorded in `pwsh-format.2026-10-10T01-18.md`).
