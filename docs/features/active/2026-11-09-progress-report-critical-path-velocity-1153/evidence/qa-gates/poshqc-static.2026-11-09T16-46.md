# Final PowerShell static QC, re-run after the P6-T3 coverage test (P6-T1)

Timestamp: 2026-11-09T16-46
Command: sh SCRATCH/issue-1153-static.sh (Invoke-Formatter check-only and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over every *.ps1 under .claude/skills/epic-progress-report/scripts and tests/scripts/claude-skills/epic-progress-report); then sh SCRATCH/issue-1153-leak.sh (branch-current PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
  Re-run because P6-T3 found Get-EpicProgressReport.State.ps1 below its Phase 0 figure and a test case was added to Get-EpicProgressReport.State.V3.Tests.ps1 (`writes the features of a sample given as an object, sorted by issue`).
  Step 1 format check: exit 0; 28 files examined; 0 files would change.
  Step 2 analyze: exit 0; 0 findings.
  Step 3 leak scan: exit 0; 739 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.
