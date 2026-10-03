# r1 P8-T2 — PowerShell analyze (loop pass 1)

Timestamp: 2026-10-03T13-26
Command: (1) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t2.ps1 -Worktree WORKTREE (direct `Invoke-PoshQCAnalyze -Root (Get-Location).Path` child, PASS-LINE count, TREE-DIGEST, VERDICT); (2) MCP tool mcp__drm-copilot__run_poshqc_analyze with workspace_root WORKTREE; (3) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t2-after.ps1 -Worktree WORKTREE (TREE-DIGEST and VERDICT against the step (1) value)
EXIT_CODE: 0
Output Summary:
- Step (1), TS=2026-10-03T13-26, exit 0: ANALYZE-EXIT=0; PASS-LINE=1 (`PSScriptAnalyzer passed: no findings under WORKTREE`); TREE-DIGEST=D5-A4-13-A6-F7-7C-7F-93-57-6A-C6-FB-97-11-42-D9-9A-77-CE-97-19-81-DD-95-66-AC-68-18-80-66-BB-82
- Step (2): MCP_ROUTE: CALLED; returned `{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"WORKTREE","summary":"Ran bundled PoshQC analyze against 'WORKTREE'."}`
- Step (3), TS=2026-10-03T13-27, exit 0: TREE-DIGEST equal to step (1)
- Loop pass 1. Superseded by the pass-2 artifact because P8-T6 failed in this pass.
