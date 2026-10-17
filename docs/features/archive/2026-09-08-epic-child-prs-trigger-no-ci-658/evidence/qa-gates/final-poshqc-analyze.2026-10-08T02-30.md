# Final PoshQC Analyze ([P2-T2], final loop pass)

Timestamp: 2026-10-08T02-30 (UTC)
Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders tests/scripts/workflows"
Route: mcp plus ci-evidence
Deviation: DEV-PWSH-ROUTE, DEV-CI-FINALQC
ExecutedCommand: mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree root, scan_folders ["tests/scripts/workflows"]) at head 8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7; analyzer literal read from workflow_dispatch CI run 37717224700, job 113116383126 "poshqc / PowerShell QC" on the same head
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37717224700/job/113116383126 (workflow CI, event workflow_dispatch, head 8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7, conclusion success)
EXIT_CODE: 0
Output Summary:
- MCP result: `ok: true`. The MCP result carries no analyzer text; EXIT_CODE is derived from the ok flag. No finding count is claimed from it.
- CI analyzer literal (log line 823, ANSI codes stripped, root redacted): `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>` (full-repository root; the plan literal `... under .` reflects a local `-Root .` run; the CI root is the checkout directory).
- Supersedes the interim artifact final-poshqc-analyze.2026-10-07T22-45.md (which cited the pre-fix run 37715960709).
