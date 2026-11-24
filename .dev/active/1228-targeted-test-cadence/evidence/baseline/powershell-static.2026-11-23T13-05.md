# Phase 0 PowerShell Static Baseline - Issue #1228 ([P0-T1])

Timestamp: 2026-11-23T13-05
Command: sh SCRATCH/issue-1228-pstatic.sh p0 (pwsh 7 script SCRATCH/issue-1228-pstatic.ps1 run at the item worktree root: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1`; `Invoke-PoshQCFormat -Root <worktree root>` with `git status --porcelain` captured before and after; `Invoke-PoshQCAnalyze -Root <worktree root>` (settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, the module default); `Invoke-PoshQCLeakScan -Root <worktree root>`; `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check`)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCFormat: EXIT_CODE 0; 1866 files visited, 0 files reformatted (finding count 0); `git status --porcelain` identical before and after the format step (True).
- Invoke-PoshQCAnalyze: EXIT_CODE 0; no exception thrown, which the function raises on any finding (finding count 0).
- Invoke-PoshQCLeakScan: EXIT_CODE 0; "Leak scan: 902 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures." (failure count 0). One warning: scan folder `tests/powershell` from `config/poshqc-scan.json` does not exist and is skipped.
- Invoke-HarnessGeneration.ps1 -Check: EXIT_CODE 0; "harness-generation: no drift" (finding count 0).
- Invoke-HarnessGeneration.ps1 -Surface instructions -Check: EXIT_CODE 0; "harness-generation: no drift" (finding count 0).

Run window: 2026-11-23T12-57 to 2026-11-23T13-04 (UTC).
