# R1 final QC: PowerShell static (P1-T7)

Timestamp: 2026-11-24T16-54
Command: sh SCRATCH/issue-1233-r1-static.sh r1-final-static SCRATCH/issue-1233-r1-files-final.txt (pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1: Invoke-PoshQCFormat -WriteFile { no-op } ; Invoke-PoshQCAnalyze ; Invoke-PoshQCLeakScan, then SCRATCH/issue-1233-ps-files.ps1 check over the listed files; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary:
- Files (11): the ten files of P0-T1 and tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1.
- Format: Invoke-PoshQCFormat with the non-writing -WriteFile seam; exit 0; finding count 0 (no "Formatted:" line; 1895 "Already formatted:"); per-file Invoke-Formatter check 11 of 11 already formatted, drift 0.
- Lint: Invoke-PoshQCAnalyze exit 0 ("PSScriptAnalyzer passed: no findings"); per-file Invoke-ScriptAnalyzer with pssa.settings.psd1: 0 findings across the 11 files.
- Type check: not applicable to PowerShell.
- Leak scan: Invoke-PoshQCLeakScan exit 0 ("Leak scan: 917 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures."); the new test file adds no unpaired global, environment, or location change.
- git status --porcelain identical before and after; no file rewritten. Baseline comparison: r1-powershell-static.2026-11-24T14-50.md also recorded 0 drift and 0 findings.
