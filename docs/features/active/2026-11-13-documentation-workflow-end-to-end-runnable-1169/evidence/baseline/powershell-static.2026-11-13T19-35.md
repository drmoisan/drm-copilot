# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-13T19-28
Command: sh SCRATCH/issue-1169-static.sh p0 (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree root> with a no-op WriteFile seam, so the formatter rewrites nothing and each would-be change is counted from its "Formatted:" log line; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on every file of Get-PoshQCFileList -Root <worktree root>; PSScriptAnalyzer 1.25.0)
EXIT_CODE: 0
Output Summary:
- Mode: check-only (no file rewritten).
- Files scanned: 1546 (whole worktree root, default PoshQC exclusions; the same scope as the CI `poshqc / PowerShell QC static` job).
- Formatter change count: 0 (FORMAT_CHANGED=0; formatter step exit 0).
- Analyzer finding count: 0 (ANALYZER_FINDINGS=0; no Error, Warning, or Information findings).
- `git status --porcelain` after the run: empty (0 lines).
