# PowerShell Final Static Loop, Re-run (Remediation Cycle 1, P3-T1 after the P3-T5 fix)

Timestamp: 2026-11-17T15-50
Command: sh SCRATCH/issue-1035-static.sh p3b ps (pwsh -NoProfile -File SCRATCH/issue-1035-ps-static.ps1 -Root <worktree>: Invoke-PoshQCFormat with a non-writing -WriteFile seam, Invoke-PoshQCAnalyze with scripts/powershell/PoshQC/settings/pssa.settings.psd1, Invoke-PoshQCLeakScan -Root)
EXIT_CODE: 0
Output Summary: Re-run of the PowerShell loop from formatting after the P3-T5 fix commit 520d78e8aa3a9f9f591bb76d3286e43dc2ad1247 changed .codex/hooks/authorize-root-epic-invocation.ps1, its bundle copy and its suite (other/task-check.P3-T5.2026-11-17T15-29.md). Run 2026-11-17T15-30 to 15-37 UTC at that HEAD; every step exited 0 with zero findings and no step changed a file. powershell-static.2026-11-17T15-00.md stands for the tree before the fix. The Python static record python-static.2026-11-17T15-00.md stays current, because no `.py` file changed after it.

| Step | Exit code | Observation | Findings |
| --- | --- | --- | --- |
| Format (non-writing `-WriteFile`) | 0 | 1814 files; 1814 `Already formatted:` lines, 0 `Formatted:` lines | 0 |
| Analyzer (pssa.settings.psd1) | 0 | Error 0, Warning 0, Information 0 | 0 |
| Leak scan | 0 | `Leak scan: 874 files, 79 findings, 77 exempt, 2 allowlisted, 0 failures.` | 0 failures |

Tree state after the loop: `git status --porcelain` listed no entry.
