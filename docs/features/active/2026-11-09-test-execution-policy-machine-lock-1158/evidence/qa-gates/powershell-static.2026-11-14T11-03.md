# Final QC: PowerShell Static (P7-T1, loop restart after the #1162 merge and the new-code coverage tests)

Timestamp: 2026-11-14T11-03
Command: sh SCRATCH/issue-1158-ps-gate-static.sh (`Invoke-PoshQCFormat -Root .` with a no-op `-WriteFile` and a capturing `-Logger`; `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every file of `Get-PoshQCFileList -Root .`; `Invoke-PoshQCLeakScan -Root .`; `git status --porcelain` before and after)
EXIT_CODE: 0
Output Summary: the loop restarted at P7-T1 for two reasons: PR #1181 (#1162, the last sibling) merged into `origin/main` and was merged into the branch, and four PowerShell test files gained cases that lift new-code line coverage to at least 90%. Format: 0 `Formatted:` lines and 1741 `Already formatted:` lines. PSScriptAnalyzer: 0 findings over 1741 files. Leak scan: exit 0. `git status --porcelain` was unchanged. The first PSScriptAnalyzer call on `.claude/lib/docs/DocsPythonSyntax.psm1` raised a tool error, `A parameter cannot be found that matches parameter name 'Function'`. A single retry of that file returned 0 findings, so this was a tool fault, not a finding.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format | `Invoke-PoshQCFormat -Root .` (check form, no write) | 0 | 0 |
| lint | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`, 1741 files | 0 | 0 |
| leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 | 0 |

Type check: not applicable (PowerShell).
