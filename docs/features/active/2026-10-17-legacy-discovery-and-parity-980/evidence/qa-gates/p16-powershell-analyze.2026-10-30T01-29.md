# P16-T3 PowerShell analyze gate on the remediated tree

Timestamp: 2026-10-30T01-29
Task: [P16-T3] Run the PowerShell gates and regenerate the canonical coverage file from the full run.
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root <worktree> (scripts/powershell/PoshQC/settings/pssa.settings.psd1; the `poshqc / PowerShell QC static` job shape, run directly with the repository settings file rather than through the MCP tool)
EXIT_CODE: 0
Output Summary: The pass (2026-10-30T00-49 to 00-51 UTC, directly after the clean format step) printed "PSScriptAnalyzer passed: no findings under <worktree>" over the full population; `ANALYZE_EXIT=0`.
Result: PASS
