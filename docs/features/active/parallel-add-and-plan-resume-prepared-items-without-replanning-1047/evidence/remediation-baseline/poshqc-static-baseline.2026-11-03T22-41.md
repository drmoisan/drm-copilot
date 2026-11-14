# PowerShell Static Baseline (remediation cycle 3)

Timestamp: 2026-11-03T22-41
Task: [P0-T4]
Command: sh SCRATCH/issue-1047-static.sh -Files .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1,tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 (PowerShell 7: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file; Invoke-Formatter with the same settings compared in memory, no -Apply, nothing written)
EXIT_CODE: 0
Output Summary: 0 analyzer findings in each file (total 0); the formatter would change neither file; SHA256 before and after equal for both.

| File | Findings | Formatter would change | SHA256 |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 0 | no | FEE660825D4C800B935130CF8AEE861C373259460F6C7A380A29A64F619BF69C |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 0 | no | EC6B6ECFC8BFFF78832E05AD35B4947740D319BE3B03A3045FE2293E2957FD5C |
