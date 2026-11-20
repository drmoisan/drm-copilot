# PowerShell Final Static Loop, Post-Merge (P6-T2 re-run after merge commit 25dcbcdc2)

Timestamp: 2026-11-10T03-52
Command: sh SCRATCH/issue-1164-ps-static.sh (pwsh: git status --porcelain; Invoke-Formatter check-only comparison with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer with the same settings; git status --porcelain; Invoke-PoshQCLeakScan -Root from the branch PoshQC.psd1) over the 21 .ps1/.psm1 files of the merge-base diff of origin/main and HEAD (7 production files under .claude/lib, their 7 bundle mirrors, and 7 test files under tests/scripts)
EXIT_CODE: 0
Output Summary:
- Step 1, format (check-only, Invoke-Formatter output compared with file text): exit 0; 0 of 21 files differ. Finding count 0. git status --porcelain before and after the static steps: 0 lines each, identical, so the formatter changed no file.
- Step 2, PSScriptAnalyzer: exit 0; pssa_findings=0. Finding count 0.
- Step 3, Invoke-PoshQCLeakScan -Root: exit 0; "Leak scan: 746 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures." Finding count 0 failures (pre-merge final: 744 files, 0 failures; the two added files are the main-side test suites of PR #1166).
- Phase 0 baseline comparison (evidence/baseline/powershell-static.2026-11-09T23-21.md): 0 findings then and now. No regression.
