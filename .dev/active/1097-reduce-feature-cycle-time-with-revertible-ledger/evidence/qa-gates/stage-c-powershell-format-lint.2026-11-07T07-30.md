# Stage C PowerShell Format and Lint Gate (final loop pass)

Timestamp: 2026-11-07T07-15
Command: Invoke-PoshQCFormat check-only (a no-op WriteFile) over the folders of every changed PowerShell file, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each changed file, from a `sh` launcher under SCRATCH
EXIT_CODE: 0
Output Summary: This pass followed the Phase 3 fixes and preceded the final test gates. 22 changed .ps1 and .psm1 files; the formatter log holds an `Already formatted: ` line for each and no `Formatted: ` line (646 and 0 across the scanned folders). Analyzer findings: 0 in total. Type checking does not apply to PowerShell.
