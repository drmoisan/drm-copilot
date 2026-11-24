# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-24T04-46
Command: sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-static.ps1 -FileList .claude/hooks/enforce-epic-merge-gate.ps1,.codex/hooks/enforce-epic-merge-gate.ps1,.claude/hooks/hook-release-pull-request-context.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1, runs Invoke-PoshQCFormat over the three files, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file, then @(Get-Content -LiteralPath <path>).Count)
EXIT_CODE: 0
Output Summary:
- Formatter: 0 `Formatted: ` lines, 3 `Already formatted: ` lines (changed-file count 0).
- `git status --porcelain` captured before and after the run: unchanged (clean tree).
- Analyzer findings: `.claude/hooks/enforce-epic-merge-gate.ps1` 0; `.codex/hooks/enforce-epic-merge-gate.ps1` 0; `.claude/hooks/hook-release-pull-request-context.ps1` 0 (total 0).
- Sizes: `.claude/hooks/enforce-epic-merge-gate.ps1` 498 lines; `.codex/hooks/enforce-epic-merge-gate.ps1` 445 lines; `.claude/hooks/hook-release-pull-request-context.ps1` 116 lines.
- No PoshQC MCP result was used for any count.
