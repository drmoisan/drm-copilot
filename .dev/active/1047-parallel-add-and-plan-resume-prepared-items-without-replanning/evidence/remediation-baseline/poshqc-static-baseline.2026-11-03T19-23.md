# PowerShell Static Baseline (remediation cycle 1)

Timestamp: 2026-11-03T19-23
Task: [P0-T4]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-static.ps1 (no -Apply): per file, Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 and an Invoke-Formatter comparison of the formatted text against the file text, with no write
EXIT_CODE: 0
Output Summary: 0 analyzer findings in each of the three files; the formatter would change none of them (SHA256 unchanged).

| File | Findings | Formatter would change |
| --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 0 | no |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 0 | no |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 0 | no |
