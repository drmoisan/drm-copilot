# Final QC: PowerShell Static (remediation cycle 1, P3-T1)

Timestamp: 2026-11-14T15-29
Command: sh SCRATCH/issue-1158-ps-gate-static.sh (Invoke-PoshQCFormat -Root . with a no-op -WriteFile and a capturing -Logger; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over every file of Get-PoshQCFileList -Root .; Invoke-PoshQCLeakScan -Root .; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary: format check 0 Formatted lines and 1742 Already formatted lines; PSScriptAnalyzer 0 findings over 1742 files; leak scan 832 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (exit 0). The porcelain status differed only by three evidence files that were written under evidence/qa-gates/ while the check ran (jest-extension-suite, pester-suite, and pytest-suite of 2026-11-14T15-28); no PowerShell file changed. Python and shell static checks are not re-run: this cycle changes no Python or shell file.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| format (check form) | Invoke-PoshQCFormat -Root . (no write) | 0 | 0 |
| lint | Invoke-ScriptAnalyzer with pssa.settings.psd1, 1742 files | 0 | 0 |
| leak scan | Invoke-PoshQCLeakScan -Root . | 0 | 0 failures |

Type check: not applicable (PowerShell).

## Tool Faults

- The first run of this step, at the start of the final QA sequence on the same commit, returned exit 1: PSScriptAnalyzer raised "Object reference not set to an instance of an object" on extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 on both its call and its retry, which the script counts as one finding. That file is unchanged by this branch, and the same file had 0 findings in the P0-T3 baseline and both phase gates. This rerun analyzed it with 0 findings.
- In this rerun, the first PSScriptAnalyzer call on .claude/lib/blast-radius/BlastRadiusConfig.psm1 raised the same exception; its retry returned 0 findings.
