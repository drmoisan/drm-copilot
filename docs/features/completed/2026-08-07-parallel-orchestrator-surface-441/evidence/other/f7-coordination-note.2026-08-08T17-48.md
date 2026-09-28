# F7 Coordination Note (P5-T3)

Timestamp: 2026-08-08T17-48

Task: [P5-T3] Mirror the plan-level `## F7 Coordination Note (carry forward to the F7 planner)`
into canonical evidence so the note survives independently of the plan file.

Source: `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md`,
section `## F7 Coordination Note (carry forward to the F7 planner)`.

## F7 Coordination Note (carry forward to the F7 planner)

Per spec `## Cross-Feature Dependencies` and research E.4, the F5-delivered surface is not
executable end-to-end until F7 lands. The F7 planner must scope both existing epic hooks for
the parallel case, in addition to the §9 F7 deliverables:

1. `.claude/hooks/enforce-epic-merge-gate.ps1` (registered at `.claude/settings.json:112`)
   denies any `gh pr merge --merge` without an epic-shaped checkpoint
   (`EPIC_MERGE_GATE_BLOCKED`). The parallel parent's per-item merge (spec R2.8 step 3) is
   denied until F7 extends or scopes the gate's allow conditions.
2. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (registered at
   `.claude/settings.json:116`) denies any `git worktree remove` without a matching epic
   checkpoint record (`EPIC_WORKTREE_REMOVAL_BLOCKED`). Because `PreToolUse` denials are
   conjunctive, F7's new `enforce-parallel-worktree-removal-gate.ps1` alone cannot override
   this deny; F7 must also coordinate the epic gate's conditions.

F5 modifies neither hook nor `.claude/settings.json`. The delivered skill text states this
dependency, naming both hooks and both block reasons (P2-T8, P2-T10, verified in P2-T15).

## Hook and Block-Reason Index

| Hook script | Block reason | Denied operation | F5 dependency point |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `EPIC_MERGE_GATE_BLOCKED` | `gh pr merge --merge` | Per-item merge-on-green, spec R2.8 step 3, documented in `.claude/skills/parallel-orchestrate/SKILL.md` section `## Per-Item Merge to Main (Merge-on-Green)` |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `EPIC_WORKTREE_REMOVAL_BLOCKED` | `git worktree remove` | Post-merge worktree cleanup, spec R2.10, documented in `.claude/skills/parallel-orchestrate/SKILL.md` section `## Worktree Cleanup` |

## Verification of Delivered-Surface Coverage

Both block reasons are named in the delivered skill text and both are asserted by the contract
tests. The presence assertions live in
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (added at P4-T4) and
passed at P4-T8; the heading-and-literal scan at P2-T15 check (c) confirmed the same two
literals. F5 itself changes no hook and no settings file, as independently verified by P5-T2
(`evidence/other/no-hook-or-settings-change.2026-08-08T17-47.md`).

## Carry-Forward Instruction

The F7 planner must treat both rows of the index above as in-scope coordination work. Scoping
only the new parallel gates is insufficient: because `PreToolUse` denials are conjunctive, an
unmodified epic gate continues to deny the parallel parent's merge and worktree-removal
operations even after F7's own parallel gates are authored and registered.
