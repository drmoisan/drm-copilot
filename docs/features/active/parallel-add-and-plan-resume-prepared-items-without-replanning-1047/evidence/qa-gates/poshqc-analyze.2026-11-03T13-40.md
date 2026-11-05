# PoshQC Analyze Gate

Timestamp: 2026-11-03T13-40
Task: [P8-T2]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-static.ps1 running Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 directly over the P8-T1 file set (with a re-import retry for the intermittent analyzer NullReferenceException)
EXIT_CODE: 0
Output Summary: TOTAL_FINDINGS=0 across 10 files (Error, Warning, and Information severities all included by the settings).

| File | Findings |
| --- | --- |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | 0 |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 0 |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 0 |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 0 |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1 | 0 |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | 0 |
