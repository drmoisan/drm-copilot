# Final QC - PowerShell Static - Issue #1228 ([P2-T1])

Timestamp: 2026-11-24T06-02
Command: `sh SCRATCH/issue-1228-pstatic.sh q1` (pwsh 7 at the item worktree root: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1`; `Invoke-PoshQCFormat -Root <worktree root>` with `git status --porcelain` captured before and after; `Invoke-PoshQCAnalyze -Root <worktree root>` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`; `Invoke-PoshQCLeakScan -Root <worktree root>`; `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; the same with `-Surface instructions -Check`), launched from `artifacts/issue-1228/qa.sh q1`; then `pwsh -NoProfile -File <item worktree>/artifacts/issue-1228/issue-1228-psfile.ps1 -Root <item worktree> -File <file>` (Invoke-Formatter comparison and Invoke-ScriptAnalyzer) for each of the two edited test files
EXIT_CODE: 0
Output Summary:
- Format (`Invoke-PoshQCFormat`): EXIT_CODE 0; 1879 files visited, 0 reformatted (finding count 0); `git status --porcelain` identical before and after the format step (True). [P0-T1]: 1866 files, 0 reformatted.
- Analyze (`Invoke-PoshQCAnalyze`, repository-wide): EXIT_CODE 0; no exception (the function throws on any finding), finding count 0, not above [P0-T1] (0).
- Leak scan: EXIT_CODE 0; "Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures." (failure count 0; [P0-T1]: 902 files, 0 failures; the file count difference comes from the test files the `origin/main` merge added and is not a change of this item).
- `Invoke-HarnessGeneration.ps1 -Check`: EXIT_CODE 0, "harness-generation: no drift" (AC-11). `-Surface instructions -Check`: EXIT_CODE 0, "harness-generation: no drift" (AC-11).
- The two edited test files: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` format drift 0, analyzer findings 0, 629 lines; `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` format drift 0, analyzer findings 0, 350 lines (checked in a second call, because `pwsh -File` binds one value to the helper's `-File` parameter).
- Run window 2026-11-24T05-56 to 06-02 (UTC). Result: PASS.
