# Experiment E4 / Fail-Before Regression Pair (Issue #392)

Timestamp: 2026-07-21T18-01

Command:
1. Direct (baseline): `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC -Output Detailed"`
2. Full bundled entry script: `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1`
3. True bundled-manifest reproduction (recorded here because item 2 does not collide in this repo): `mcp__drm-copilot__run_poshqc_test` (P0-T5) and E1b `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"` (P0-T8).

EXIT_CODE:
1. Direct: 0
2. `run-poshqc-suite.ps1`: 0
3. MCP `run_poshqc_test`: 31; E1b: 31

Output Summary:
- Direct run: Passed=95, Failed=0, Skipped=7 (PoshQC folder). Baseline green, as expected.
- `run-poshqc-suite.ps1` (full tree): tests=1338, failures=0, disabled(skipped)=9 (from `artifacts/pester/pester-junit.xml`). This entry script imports `scripts/powershell/PoshQC/PoshQC.psd1` (repo-root, resolved from `$PSScriptRoot/..\powershell\PoshQC`), which is the SAME path the test-file `BeforeAll` guards import. No path collision occurs, so the guard never removes the hosting module and the run passes. This script therefore does NOT reproduce the defect in this repo.
- True bundled reproduction (fail-before): the MCP `run_poshqc_test` tool (which loads the extensions-bundled PoshQC copy, a different path) exits 31 with 31 failures (P0-T5); the E1b bundled-manifest narrowed run exits 31 with 31 failures (P0-T8). Representative failure line: `RuntimeException: Mock data are not setup for this scope, what happened?`.
- Fail-before condition is established: the bundled-module import path (MCP `run_poshqc_suite`/`run_poshqc_test`, and any entry that imports the extensions-bundled manifest) reproduces the 31 mock-scope failures; the direct run and the repo-root `run-poshqc-suite.ps1` run are green.
