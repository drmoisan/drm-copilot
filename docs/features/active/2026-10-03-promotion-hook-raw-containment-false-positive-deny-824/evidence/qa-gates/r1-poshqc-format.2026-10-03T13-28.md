# r1 P8-T1 — PowerShell format (loop pass 2; direct write-mode run, then the MCP route step bracketed by TREE-DIGEST)

Timestamp: 2026-10-03T13-28
Command: (1) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t1.ps1 -Worktree WORKTREE, running `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path' *> "$Scratch/r1-format-final.log"`, the Formatted and Already-formatted counts, TREE-DIGEST, and the VERDICT line; (2) MCP tool mcp__drm-copilot__run_poshqc_format with workspace_root WORKTREE; (3) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t1-after.ps1 -Worktree WORKTREE (A0, TREE-DIGEST, VERDICT against the step (1) value)
EXIT_CODE: 0
Output Summary:
- Step (1), TS=2026-10-03T13-28, exit 0: FORMAT-EXIT=0; FORMATTED=0; ALREADY-FORMATTED=624 (no file rewritten); TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93
- Step (2): MCP_ROUTE: CALLED; returned `{"ok":true,"tool":"run_poshqc_format","workspace_root":"WORKTREE","summary":"Ran bundled PoshQC format against 'WORKTREE'."}`
- Step (3), TS=2026-10-03T13-28, exit 0: TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93 (equal; the MCP call changed no file in scope)
- Loop pass 2 (restarted after the pass-1 P8-T6 failure). Top-level EXIT_CODE is the larger of steps (1) and (3): 0.
