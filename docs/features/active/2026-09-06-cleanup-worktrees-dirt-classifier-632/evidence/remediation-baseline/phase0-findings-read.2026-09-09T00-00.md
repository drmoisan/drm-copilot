# Phase 0 findings read — remediation cycle 3

Timestamp: 2026-09-09T00-00

Task: [P0-T2]

Command: `cat` / `sed -n` / `grep -n` over the four cycle-3 finding documents in
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/`:

1. `remediation-inputs.2026-09-08T23-30.md`
2. `code-review.2026-09-08T23-30.md`
3. `feature-audit.2026-09-08T23-30.md`
4. `policy-audit.2026-09-08T23-30.md`

EXIT_CODE: 0

## N3 — rungs 4 and 5 resolve a disposable verdict without ever comparing the index blob

- File named by the finding: `scripts/bash/cleanup_worktrees_dirt_lib.sh`
- Line ranges named by the finding: `303-320` (rung 4, tracked half) and `344-362` (rung 5).
- Severity: FAIL. Data loss on `--clear-disposable`.
- Cited identically in `remediation-inputs.2026-09-08T23-30.md:38-39`,
  `code-review.2026-09-08T23-30.md` Part 4 and its summary table, and
  `policy-audit.2026-09-08T23-30.md:216-217`.
- Statement: for a porcelain entry whose X column is content-bearing and whose Y column is
  also content-bearing, content exists in the index and in the working tree as two distinct
  blobs. Rung 4's tracked half compares `main` to the working tree and rung 5 hashes the
  working-tree file; neither reads the index blob. An entry whose working-tree copy matches
  `main` therefore resolves `CONTENT_ON_MAIN` (or `CONTENT_IN_HISTORY` at rung 5), the
  worktree aggregates `ALL_DISPOSABLE`, and `reset --hard` drops the index entry, making the
  staged blob unreachable.
- Reachable status codes named by the finding: `MM`, `AM`, `RM`, `CM`. `AD` is closed by the
  cycle-2 N1 fix and `MD` fails closed at the `hash-object` guard.

## N4 — the guard registry gate can be satisfied without exercising a guard

- File named by the finding: `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
- Line range named by the finding: `338-373` (the `EXEMPT` arm of Obligation 5 and
  Obligation 6's sibling rule).
- Severity: PARTIAL, blocking.
- Cited identically in `remediation-inputs.2026-09-08T23-30.md:66-67`,
  `code-review.2026-09-08T23-30.md` summary table, and
  `policy-audit.2026-09-08T23-30.md:230`.
- Statement: 20 of the 37 marker ids are not pinned by the third test and all 20 are
  arithmetic-only. For any of them a scenario can be named under which the ladder never
  reaches the guard; both admissible constants are then unobservable on both channels and
  the row passes as `EXEMPT`. Demonstrated in the code review by replacing the shipped
  `staged-probe-skip-head` row and observing `1..3, 3 ok`.

## Non-blocking findings carried into this cycle's scope

- P2: `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` cites `.gitignore:67`; the
  observed rule is at `.gitignore:68` (`policy-audit.2026-09-08T23-30.md:166`, `:175`,
  `:248`). Remediated in Phase 4 of the cycle-3 plan.
- P4: the registry's `GUARD_RE` predicate compels markers only onto arithmetic comparisons,
  so a newly added `[[ ... ]]` verdict guard is not picked up automatically
  (`remediation-inputs.2026-09-08T23-30.md` non-blocking table). Remediated in P2-T5 by
  registering the one non-arithmetic guard this cycle adds in the suite's literal list.

Output Summary: the four cycle-3 finding documents were read. Both blocking findings and
their file/line citations are recorded above. N3 names
`scripts/bash/cleanup_worktrees_dirt_lib.sh` at `303-320` and `344-362`; N4 names
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` at `338-373`. Blocking count
is 2; both are new and both open cycle 3 rather than reopening cycle 2.
