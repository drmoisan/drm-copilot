# r1 P8-T1 — PowerShell format (direct write-mode run, then the MCP route step bracketed by TREE-DIGEST)

Timestamp: 2026-10-03T13-24
Command: (1) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t1.ps1 -Worktree WORKTREE, running `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path' *> "$Scratch/r1-format-final.log"`, the Formatted and Already-formatted counts, TREE-DIGEST, and the VERDICT line; (2) MCP tool mcp__drm-copilot__run_poshqc_format with workspace_root WORKTREE; (3) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t1-after.ps1 -Worktree WORKTREE (A0, TREE-DIGEST, VERDICT comparing it with the step (1) value)
EXIT_CODE: 0
Output Summary:
- Step (1), TS=2026-10-03T13-24, exit 0: FORMAT-EXIT=0; FORMATTED=0; ALREADY-FORMATTED=624 (no file rewritten); TREE-DIGEST=D5-A4-13-A6-F7-7C-7F-93-57-6A-C6-FB-97-11-42-D9-9A-77-CE-97-19-81-DD-95-66-AC-68-18-80-66-BB-82
- Step (2): MCP_ROUTE: CALLED; the call returned `{"ok":true,"tool":"run_poshqc_format","workspace_root":"WORKTREE","summary":"Ran bundled PoshQC format against 'WORKTREE'."}` (no exit code, count, or percentage; the direct run is the gating measurement)
- Step (3), TS=2026-10-03T13-25, exit 0: TREE-DIGEST=D5-A4-13-A6-F7-7C-7F-93-57-6A-C6-FB-97-11-42-D9-9A-77-CE-97-19-81-DD-95-66-AC-68-18-80-66-BB-82 (equal to step (1); the MCP call changed no file in scope)
- Top-level EXIT_CODE is the larger of the step (1) and step (3) exit codes: 0.
