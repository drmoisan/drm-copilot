# r2 P8-T2 PowerShell analyze (final QC, loop pass 1)

Timestamp: 2026-10-03T16-26
Command: (1) step script SCRATCH/steps/r2-p8-t2.ps1: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r2-analyze-final.log" (gating run), PASS-LINE count, TREE-DIGEST, VERDICT; (2) mcp__drm-copilot__run_poshqc_analyze with workspace_root WORKTREE (route step); (3) step script SCRATCH/steps/r2-p8-t2-after.ps1: TREE-DIGEST and VERDICT against the step (1) digest
EXIT_CODE: 0
Output Summary:
- Step (1): ANALYZE-EXIT=0; PASS-LINE=1 (log line "PSScriptAnalyzer passed: no findings under WORKTREE"; zero findings); process exit 0
- TREE-DIGEST before MCP: 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E
- MCP_ROUTE: CALLED - returned (ok true; summary "Ran bundled PoshQC analyze against WORKTREE")
- TREE-DIGEST after MCP (16-28): 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E (equal)
- Step (3) process exit 0. Top-level EXIT_CODE is the larger of steps (1) and (3).
