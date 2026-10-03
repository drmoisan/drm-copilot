# P6-T1 Format (loop pass 1)

Timestamp: 2026-10-03T10-02
Command: (1) pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path' *> "SCRATCH/format-final.log"; $LASTEXITCODE; Select-String counts of '^Formatted: ' and '^Already formatted: '; TREE-DIGEST (2) mcp__drm-copilot__run_poshqc_format (workspace_root = WORKTREE) (3) SCRATCH/steps/p6-t1-after.ps1: TREE-DIGEST
EXIT_CODE: 0
Output Summary:
- Direct format run (gating, write mode) exit code: 0
- 'Formatted: ' count: 0 (no file rewritten)
- 'Already formatted: ' count: 620
- TREE-DIGEST before MCP call: 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6
- MCP_ROUTE: CALLED; the call returned {"ok":true,"tool":"run_poshqc_format", "summary":"Ran bundled PoshQC format against 'WORKTREE'."}
- TREE-DIGEST after MCP call: 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6
- TREE-DIGEST values equal: the MCP route step changed no file in scope
- Result: PASS
