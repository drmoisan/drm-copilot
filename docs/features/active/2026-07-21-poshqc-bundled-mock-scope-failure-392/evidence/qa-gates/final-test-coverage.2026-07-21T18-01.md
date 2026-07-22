# Final QA Step 3 — Test with Coverage (Issue #392)

Timestamp: 2026-07-21T18-01

## MCP tool run (plan command; stale-bundle limitation)
Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root = repo root)
EXIT_CODE: 33
Output Summary:
- tests=1341, failures=33 (all `Mock data are not setup for this scope`), disabled=9.
- LIMITATION (not a defect in this change): the MCP server loads its bundled PoshQC module from the installed/main-repo snapshot `C:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\powershell\PoshQC\PoshQC.Testing.psm1` (dated 2026-07-10, verified to contain NO `Invoke-PoshQCPesterRun` trampoline), NOT this worktree's fixed copy (verified to contain the trampoline, 3 references). The MCP bundle is refreshed only when the extension is repackaged from merged main, so it cannot reflect un-merged worktree edits. The 33 = the 31 original mock-scope failures + the 2 new `InModuleScope`-based seam tests failing under the stale module-hosting.

## Authoritative worktree coverage-enabled run (uses the fixed code + updated settings)
Command: `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1` (repo-root module with the fix; worktree `pester.runsettings.psd1` with `PoshQC.Testing.psm1` in `CodeCoverage.Path`; coverage enabled)
EXIT_CODE: 0
Output Summary:
- tests=1341, failures=0, disabled(skipped)=9. Passed=1332. 0 failed.
- Aggregate coverage (JaCoCo, `artifacts/pester/powershell-coverage.xml`): LINE = 88.26% (covered=2097, missed=279); INSTRUCTION = 87.92%; METHOD = 85.64%; CLASS = 93.55%.
- Per-file `PoshQC.Testing.psm1`: LINE = 76.41% (covered=149, missed=46), INSTRUCTION = 77.53% (this file-level figure reflects the many pre-existing seam/coverage code paths in the large module; the changed lines specifically are all covered — see P6-T4).
- Changed executable lines all COVERED: line 165 (`Import-Module $Name -Global`), 271 (`[scriptblock]::Create(...)`), 272 (`New-Item function:global:Invoke-PoshQCPesterRun`), 274 (`Invoke-PoshQCPesterRun $Config`), 279 (`finally Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun'`).

Acceptance: the substantive acceptance (0 failed with numeric coverage using the actual fixed code) is met by the authoritative worktree run. The MCP command was executed and recorded; its exit 33 is a bundled-snapshot staleness that resolves once the extension is repackaged from merged main (flagged for the reviewer).
