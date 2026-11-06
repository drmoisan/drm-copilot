# PowerShell Analyzer Gate (loop pass 2)

Timestamp: 2026-11-03T19-55
Task: [P6-T2]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-static.ps1: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 for each of the five files
EXIT_CODE: 0
Output Summary: TOTAL_FINDINGS=0 (0 findings in each of the five files). Pass 1 reported 2 findings, fixed before this pass (see poshqc-format.2026-11-03T19-55.md).

| File | Findings |
| --- | --- |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 0 |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionJson.Tests.ps1 | 0 |
