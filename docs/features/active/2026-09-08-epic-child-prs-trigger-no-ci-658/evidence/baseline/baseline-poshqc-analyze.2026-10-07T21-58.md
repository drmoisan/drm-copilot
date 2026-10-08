# Baseline PoshQC Analyze ([P0-T17])

Timestamp: 2026-10-07T21-58
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders tests/scripts/workflows"
Route: mcp
Deviation: DEV-PWSH-ROUTE, DEV-CI-BASELINE
ExecutedCommand: mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree root, scan_folders ["tests/scripts/workflows"])
EXIT_CODE: 0
Output Summary:
- MCP result: `ok: true`. The MCP result carries no analyzer output; the EXIT_CODE above is derived from the ok flag. No finding count is claimed from it.
- Analyzer literal cited from CI run 37645267440 (workflow CI, event push, head 08ee030d9584bf15882fbb3654c8e38f34c7c359, conclusion success), job 112874273719 "poshqc / PowerShell QC", https://github.com/drmoisan/drm-copilot/actions/runs/37645267440/job/112874273719 , log line 830:
  - `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>`
- Scope note: the CI analyze step covers the full repository, which includes tests/scripts/workflows.
- Item branch differs from 08ee030d only in documentation files.
