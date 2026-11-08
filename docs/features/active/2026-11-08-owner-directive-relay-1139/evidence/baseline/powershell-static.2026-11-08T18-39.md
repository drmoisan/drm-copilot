# PowerShell Static Baseline (Phase 0, [P0-T1])

Timestamp: 2026-11-08T18-38
Command: pwsh -NoProfile -File SCRATCH/issue-1139-ps-static.ps1 -Root <worktree root> -PathList '.claude/hooks/validate-orchestrator-output.ps1;extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1;.claude/lib/orchestrator-state'
EXIT_CODE: 0
Output Summary: 17 files examined (the hook, its bundle copy, and the 15 modules under .claude/lib/orchestrator-state/). Check-only format comparison (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, output compared with the file text; no file written): 0 files would change. Invoke-ScriptAnalyzer 1.25.0 with the same settings file: 0 findings (no rule groups).

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format (check-only) | `Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the file text | 0 | 0 files would change |
| Analyze | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 | 0 findings |

The script reports its counts on stdout and exits 0 by design; the finding counts above, not the exit code, are the observation. Tracked files were not modified (`git status --porcelain` checked before the commit).
