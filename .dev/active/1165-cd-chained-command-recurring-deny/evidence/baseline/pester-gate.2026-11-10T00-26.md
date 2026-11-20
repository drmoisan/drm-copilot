# Pester Phase 0 Baseline (issue #1165)

Timestamp: 2026-11-10T00-26
Command: sh SCRATCH/issue-1165-pester.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; $result = Invoke-PoshQCParallelTest -Root <item worktree root>; exit [int]$result.ExitCode). Counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1165-pesterstats.ps1.
EXIT_CODE: 0
Output Summary:
- Run state: after [P0-T4] created tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1 and before any edit to .claude/hooks/validate-bash.ps1 (unedited hook).
- Invoke-PoshQCParallelTest: workers=8; wall-clock=604.53s; returned ExitCode=0.
- Merged JUnit: tests=21277 passed=21267 failed=0 errors=0 skipped=10.
- validate-bash.CdChainGuidance.Tests.ps1: tests=60 passed=60 failures=0 (58 corpus rows plus the two constant pins). This is the pre-change corpus run required by AC-9.
- Repo-wide line coverage: 95.79% (covered=37491 missed=1646).
- .claude/hooks/validate-bash.ps1: 94.17% (covered=97 missed=6; missed lines are the entry-point tail).
- .claude/hooks/worktree-poetry-venv-policy.ps1: 100.00% (covered=117 missed=0).
- .codex/hooks/worktree-poetry-venv-policy.ps1: 100.00% (covered=117 missed=0).
