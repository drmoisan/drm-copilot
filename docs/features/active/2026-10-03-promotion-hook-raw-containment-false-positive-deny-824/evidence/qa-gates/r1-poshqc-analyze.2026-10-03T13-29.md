# r1 P8-T2 — PowerShell analyze (loop pass 2)

Timestamp: 2026-10-03T13-29
Command: (1) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t2.ps1 -Worktree WORKTREE (direct `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "$Scratch/r1-analyze-final.log"`, PASS-LINE count, TREE-DIGEST, VERDICT); (2) MCP tool mcp__drm-copilot__run_poshqc_analyze with workspace_root WORKTREE; (3) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t2-after.ps1 -Worktree WORKTREE (TREE-DIGEST and VERDICT against the step (1) value)
EXIT_CODE: 0
Output Summary:
- Step (1), TS=2026-10-03T13-29, exit 0: ANALYZE-EXIT=0; PASS-LINE=1 (zero findings); TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93
- Step (2): MCP_ROUTE: CALLED; returned `{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"WORKTREE","summary":"Ran bundled PoshQC analyze against 'WORKTREE'."}`
- Step (3), TS=2026-10-03T13-30, exit 0: TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93 (equal)
