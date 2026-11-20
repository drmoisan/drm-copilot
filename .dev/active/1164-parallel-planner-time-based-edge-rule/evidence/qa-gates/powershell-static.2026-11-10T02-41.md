# PowerShell Final Static Loop, Correction (remediation P2-T2)

Timestamp: 2026-11-10T02-41
Command: sh SCRATCH/issue-1164-ps-static.sh (pwsh: git status --porcelain; Invoke-Formatter check-only comparison with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer with the same settings; git status --porcelain; Invoke-PoshQCLeakScan -Root from the branch PoshQC.psd1) over BlastRadiusAccess.psm1, ParallelDriftAccess.psm1, ParallelAdmissionPrecedenceGate.psm1, Invoke-ParallelAdmission.ps1 and their four bundle mirrors
EXIT_CODE: 0
Output Summary:
- Step 1, format (check-only, Invoke-Formatter output compared with file text): exit 0; 0 of 8 files differ. Finding count 0. The git status --porcelain listings before and after the static steps are identical (20 lines each), so the formatter changed no file.
- Step 2, PSScriptAnalyzer: exit 0; pssa_findings=0. Finding count 0.
- Step 3, Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 744 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." Finding count 0 failures.
