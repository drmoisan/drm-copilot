# PowerShell Final Static Loop (remediation cycle 1, P2-T1, post-main-merge re-run)

Timestamp: 2026-11-12T12-33
Command: sh SCRATCH/issue-1164-ps-static.sh (pwsh 7 running SCRATCH/issue-1164-ps-static.ps1 in the item worktree: git status --porcelain; Invoke-Formatter check-only comparison with scripts/powershell/PoshQC/settings/pssa.settings.psd1; git status --porcelain; Invoke-ScriptAnalyzer with the same settings; Invoke-PoshQCLeakScan -Root from the branch PoshQC.psd1) over the five P0-T1 files
EXIT_CODE: 0
Output Summary:
- Run on the post-main-merge head 01547c4c7 (plain merge of origin/main, PR #1168, after the remediation commit e2d42d831). The earlier P2-T1 artifact powershell-static.2026-11-11T06-48.md is unchanged; this re-run follows the plan's restart rule because the merge changed the tree.
- Step 1, format (check-only): exit 0; 0 of 5 files differ. Finding count 0.
- git status --porcelain before and after the format step: empty both times (clean tree), identical, so the format step changed no file.
- Step 2, PSScriptAnalyzer: exit 0; 0 findings in total (0 per file). Finding count 0.
- Step 3, Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 747 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." Finding count 0.
- Logical lines: BlastRadiusAccess.psm1 320, its mirror 320, ParallelAdmissionPrecedenceGate.psm1 160, BlastRadiusAccess.Tests.ps1 192, ParallelAdmissionPrecedenceGate.Tests.ps1 125; all at or below 500.
- Prior attempt of this loop (started 2026-11-12T12-33): Invoke-ScriptAnalyzer on ParallelAdmissionPrecedenceGate.psm1 stopped with "Object reference not set to an instance of an object" (launcher EXIT 1) after the format step and the first two files reported 0 findings; no file changed. The loop was re-run from step 1 as recorded above.
- Phase 0 comparison (evidence/remediation-baseline/powershell-static.2026-11-11T05-48.md): 0 findings then and now.
