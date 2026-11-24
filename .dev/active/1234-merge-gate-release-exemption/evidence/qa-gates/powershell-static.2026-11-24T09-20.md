# Final PowerShell Static QC (P4-T1, loop restart after remediation)

Timestamp: 2026-11-24T09-20
Command: sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-static.ps1 -FileList <19 new and changed .ps1 files from git status --porcelain>; sh SCRATCH/issue-1234-ps.sh SCRATCH/issue-1234-leakscan.ps1 (Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary:
- Restart of the final QA loop after the remediation recorded in evidence/other/final-qa-remediation.2026-11-24T09-16.md; this artifact supersedes powershell-static.2026-11-24T08-42.md for the final gate (that file is kept unchanged).
- Step 1, format (Invoke-PoshQCFormat, 19 files): EXIT_CODE 0; 0 `Formatted: ` lines, 19 `Already formatted: `; `git status --porcelain` unchanged before and after.
- Step 2, analyzer (direct Invoke-ScriptAnalyzer with pssa.settings.psd1): EXIT_CODE 0; 0 findings.
- Step 3, type check: not applicable for PowerShell.
- Step 4, leak scan (Invoke-PoshQCLeakScan -Root): EXIT_CODE 0; `912 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures`.
