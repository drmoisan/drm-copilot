# r2 P8-T1 PowerShell format (final QC, loop pass 1)

Timestamp: 2026-10-03T16-25
Command: (1) step script SCRATCH/steps/r2-p8-t1.ps1: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path' *> "$Scratch/r2-format-final.log" (write mode, gating run), FORMATTED and ALREADY-FORMATTED counts, TREE-DIGEST, VERDICT; (2) mcp__drm-copilot__run_poshqc_format with workspace_root WORKTREE (route step); (3) step script SCRATCH/steps/r2-p8-t1-after.ps1: TREE-DIGEST and VERDICT against the step (1) digest
EXIT_CODE: 0
Output Summary:
- Step (1): FORMAT-EXIT=0; FORMATTED=0; ALREADY-FORMATTED=627 (no file was rewritten; every file logged "Already formatted:"); process exit 0
- TREE-DIGEST before MCP: 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E
- MCP_ROUTE: CALLED - returned (ok true; summary "Ran bundled PoshQC format against WORKTREE"; no count or exit code is carried)
- TREE-DIGEST after MCP: 63-E3-09-1F-A2-29-36-BE-D8-B3-FC-89-37-91-79-69-7C-75-2C-F4-0E-1B-1F-C7-4B-DC-11-91-8E-30-9F-7E (equal; the MCP step rewrote nothing)
- Step (3) process exit 0. Top-level EXIT_CODE is the larger of steps (1) and (3).
