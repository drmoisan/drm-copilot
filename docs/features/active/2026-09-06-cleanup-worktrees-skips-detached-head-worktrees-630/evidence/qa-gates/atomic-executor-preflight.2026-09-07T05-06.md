# Atomic-Executor Preflight Clearance — Issue #630

Timestamp: 2026-09-07T05-06
Command: Agent(atomic-executor, model=opus) with `DIRECTIVE: PREFLIGHT VALIDATION ONLY` against `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md` (round 4, confirming)
EXIT_CODE: 0

PREFLIGHT: ALL CLEAR

CONVERGENCE: NO FURTHER ROUNDS EXPECTED

Output Summary: Round 4 cleared the plan after four preflight rounds. The reviewer independently
re-derived that the `scenarios/detached_unmerged` fixture yields exactly the record the round-3
correction asserts, confirmed the fail-before condition holds for every Phase 2 `[expect-fail]`
task, and confirmed the suite-level gate is satisfiable. Two non-blocking observations were
recorded rather than left silent; neither blocks execution.

## Context

- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`
- Plan path: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md`
- Work mode: `full-bug`. Sole acceptance-criteria source: `spec.md`, AC1 through AC24, all unchecked.
- Branch: `bug/cleanup-worktrees-skips-detached-head-worktrees-630`, based on
  `origin/epic/cleanup-merged-worktrees-hardening-integration`.
- Epic: child A of `cleanup-merged-worktrees-hardening`, covering gaps 1 and 6.
- Plan structure at clearance: eight phases, 77 tasks, all unchecked. Execution begins at `[P0-T1]`.

## Validator gate

`mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "plan"` was run against the
plan path after every revision round. The final call returned `ok: true` with no `warnings` field, so
no `PLAN GATE WARNING:` entry was raised by rules G1 through G9.

## Preflight round history

| Round | Signal | Convergence | Defects | Blocking |
|---|---|---|---|---|
| 1 | REVISIONS REQUIRED | FURTHER ROUNDS LIKELY | 15 (D1-D15) | 6 |
| 2 | REVISIONS REQUIRED | NO FURTHER ROUNDS EXPECTED | 11 (B1-B4, N1-N7) | 4 |
| 3 | REVISIONS REQUIRED | NO FURTHER ROUNDS EXPECTED | 5 (B5, N8-N11) | 1 |
| 4 | ALL CLEAR | NO FURTHER ROUNDS EXPECTED | 0 | 0 |

The `atomic-plan-contract` two-round figure is a target rather than a cap. Rounds 3 and 4 were run
because rounds 2 and 3 each reported acceptance conditions that could not fail or could not be
satisfied; clearing at round 2 would have approved gates that verify nothing.

## Defect classes closed

- **Conditions that could not fail.** Three `[expect-fail]` tasks asserted conditions already true
  against the pre-change tree, one of them a literal already asserted green in two existing suites.
- **Conditions that could not be satisfied.** Eight fixture-creation gates counted paths from a
  `git status --porcelain` invocation that collapses a wholly-untracked directory to one entry; four
  unit assertions demanded `$output` equality from cases that retain a stderr argv log; one gate
  demanded an empty porcelain listing at a point where the feature has necessarily modified tracked
  files.
- **Ordering and satisfiability.** Three Phase 3 acceptance conditions named driver-level cases that
  only reach the new code after the Phase 4 wiring lands.
- **Stale citations.** Four `path:line` citations resolved to a different construct than claimed,
  three of them propagated from the research artifact into `spec.md` and the plan.
- **Sibling invalidation, twice.** The round-2 `&&`-joined source-chain correction made a task fail
  only if it carried a positive assertion, leaving a negatives-only task still passing; and the
  `setup()` insertions in two tasks shifted the line numbers those same tasks pinned.

## Documented non-blocking residuals

Recorded here so the clearance is not an approval by silence. Neither blocks execution.

1. `spec.md` retains the phrase "the listing is non-empty by construction" in the `## Verification`
   `format` paragraph and the AC24 parenthetical, which the plan removed from `[P7-T1]`. The claim is
   true as the plan is scheduled, because no task commits before Phase 7, and no acceptance condition
   depends on it: `[P7-T1]` requires the summary to state byte-identity, not non-emptiness. The plan's
   wording is the form that survives a per-phase commit.
2. `[P7-T1]`'s restart branch names a narrower remedy than the observation it guards: `check` output
   can be non-empty from `shfmt -d` drift, which "run `format` and restart" repairs, or from a
   `shellcheck` finding, which it does not. The Phase 7 preamble's general restart rule and
   `.claude/rules/shell.md` already require fixing the finding and restarting, so the task text is
   terse rather than defective.

## Execution-phase condition

The preparation orchestrator could not invoke WSL from its worktree-isolated context: the isolation
guard refuses the `wsl` invocation outright. No bash toolchain command was run during preparation,
and no baseline was captured. The plan names the exact WSL command form and `[P0-T4]` requires the
executor to verify reachability and stop with a blocking report if it is refused.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
- Total AC items: 24
- Checked off (delivered): 0
- Remaining (unchecked): 24
- Items remaining: AC1 through AC24. This was preparation only; no acceptance criterion was delivered
  or verified, and none was modified except to correct three unsatisfiable verification clauses
  (AC14, AC16, AC18) and one unsatisfiable observation clause (AC24).
