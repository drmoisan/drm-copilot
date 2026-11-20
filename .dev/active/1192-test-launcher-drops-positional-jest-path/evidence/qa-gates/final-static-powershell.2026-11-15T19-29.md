# Final-QC static artifact, PowerShell (P3-T1)

Timestamp: 2026-11-15T19-29
Command: format step `mcp__drm-copilot__run_poshqc_format` (repository-wide) with a direct compare-only `Invoke-Formatter` check; analyze step `mcp__drm-copilot__run_poshqc_analyze` with a direct `Invoke-ScriptAnalyzer` run using `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (`sh SCRATCH/issue-1192-static2.sh`) over the four hook copies and the two edited test files.
EXIT_CODE: 0
Output Summary:
- Format step: command as above, EXIT_CODE 0, drift files 0 of 6; `git status --porcelain` is empty before and after the step (all changes were committed), so the format step changed no tracked file.
- Analyze step: command as above, EXIT_CODE 0, findings 0 for each of the six files (total 0). The MCP result carries only an ok flag, so the finding count is from the direct run.
- Type check: not applicable for PowerShell.
