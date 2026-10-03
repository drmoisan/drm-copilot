# P6-T2 Analyze (loop pass 1)

Timestamp: 2026-10-03T10-02
Command: (1) pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "SCRATCH/analyze-final.log"; $LASTEXITCODE; (Select-String -SimpleMatch 'PSScriptAnalyzer passed: no findings under').Count; TREE-DIGEST (2) mcp__drm-copilot__run_poshqc_analyze (workspace_root = WORKTREE) (3) SCRATCH/steps/p6-t2-after.ps1: TREE-DIGEST
EXIT_CODE: 0
Output Summary:
- Direct analyze run (gating) exit code: 0
- 'PSScriptAnalyzer passed: no findings under' count: 1 (zero findings, AC-26)
- TREE-DIGEST before MCP call: 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6
- MCP_ROUTE: CALLED; the call returned {"ok":true,"tool":"run_poshqc_analyze", "summary":"Ran bundled PoshQC analyze against 'WORKTREE'."}
- TREE-DIGEST after MCP call: 2F-5C-7A-91-0D-83-E3-FD-31-F2-FF-D5-6D-55-0D-23-85-8D-C8-9E-77-9E-0B-06-9E-77-3D-C4-45-E1-0C-F6 (TS=2026-10-03T10-04). The after-script was first issued in the same tool batch as the MCP call; it was re-run after the MCP call returned, and both runs printed this value.
- TREE-DIGEST values equal: the MCP route step changed no file in scope
- Result: PASS
