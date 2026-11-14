# QA Gate: Coverage Delta (Issue #1010, P5-T4)

Timestamp: 2026-10-30T21-09
Command: git diff -U0 --merge-base origin/main -- <four edited production files> > SCRATCH/issue-1010-prod.diff; sh SCRATCH/issue-1010-run.sh issue-1010-delta.ps1 -DiffFile SCRATCH/issue-1010-prod.diff -CoverageFile SCRATCH/issue-1010-coverage-p5t3.xml (the P5-T3 powershell-coverage.xml; changed lines are the new-side line numbers of the merge-base diff hunks, intersected with the measured lines of the coverage file)
EXIT_CODE: 0
Output Summary: Every file is at or above its 85% line threshold after the change. Changed-line coverage: Claude gate 100% (1 of 1), Claude -epic-scope 91.67% (33 of 36), Codex gate 100% (4 of 4), Codex -epic-scope 94.64% (53 of 56). The only uncovered changed lines are the three body lines of the always-mocked worktree-list wrapper Get-OrchestrationGateWorktreeList in each -epic-scope file. No other changed-line shortfall.

| File | Baseline (P0-T7) | Post-change (P5-T3) | Changed-line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 93.08% | 93.08% | 100.00% (1 of 1 measurable changed lines) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 98.53% | 96.74% | 91.67% (33 of 36) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 88.30% | 88.17% | 100.00% (4 of 4) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 98.18% | 96.40% | 94.64% (53 of 56) |

## Uncovered Changed Lines

- Claude `-epic-scope`: the body of `Get-OrchestrationGateWorktreeList` (the listing call, the non-zero-exit return, and the join). The wrapper is always mocked by design (Pre-Mortem, Coverage bullet), so no test starts git.
- Codex `-epic-scope`: the same three body lines of `Get-OrchestrationGateWorktreeList`.

## Whole-File Movement

- The Claude and Codex `-epic-scope` percentages fall by 1.79 and 1.78 points because three always-mocked wrapper lines were added to each file; every other added line is covered.
- The Codex gate falls from 88.30% to 88.17% because two covered lines (the removed parameterless `Get-CheckpointContent` body) left the file; the 20 uncovered lines are pre-existing lines of the entry tail and are unchanged by this plan.

Verdict: no changed-line regression other than the named wrapper body; the plan is not remediation-required on coverage.
