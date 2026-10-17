# PoshQC Analyze Baseline (P0-T21)

Timestamp: 2026-10-16T00-27

Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=WORKTREE_ROOT scan_folders=[".claude/hooks","tests/scripts/claude-hooks"]
EXIT_CODE: 0
MCP result: `ok: true`; summary "Ran bundled PoshQC analyze against 'WORKTREE_ROOT' with 2 selected scan folder(s)." (call disposition only; no finding count is read from the MCP result).

Command: sh SCRATCH/issue-929/P0-T21-1.sh
Script: `$n = 0; foreach ($f in @('.claude/hooks/validate-task-researcher-output.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1')) { $d = @(Invoke-ScriptAnalyzer -Path $f -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information); $n += $d.Count; '{0} | FINDINGS={1}' -f $f, $d.Count }; 'TOTAL_FINDINGS=' + $n`
EXIT_CODE: 0
Output:
```
.claude/hooks/validate-task-researcher-output.ps1 | FINDINGS=0
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | FINDINGS=0
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | FINDINGS=0
TOTAL_FINDINGS=0
```

Output Summary: `TOTAL_FINDINGS=0`. No analyzer finding in any of the nine files at baseline.
