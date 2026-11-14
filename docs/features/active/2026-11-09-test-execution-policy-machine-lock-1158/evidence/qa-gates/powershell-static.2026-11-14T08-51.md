# Final QC: PowerShell Static (P7-T1)

Timestamp: 2026-11-14T08-51
Command: sh SCRATCH/issue-1158-ps-gate-static.sh (`Invoke-PoshQCFormat -Root .` with a no-op `-WriteFile` and a capturing `-Logger`; `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every file of `Get-PoshQCFileList -Root .`; `Invoke-PoshQCLeakScan -Root .`; `git status --porcelain` before and after)
EXIT_CODE: 0
Output Summary: format 0 `Formatted:` lines and 1701 `Already formatted:` lines; PSScriptAnalyzer 0 findings over 1701 files; leak scan exit 0; `git status --porcelain` unchanged. The first PSScriptAnalyzer call on the bundled `PoshQC.psm1` raised the known PSScriptAnalyzer 1.25 `NullReferenceException`. The script retried that file once, and the retry returned 0 findings. This is a tool fault, not a finding.

## Steps

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format | `Invoke-PoshQCFormat -Root .` (check form, no write) | 0 | 0 |
| lint | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`, 1701 files | 0 | 0 |
| leak scan | `Invoke-PoshQCLeakScan -Root .` | 0 | 0 |

Type check: not applicable (PowerShell).
