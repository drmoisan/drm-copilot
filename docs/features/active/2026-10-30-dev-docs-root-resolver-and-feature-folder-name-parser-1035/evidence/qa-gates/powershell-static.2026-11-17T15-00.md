# PowerShell Final Static Loop (Remediation Cycle 1, P3-T1)

Timestamp: 2026-11-17T15-00
Command: sh SCRATCH/issue-1035-static.sh p3 (pwsh -NoProfile -File SCRATCH/issue-1035-ps-static.ps1 -Root <worktree>: Invoke-PoshQCFormat with a non-writing -WriteFile seam, Invoke-PoshQCAnalyze with scripts/powershell/PoshQC/settings/pssa.settings.psd1, Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary: One pass at HEAD e10f769352dffd18ac3608d74c41fd2c4db6244c, run 2026-11-17T14-53 to 14-59 UTC; every step exited 0 with zero findings, and no step changed a file.

| Step | Exit code | Observation | Findings |
| --- | --- | --- | --- |
| Format (non-writing `-WriteFile`) | 0 | 1814 files; 1814 `Already formatted:` lines, 0 `Formatted:` lines | 0 |
| Analyzer (pssa.settings.psd1) | 0 | Error 0, Warning 0, Information 0 | 0 |
| Leak scan | 0 | `Leak scan: 874 files, 79 findings, 77 exempt, 2 allowlisted, 0 failures.` | 0 failures |

Tree state after the loop: `git status --porcelain` listed no entry.
