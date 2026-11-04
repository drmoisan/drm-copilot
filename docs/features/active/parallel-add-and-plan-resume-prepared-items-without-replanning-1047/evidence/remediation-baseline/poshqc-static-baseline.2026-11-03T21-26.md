# PowerShell Static Baseline (remediation cycle 2)

Timestamp: 2026-11-03T21-26
Task: [P0-T4]
Command: sh SCRATCH/issue-1047-static.sh -Files .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1,tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 (PowerShell 7: Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file; Invoke-Formatter with the same settings compared in memory, no -Apply, nothing written)
EXIT_CODE: 0
Output Summary: 0 analyzer findings in each file (total 0); the formatter would change neither file; SHA256 before and after equal for both.

| File | Findings | Formatter would change | SHA256 |
| --- | --- | --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 0 | no | 7F0A6920239DB6B623A641F075D4CEB7D0776F686CAA9AF6AA87CACB7A21090A |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 0 | no | 2C5F1CBB232DD110429549352E3B5CD897BF37082E7C7C1C31B02007B15F070C |
