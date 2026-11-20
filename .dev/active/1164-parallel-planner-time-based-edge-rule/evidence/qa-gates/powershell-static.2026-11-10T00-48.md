# PowerShell Final Static Loop, Restarted (P6-T2)

Timestamp: 2026-11-10T00-48
Command: bash SCRATCH/issue-1164-ps-final-static.sh <the same 14 files as the earlier P6-T2 record> (git status --porcelain; Invoke-Formatter write mode; git status --porcelain; Invoke-Formatter check and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary:
- Reason for the restart: the first final Pester gate (pester-gate record of 2026-11-10T00-46) failed on the branch; .claude/lib/parallel-drift/ParallelDriftAccess.psm1 and its bundle mirror gained the CONVENTION sentence, and the loop restarted from formatting.
- Step 1, format (write mode): exit 0; 14 of 14 files UNCHANGED; git status --porcelain is identical before and after. Finding count 0.
- Step 2, PSScriptAnalyzer: exit 0; TOTAL format_findings=0 pssa_findings=0. Finding count 0.
- Step 3, Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 744 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." Finding count 0 failures.
