# P6-T3 Test with coverage (loop pass 1)

Timestamp: 2026-10-03T10-04
Command: (1) SCRATCH/steps/p6-t3.ps1: TREE-DIGEST (2) mcp__drm-copilot__run_poshqc_test (workspace_root = WORKTREE, scan_folders = tests/scripts/claude-hooks, tests/scripts/codex-hooks) (3) SCRATCH/steps/p6-t3-after.ps1: TREE-DIGEST; pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "SCRATCH/pester-final.log"; $LASTEXITCODE; Copy-Item artifacts/pester/powershell-coverage.xml -> SCRATCH/final-coverage.xml -Force; JUnit totals and FAILED lines from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- TREE-DIGEST before MCP call (TS=2026-10-03T10-04): 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6
- MCP_ROUTE: CALLED; the call returned {"ok":true,"tool":"run_poshqc_test", "summary":"Ran bundled PoshQC test against 'WORKTREE' with 2 selected scan folder(s)."}
- TREE-DIGEST after MCP call (first line after A0 of p6-t3-after.ps1, TS=2026-10-03T10-07): 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6 (equal)
- Direct full Pester run (gating, last, so artifacts/pester holds its output) exit code: 0
- Totals: tests=6626 failures=0 errors=0 disabled=10 (P0-T13 baseline tests=6529; +97 = 54 unit + 43 hook-level Issue824 tests)
- FAILED lines: none
- Result: PASS
