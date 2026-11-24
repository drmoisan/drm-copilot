# Final PowerShell Static QC (P4-T1)

Timestamp: 2026-11-24T08-42
Command: sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-static.ps1 -FileList <19 new and changed .ps1 files from git status --porcelain>; sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-leakscan.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary:
- Step 1, format (Invoke-PoshQCFormat over the 19 files, through the sh launcher route): EXIT_CODE 0; 0 `Formatted: ` lines, 19 `Already formatted: ` lines; `git status --porcelain` unchanged before and after.
- Step 2, analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): EXIT_CODE 0; 0 findings across the 19 files (both gates and their bundle copies, the four leg copies, the four pure-file copies, and the eight new or changed test files).
- Step 3, type check: not applicable for PowerShell.
- Step 4, leak scan (Invoke-PoshQCLeakScan -Root): EXIT_CODE 0; `912 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures`. One warning: the scan configuration folder `tests/powershell` does not exist and was skipped (pre-existing configuration, unrelated to this change).
- No counts were read from a PoshQC MCP result.
