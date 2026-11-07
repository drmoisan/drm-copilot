# Final QC: PSScriptAnalyzer

Timestamp: 2026-11-07T15-09
Command: Invoke-ScriptAnalyzer -Path tests/scripts/claude-runtime -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information (pwsh via SCRATCH/issue-1106-static.sh final; the folder includes tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1)
EXIT_CODE: 0
Output Summary: FindingCount: 0 (zero findings, including the new guard file).
