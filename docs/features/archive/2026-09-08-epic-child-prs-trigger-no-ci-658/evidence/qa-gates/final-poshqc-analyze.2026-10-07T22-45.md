# Final PoshQC Analyze ([P2-T2])

Timestamp: 2026-10-07T22-45
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders tests/scripts/workflows"
Route: mcp
Deviation: DEV-PWSH-ROUTE, DEV-CI-FAILBEFORE (interim literal source)
ExecutedCommand: mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree root, scan_folders ["tests/scripts/workflows"]) at fix head 00798863
EXIT_CODE: 0
Output Summary:
- MCP result: `ok: true`. The MCP result carries no analyzer text; EXIT_CODE is derived from the ok flag. No finding count is claimed from it.
- Interim citation of the analyzer literal: workflow_dispatch CI run 37715960709, job 113112343480 (head 632fe595199cc75e7e1560f010acc3a0e611aab2, which already contains CiWorkflow.Tests.ps1), log line 813: `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>` (full-repository root).
- PendingCiCitation: the literal is to be re-cited from the CI `poshqc` job on the fix head. This task stays unchecked until then.
