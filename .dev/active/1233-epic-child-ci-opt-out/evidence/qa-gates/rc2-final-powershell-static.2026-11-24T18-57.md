# RC2 final QC: PowerShell static (P1-T8)

Timestamp: 2026-11-24T18-57
Command: sh SCRATCH/issue-1233-r1-static.sh rc2-final-ps SCRATCH/issue-1233-rc2-psfiles.txt (pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1: Invoke-PoshQCFormat -WriteFile { no-op } ; Invoke-PoshQCAnalyze ; Invoke-PoshQCLeakScan, then SCRATCH/issue-1233-ps-files.ps1 check (Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1) over tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1; git status --porcelain before and after)
EXIT_CODE: 0
Output Summary:
- Format: Invoke-PoshQCFormat with the non-writing -WriteFile seam; exit 0; finding count 0 (no "Formatted:" line; 1897 "Already formatted:"); per-file Invoke-Formatter check of the contract test: already formatted, drift 0.
- Lint: Invoke-PoshQCAnalyze exit 0 ("PSScriptAnalyzer passed: no findings"); per-file Invoke-ScriptAnalyzer with pssa.settings.psd1: 0 findings.
- Type check: not applicable to PowerShell.
- Leak scan: Invoke-PoshQCLeakScan exit 0 ("Leak scan: 919 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.").
- git status --porcelain identical before and after; no file rewritten.
- Baseline: lexicographically greatest r1-powershell-static.*.md is r1-powershell-static.2026-11-24T14-50.md (0 drift, 0 findings); no change.
