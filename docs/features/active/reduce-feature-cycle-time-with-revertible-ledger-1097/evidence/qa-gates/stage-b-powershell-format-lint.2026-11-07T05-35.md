# Stage B PowerShell Format and Lint Gate (loop pass 2)

Timestamp: 2026-11-07T05-35
Command: Invoke-PoshQCFormat check-only (a no-op WriteFile) over scripts/dev-tools, tests/scripts/dev-tools, and tests/scripts/claude-lib/orchestrator-state, then Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each of the six stage B PowerShell files, run from a `sh` launcher under SCRATCH
EXIT_CODE: 0
Output Summary: This pass follows a repair of scripts/dev-tools/Get-StageTimingReport.ps1: the first PowerShell test gate measured that file at 5 of 6 lines (83.33%) because Pester does not record the default-value expression of a param block as executed, so the default root is now resolved by an `if` statement in the script body that a test runs. The formatter log holds one `Already formatted: ` line and no `Formatted: ` line for each of the six stage B files and for every file of the three scanned folders. Analyzer findings: 0 for every file, 0 in total. Type checking does not apply to PowerShell.
