# Final PowerShell static QC (P6-T1)

Timestamp: 2026-11-09T16-36
Command: sh SCRATCH/issue-1153-static.sh (pwsh 7.6.9; PSScriptAnalyzer 1.25.0; for every *.ps1 under .claude/skills/epic-progress-report/scripts and tests/scripts/claude-skills/epic-progress-report: Invoke-Formatter -ScriptDefinition <LF-normalized content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the content, no file written; then Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1); then sh SCRATCH/issue-1153-leak.sh (Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
  Final pass (recorded values):
  Step 1 format check (Invoke-Formatter, check-only): exit 0; 28 files examined; 0 files would change.
  Step 2 analyze (Invoke-ScriptAnalyzer, repo settings): exit 0; 0 findings.
  Step 3 leak scan (Invoke-PoshQCLeakScan -Root): exit 0; 739 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.
  First pass (restarted after fixes): format exit 1 with 2 files that would change (Get-EpicProgressReport.Render.ps1, Get-EpicProgressReport.Render.Tests.ps1; hashtable alignment only, whitespace-only diff); analyze 26 findings (PSAlignAssignmentStatement 25 in the same two files; PSUseDeclaredVarsMoreThanAssignments 1 for savedExitCode in Get-EpicProgressReport.CriticalPath.Tests.ps1). Fixes: Invoke-Formatter applied to the two files, savedExitCode moved to script scope in the forwarder Context, and the Render.ps1 bundle copy refreshed; every skill-folder file is byte-identical with its bundle copy (cmp, no difference).
  The check-only steps wrote no file: git status --porcelain was byte-identical before and after the first pass.
