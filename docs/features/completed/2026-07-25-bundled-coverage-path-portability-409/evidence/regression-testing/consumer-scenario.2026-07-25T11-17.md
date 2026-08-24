# Consumer-Repository Scenario (spec AC 7, issue #409)

Timestamp: 2026-07-25T11-17

Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot tests -ScanFoldersJson '["scripts/powershell/PoshQC"]'` (run from the repository root)

EXIT_CODE: 0

Scenario shape: the workspace root `tests/` contains Pester suites (the scan folder resolves to `tests/scripts/powershell/PoshQC`, which holds 10 `*.Tests.ps1` files) but none of the configured `CodeCoverage.Path` entries exist beneath it. This reproduces the reported consumer-repository condition without requiring an external checkout. The bundled entry script imports the in-repo bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1`, so this run exercises the fixed code (blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`).

Output Summary:
- **RunStart passed and test execution completed.** Before the fix this invocation aborted during Pester RunStart on the first unresolvable coverage path. The run now proceeds to completion: `Tests completed in 3.68s` with `Tests Passed: 111, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0`.
- **Every configured coverage path was logged as pruned: 32 prune lines** (one per configured entry). Examples:
  - `Pruned nonexistent code coverage path: tests\tests\.claude\hooks\validate-bash.ps1`
  - `Pruned nonexistent code coverage path: tests\tests\.claude\hooks\check-python-test-purity.ps1`
  - `Pruned nonexistent code coverage path: tests\tests\.claude\hooks\check-powershell-test-purity.ps1`
- **The single coverage-disable message appeared exactly once:**
  `Code coverage disabled for this invocation: no configured coverage path exists under root 'tests'.`
- Process exit reflects the test results (all discovered tests passed), not a RunStart abort: `EXIT_CODE: 0`.
- Individual suite results confirm real execution, including the new file: `[+] tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 163ms`, plus `PoshQC.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.EntryPoints.Tests.ps1`, `PoshQC.ScanConfig.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`.

Observation recorded for completeness (pre-existing, out of scope for #409): the logged prune paths show a doubled prefix (`tests\tests\...`). This is because the default `$ExpandCoveragePaths` seam already roots relative entries against `-Root` (writing them into the Pester `StringArrayOption`), and the coverage-enabled block then re-roots the still-relative result. That double-join predates this change and is unaffected by it; it does not occur in this repository, where `-Root` is an absolute path so the first join yields rooted entries that the second join leaves as-is (confirmed by the 31-file baseline in `evidence/baseline/coverage-file-set.baseline.2026-07-25T10-52.md`). Because all 32 entries are absent under `tests` either way, the pruning and disable behavior under test is exercised exactly as specified. No change was made to address this observation, per the approved scope.

Corroborating check that this repository has nothing prunable (AC-4 premise):
`pwsh -NoLogo -NoProfile -Command "$s = Import-PowerShellDataFile scripts/powershell/PoshQC/settings/pester.runsettings.psd1; ..."` reported `configured entries (raw): 32`, `configured entries (unique): 31`, `missing under repo root: 0`.

Tool-output note (research Reproduction Protocol): this invocation unconditionally creates tool output directories under `tests/artifacts/` before coverage handling (`PoshQC.Testing.psm1` `$EnsureResultPath` `New-Item` at line 197 and `$ExpandCoveragePaths` `New-Item` at line 230, both reached at lines 303-304, ahead of the coverage block at line 338). This is repository-tree tool-output churn, not a test-created temp file under `.claude/rules/general-unit-test.md`, and a fully side-effect-free faithful reproduction is not achievable because directory creation precedes the previously-aborting code path. Cleanup is task [P3-T3].
