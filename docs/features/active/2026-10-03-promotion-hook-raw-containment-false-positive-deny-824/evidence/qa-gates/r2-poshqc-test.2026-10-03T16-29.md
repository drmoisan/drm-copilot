# r2 P8-T3 PowerShell tests with coverage (final QC, loop pass 1)

Timestamp: 2026-10-03T16-29
Command: (1) step script SCRATCH/steps/r2-p8-t3.ps1: TREE-DIGEST; (2) mcp__drm-copilot__run_poshqc_test with workspace_root WORKTREE and scan folders tests/scripts/claude-hooks and tests/scripts/codex-hooks (route step); (3) step script SCRATCH/steps/r2-p8-t3-after.ps1 (16-32): TREE-DIGEST, then pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r2-pester-final.log" (gating run, last), Copy-Item of artifacts/pester/powershell-coverage.xml to SCRATCH/r2-final-coverage.xml, JUnit totals, VERDICT (P0-T13 tests 6753 + 73)
EXIT_CODE: 0
Output Summary:
- TREE-DIGEST before MCP: 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E
- MCP_ROUTE: CALLED - returned (ok true; summary "Ran bundled PoshQC test against WORKTREE with 2 selected scan folder(s)")
- TREE-DIGEST after MCP: 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E (equal)
- PESTER-EXIT=0; tests=6826 failures=0 errors=0 (P0-T13 value 6753 plus 73: the 52 D9 new rows plus the 15 GT and 6 WT tests); no FAILED line; no PRE-EXISTING-FAILURE
- Top-level EXIT_CODE is the exit code of step script (3).
