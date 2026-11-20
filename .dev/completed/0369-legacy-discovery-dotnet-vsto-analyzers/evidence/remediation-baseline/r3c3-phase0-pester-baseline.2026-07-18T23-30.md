# r3c3 Phase 0 — PowerShell/Pester Coverage Baseline

Timestamp: 2026-07-18T23-30

Command:
1. `mcp__drm-copilot__run_poshqc_test` scoped to the two discovery-artifact-gate suites (`tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1`, `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1`) — mandated MCP wrapper.
2. Authoritative regeneration against the live repo runsettings (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`): `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1') -DisableKoverageCopy`

EXIT_CODE: 0

Output Summary:
- Pester result (both invocations): Tests Passed 28, Failed 0, Skipped 0 for the two discovery-artifact-gate suites. Green.
- Numeric line coverage for the two discovery-artifact-gate hooks (from the authoritative `artifacts/pester/powershell-coverage.xml`):
  - `.claude/hooks/enforce-discovery-artifact-gate.ps1`: LINE 48/55 = 87.27% (INSTRUCTION 74/87 = 85.06%).
  - `.claude/hooks/validate-discovery-artifact-gate.ps1`: LINE 51/58 = 87.93% (INSTRUCTION 73/84 = 86.90%).
  - Aggregate (two hooks): LINE 99/113 = 87.61% (INSTRUCTION 147/171 = 85.96%).
- Both discovery-artifact-gate hooks are present in the coverage set of the authoritative artifact.
- Branch coverage: not emitted. Pester `CoverageGutters` output is command/line-based and emits no report-level BRANCH counters (per-line `mb`/`cb` attributes are all zero). Per the established repo convention (see issue #344 `remediation-ps-test-coverage`), this is the authorized line-based-instrument limitation note (not a skip); the recorded line figure is the threshold value.
- MCP-wrapper vs authoritative artifact: the `mcp__drm-copilot__run_poshqc_test` wrapper runs from the installed server's frozen bundled resources, whose runsettings predate the issue #366 `CodeCoverage.Path` additions for the two discovery hooks; its coverage XML omits the two discovery hooks. This is a frozen-bundle tooling-state limitation, not a breakpoint-binding failure. The workspace `Invoke-PoshQCTest` performs the identical underlying operation against the live workspace runsettings, producing the authoritative XML that includes both discovery hooks. The installed bundle converges at the next packaged extension release.
- Baseline state: coverage evidence for the two hooks is at parity with the final state because this cycle authors no PowerShell logic change.
