# PowerShell Final QC (static) — remediation cycle 1, [P2-T1]

Timestamp: 2026-11-14T05-29
Command: sh SCRATCH/issue-1156-static.sh over the four changed PowerShell files (check-only Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file text; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1), then pwsh -File SCRATCH/issue-1156-leak.ps1 (Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <item worktree root>)
EXIT_CODE: 0
Output Summary: one clean pass; no file rewritten.

| Step | Command | Exit | Findings |
|---|---|---|---|
| format (compare) | Invoke-Formatter vs file text, 4 files | 0 | 0 files with differences |
| analyze | Invoke-ScriptAnalyzer, 4 files | 0 | 0 |
| type check | not applicable for PowerShell | - | - |
| leak scan | Invoke-PoshQCLeakScan -Root | 0 | `Leak scan: 790 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.` |

Files: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` (788 logical lines), its bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1` (788), `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` (602), and `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1` (113).

No Python or TypeScript source changed in this cycle (the only non-PowerShell change is `quality-tiers.yml` and Markdown), so no Python or TypeScript final-QC static artifact is required.
