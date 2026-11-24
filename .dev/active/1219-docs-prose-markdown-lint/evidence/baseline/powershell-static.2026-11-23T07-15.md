# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-23T07-15
Command: sh SCRATCH/issue-1219-static.sh (PowerShell 7: imports branch-current scripts/powershell/PoshQC/PoshQC.psd1; step 1 Invoke-PoshQCFormat -ScanFolders .claude/lib/docs, tests/scripts/claude-lib/docs with a no-op -WriteFile (check mode, counts `Formatted:` log lines); step 2 Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information on every .ps1/.psm1/.psd1 under the same folders)
EXIT_CODE: 0
Output Summary:
- Step 1 format check: EXIT_CODE 0; 210 files examined; 210 `Already formatted:`; 0 files that would be reformatted. Finding count: 0.
- Step 2 PSScriptAnalyzer: EXIT_CODE 0; finding count: 0.
