# R4 Phase 6 runner re-derivation against the merged tree (P6-T3)

Timestamp: 2026-10-17T03-26
Command: (1) grep -c -F -e "'artifacts/pester/pester-junit.xml'" scripts/powershell/PoshQC/settings/pester.runsettings.psd1; (2) grep -c -F -e "'artifacts/pester/powershell-coverage.xml'" scripts/powershell/PoshQC/settings/pester.runsettings.psd1; (3) grep -n -F -e 'UseBreakpoints' scripts/powershell/PoshQC/settings/pester.runsettings.psd1; (4) grep -c -F -e 'Sort-Object -Unique' scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1; (5) grep -c -F -e 'Sort-Object -Property FullName -Stable' scripts/powershell/PoshQC/PoshQC.Testing.psm1; (6) grep -c -F -e 'pester-junit-shard-' .github/workflows/_poshqc.yml; (7) grep -c -F -e '@danmoisan/drm-copilot-mcp' .mcp.json; (8) grep -c -F -e 'inputs.run-heavy' .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary:
- (1) 1
- (2) 1
- (3) 29:        UseBreakpoints        = $false
- (4) 1
- (5) 1
- (6) 2
- (7) 1
- (8) 10
MERGED-TREE-OUTPUT-PATHS: UNCHANGED
MERGED-TREE-COVERAGE-MODE: PROFILER
MERGED-TREE-SORTING: UNCHANGED
CI-JUNIT-SHARDED: YES
CI-CHANGE-SCOPE-GATED: YES
LOCAL-RUNNER: packaged MCP server started from .mcp.json; the local run_poshqc_test reads the PoshQC settings packaged with that server, not the merged-tree runsettings (planning observation: breakpoint coverage).
