# Final QC: PowerShell Static (P7-T1, loop restart after the #1159 and #1179 merges)

Timestamp: 2026-11-14T10-17
Command: sh SCRATCH/issue-1158-ps-gate-static.sh (`Invoke-PoshQCFormat -Root .` with a no-op `-WriteFile` and a capturing `-Logger`; `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every file of `Get-PoshQCFileList -Root .`; `Invoke-PoshQCLeakScan -Root .`; `git status --porcelain` before and after)
EXIT_CODE: 0
Output Summary: the loop restarted at P7-T1 because merging `origin/main` (PR #1177 for #1159 and PR #1180 for #1179) and the switch to registration branch B changed the tree after the `powershell-static.2026-11-14T08-51.md` run. Format: 0 `Formatted:` lines and 1724 `Already formatted:` lines. PSScriptAnalyzer: 0 findings over 1724 files. Leak scan: exit 0. `git status --porcelain` was unchanged. The first PSScriptAnalyzer call on `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` raised the known PSScriptAnalyzer 1.25 `NullReferenceException`; a single retry of that file returned 0 findings.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format | `Invoke-PoshQCFormat -Root .` (check form, no write) | 0 | 0 |
| lint | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`, 1724 files | 0 | 0 |
| leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 | 0 |

Type check: not applicable (PowerShell).
