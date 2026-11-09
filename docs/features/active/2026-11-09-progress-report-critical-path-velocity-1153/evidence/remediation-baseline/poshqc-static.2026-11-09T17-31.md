# Remediation cycle 1 PowerShell static baseline (P0-T1)

Timestamp: 2026-11-09T17-30
Command: sh SCRATCH/issue-1153-static.sh (Invoke-Formatter check-only comparison, no file written, and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, PSScriptAnalyzer 1.25.0, over every *.ps1 under .claude/skills/epic-progress-report/scripts and tests/scripts/claude-skills/epic-progress-report); then sh SCRATCH/run-ps.sh SCRATCH/issue-1153-lines.ps1 (physical line counts with @(Get-Content -LiteralPath <path>).Count); git status --porcelain captured before and after
EXIT_CODE: 0
Output Summary:
  Head: the remediation-plan preflight commit on feature/progress-report-critical-path.
  Step 1 format check: exit 0; 28 files examined; 0 files would change.
  Step 2 analyze: exit 0; 0 findings (no rule reported).
  Line counts: Get-EpicProgressReport.Schedule.ps1 783; SKILL.md 497; Get-EpicProgressReport.Tests.ps1 698.
  Other line counts read in the same run: Velocity.ps1 307; State.ps1 467; Get-EpicProgressReport.CriticalPath.ps1 absent (created in P1-T1).
  git status --porcelain: empty before and after the run (unchanged).
  Test-suite comparison references (no new run in Phase 0): evidence/baseline/pester.2026-11-09T15-50.md and evidence/baseline/pytest.2026-11-09T15-44.md (Phase 0 baseline); evidence/qa-gates/pester.2026-11-09T16-54.md, coverage-comparison.2026-11-09T16-54.md, and pytest.2026-11-09T16-59.md (main final gate).
