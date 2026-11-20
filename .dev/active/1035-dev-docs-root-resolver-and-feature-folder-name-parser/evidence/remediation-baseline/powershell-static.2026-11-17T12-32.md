# PowerShell Static Baseline (Remediation Cycle 1, P0-T1)

Timestamp: 2026-11-17T12-32
Command: sh SCRATCH/issue-1035-static.sh p0 (pwsh -NoProfile -File SCRATCH/issue-1035-ps-static.ps1 -Root <worktree>, which imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat with a non-writing -WriteFile seam, Invoke-PoshQCAnalyze with scripts/powershell/PoshQC/settings/pssa.settings.psd1 through a recording -AnalyzeFile seam, and Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Baseline-Head: 4ba9c6ab33076366b1d40e0ccb3d61142e1278d4
Output Summary: Format, analyzer and leak scan clean at the starting HEAD. Run window 2026-11-17T12-28 to 2026-11-17T12-32 (UTC).

| Step | Exit code | Observation | Findings |
| --- | --- | --- | --- |
| Format (non-writing `-WriteFile`) | 0 | 1809 files; 1809 `Already formatted:` lines, 0 `Formatted:` lines | 0 |
| Analyzer (pssa.settings.psd1) | 0 | Error 0, Warning 0, Information 0; 0 NullReferenceException retries | 0 |
| Leak scan | 0 | `Leak scan: 869 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures.` (the scan configuration warns that the folder `tests/powershell` does not exist and skips it) | 0 failures |

Tree state after the task: `git status --porcelain` listed only the two untracked cycle files; no tracked change.
