# PowerShell Final Static Loop, Second Restart (P6-T2)

Timestamp: 2026-11-10T01-06
Command: bash SCRATCH/issue-1164-ps-final-static.sh <the same 14 files> (git status --porcelain; Invoke-Formatter write mode; git status --porcelain; Invoke-Formatter check and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary:
- Reason for the restart: the first final pytest gate (pytest-gate record of 2026-11-10T01-05) failed on the branch; a test stub and one parallel-orchestrate sentence (with its mirror) changed, and the loop restarted from formatting.
- Step 1, format (write mode): exit 0; 14 of 14 files UNCHANGED; the git status --porcelain listings before and after (12 lines each) are byte-identical. Finding count 0.
- Step 2, PSScriptAnalyzer: exit 0; TOTAL format_findings=0 pssa_findings=0. Finding count 0.
- Step 3, Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 744 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." Finding count 0 failures.
