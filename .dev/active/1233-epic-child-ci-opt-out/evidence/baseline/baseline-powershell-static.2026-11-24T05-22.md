# Baseline: PowerShell static (P0-T1)

Timestamp: 2026-11-24T05-22
Command: pwsh -NoProfile -File SCRATCH/issue-1233-ps-static-runtime.ps1 -Root <item worktree> (through SCRATCH/issue-1233-ps-static.sh): Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> -WriteFile { no-op } -Logger { collect }; Invoke-PoshQCAnalyze -Root <worktree> (settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, the module default); Invoke-PoshQCLeakScan -Root <worktree>
EXIT_CODE: 0
Output Summary:
- Format (Invoke-PoshQCFormat with the non-writing -WriteFile seam; the module has no check mode): exit 0; 0 "Formatted:" lines (drift count 0); 1879 "Already formatted:" lines.
- PSScriptAnalyzer (Invoke-PoshQCAnalyze, pssa.settings.psd1): exit 0; "PSScriptAnalyzer passed: no findings" (finding count 0).
- Invoke-PoshQCLeakScan: exit 0; "Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures." (failure count 0).
- No file rewritten: `git status --porcelain` was empty before the run; after the run it lists only this item's own plan check-offs and evidence files written by the executor in parallel (`.dev/active/1233-epic-child-ci-opt-out/plan.2026-11-23T22-42.md`, `.dev/active/1233-epic-child-ci-opt-out/evidence/baseline/`), no PowerShell file.
