# PowerShell Static Baseline (Phase 0, [P0-T1])

Timestamp: 2026-11-12T03-12
Command: sh SCRATCH/issue-1167-psstatic.sh tests/scripts/claude-runtime (pwsh 7: Invoke-Formatter check per file with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Step 1 format check (no write): files=36, format drift=0, exit 0, finding count 0.
- Step 2 PSScriptAnalyzer: findings=0, exit 0.
- Step 3 Invoke-PoshQCLeakScan: 741 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures; exit 0. (Informational: scan folder tests/powershell does not exist and is skipped.)
- git status --porcelain before and after the format step: unchanged (no file rewritten).
