# Stage C PowerShell Format and Lint Gate

Timestamp: 2026-11-07T07-04
Command: Invoke-PoshQCFormat check-only (a no-op WriteFile) over the folders of every changed PowerShell file, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each changed file, from a `sh` launcher under SCRATCH
EXIT_CODE: 0
Output Summary: 22 changed .ps1 and .psm1 files, derived from the diff from the merge base of origin/main and HEAD. The formatter log holds an `Already formatted: ` line for each of the 22 files and no `Formatted: ` line: 646 `Already formatted: ` lines and 0 `Formatted: ` lines across the scanned folders. Analyzer findings: 0 in total. Type checking does not apply to PowerShell.
