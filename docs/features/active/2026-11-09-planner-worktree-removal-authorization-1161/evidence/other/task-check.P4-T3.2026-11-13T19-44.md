# Task Check - P4-T3 coverage fix for the Codex gate body

Timestamp: 2026-11-13T19-44
Command: sh SCRATCH/issue-1161-tc-fix3.sh (Invoke-Formatter and Invoke-ScriptAnalyzer on the edited suite; New-PesterConfiguration with Run.Path set to the selection and PassThru)
EXIT_CODE: 0
Output Summary: format drift 0, PSScriptAnalyzer 0; Pester selection 570 tests, 570 passed, 0 failed. This is a task check, not a gate; it measures no coverage. The P4-T3 gate is re-run from the start of the QA loop.

## Finding from the second gate attempt (not the P4-T3 artifact)

Command: sh SCRATCH/issue-1161-pester-gate.sh (one Invoke-PoshQCParallelTest run, started 2026-11-13T19-24)
EXIT_CODE: 0
Result: 8 workers, wall clock 925.05 s; merged JUnit 22678 tests, 0 failures, 0 errors, 10 disabled; repo-wide line coverage 95.85% (38939/40624).

Per-file line coverage against the Phase 0 baseline (`evidence/baseline/pester-gate.2026-11-10T04-07.md`):

| File | Baseline | This run |
| --- | --- | --- |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 94.92% (112/118) | 95.24% (120/126) |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 95.58% (108/113) | 95.93% (118/123) |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.73% (78/79) | 97.70% (85/87) |

The Codex gate fell below its baseline, which the P4-T3 acceptance (no drop) does not allow. The uncovered lines in the coverage report are in the script body: the planner checkpoint read `Get-Content -Raw -LiteralPath $plannerPath` and the target-checkpoint reader script block, both added by P2-T6. The existing entry-point rows run the body with no planner checkpoint, so neither line executed.

## Fix

`tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` gains the row `reads the planner, epic, and target checkpoints through the entry point and appends the planner refusal (issue #1161)`. Path-filtered mocks of Test-Path and Get-Content supply in-memory texts for the epic checkpoint, the planner checkpoint, and the target's orchestrator checkpoint (`next_step` S6_review); the git seam returns a listing that names the synthetic target on branch feature/alpha-1. The row asserts exit 0, an `EPIC_WORKTREE_REMOVAL_BLOCKED` deny carrying `Planner worktree: PLANNER_WORKTREE_IN_USE: U4`, and exactly one Get-Content call each for the planner checkpoint and the target checkpoint. No file is read or written and no git process starts; the row's outcome does not depend on gitignored state, as the suite's .DESCRIPTION requires of entry-point rows.

## Selection and rule

Rule (Test Cadence): the edited suite and the test that enumerates it (the discovery guard).

| Step | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| Format and analyze | Invoke-Formatter, Invoke-ScriptAnalyzer on the edited suite | 0 | drift 0, findings 0 |
| Pester | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 0 | 570 passed, 0 failed |
