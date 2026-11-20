# Remediation cycle 1 final PowerShell static QC (P2-T1)

Timestamp: 2026-11-09T17-43
Command: sh SCRATCH/issue-1153-static.sh (Invoke-Formatter check-only and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, PSScriptAnalyzer 1.25.0, over every *.ps1 under .claude/skills/epic-progress-report/scripts and tests/scripts/claude-skills/epic-progress-report); then sh SCRATCH/issue-1153-leak.sh (branch-current scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>); then sh SCRATCH/run-ps.sh SCRATCH/issue-1153-lines.ps1 (physical line counts with @(Get-Content -LiteralPath <path>).Count)
EXIT_CODE: 0
Output Summary:
  Step 1 format check: exit 0; 29 files examined (28 at the P0-T1 baseline plus Get-EpicProgressReport.CriticalPath.ps1); 0 files would change.
  Step 2 analyze: exit 0; 0 findings. (A debugging run during P1-T5 reported one PSUseOutputTypeCorrectly finding on Select-EpicProgressRetainedPauseSpan; it was fixed in P1-T5 before that task's commit.)
  Step 3 leak scan: exit 0; 739 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (same figures as the main final gate). The scan printed the existing warning that the configured folder tests/powershell does not exist.
  Line counts, P1-T1 script files: Get-EpicProgressReport.Schedule.ps1 494 (783 at P0-T1); Get-EpicProgressReport.CriticalPath.ps1 308; both below 500.
  Other changed files: Get-EpicProgressReport.Velocity.ps1 358; Get-EpicProgressReport.State.ps1 470; SKILL.md 499.
  Edited test files: EpicProgressReport.SkillContract.Tests.ps1 338; Get-EpicProgressReport.CriticalPath.Tests.ps1 403; Get-EpicProgressReport.ItemMode.Tests.ps1 261; Get-EpicProgressReport.Schedule.Range.Tests.ps1 252; Get-EpicProgressReport.Schedule.Tests.ps1 391; Get-EpicProgressReport.State.V3.Tests.ps1 182; Get-EpicProgressReport.Tests.ps1 699; Get-EpicProgressReport.Velocity.Tests.ps1 393.
  No edited file exceeds 800 lines.
