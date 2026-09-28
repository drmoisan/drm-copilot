# Remediation Inputs — cleanup-worktrees dirt classifier (Issue #632), cycle 3

- Timestamp: 2026-09-08T23-30 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `454bd523`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Blocking count: **2**
- Both findings are **NEW**. They open cycle 3; they do not reopen cycle 2.

## Source Artifacts

- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/policy-audit.2026-09-08T23-30.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/code-review.2026-09-08T23-30.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/feature-audit.2026-09-08T23-30.md`

## Cycle 2 exit status

| ID | Verdict | How established |
|---|---|---|
| N1 — rung 4 resolved `CONTENT_ON_MAIN` from an empty pathspec | **CLOSED** | Real-git confirmation of the premise and the fix semantics; three discrimination probes, including the true historical revert via `git show 02150524:…` |
| N2 site 1 — `find-object-hard-fail` | **CLOSED** | `s/((lrc != 0))/((0))/` fails `dirt_history_read_error` |
| N2 site 2 — `hash-object-hard-fail` | **CLOSED** | `s/((hrc != 0))/((0))/` fails two `dirt_classifier_read_error` tests |
| N2 site 3 — `rung4-tracked-hard-fail` | **CLOSED** | `s/((drc > 1))/((0))/` fails `dirt_tracked_probe_error_in_history` |
| N2 site 4 — `build-artifact-vacuous-confinement` | **CLOSED** | `s/((total == 0))/((0))/` fails `dirt_build_artifact_empty_diff` |
| Systemic criterion (AC-47 guard registry) | **Delivered as written; strength insufficient** | See N4 |

Coverage, toolchain, file size, mirror parity, evidence locations, and no-temp-files all pass. See
`policy-audit.2026-09-08T23-30.md`.

## Blocking Findings (2)

### N3 — rungs 4 and 5 resolve a disposable verdict without ever comparing the index blob

- Severity: **FAIL**. Data loss on `--clear-disposable`.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:303-320` (rung 4 tracked half),
  `:344-362` (rung 5).
- Problem: for a status entry whose X column is one of `M A R C` and whose Y column is not a space,
  content exists in both the index and the working tree. Rung 1 correctly declines such an entry
  (cycle 1's R1 fix, the Y-column gate at `:270`). The rungs it then falls to compare only
  working-tree content: rung 4 compares `main`'s tree to the working tree, and rung 5 hashes the
  working-tree file. Neither compares the index blob to anything. Rung 3 does read both sides
  (`dirt_is_build_artifact`, `:214-219`), which shows the pattern the lower rungs do not follow.
- Reachable status codes: `MM`, `AM`, `RM`, `CM`. `AD` is closed by the N1 fix and `MD` fails closed
  at the `hash-object` guard.
- Reproduction, from the checked-in `dirt_staged_tree_worktree_delta` fixture with only the rung-4
  and rung-5 answers changed and `diff-index.eeee7777.rc` set to 1 so the staged index matches no
  ancestor tree:

  - rung 4 variant (`diff-quiet..src_a.cs.rc` = 0, `rev-parse.verify.main_src_a.cs.rc` = 0):
    `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MM|src/a.cs`,
    `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|`, then `ACTION|dirt-clear|/repo-wt/dirt|OK` after
    `reset --hard` and `clean -fd` both returned 0.
  - rung 5 variant (`diff-quiet..src_a.cs.rc` = 1, `hash-object.src_a.cs.out` = `bbbb1111`,
    `log.find-object.bbbb1111.out` = `ffff3333`):
    `DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff3333|MM|src/a.cs`,
    `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`, then `ACTION|dirt-clear|/repo-wt/dirt|OK`.

- Realizable with ordinary git: on a feature branch that has not touched the file, `git add <file>`
  stages content D, then editing the working-tree copy back to `main`'s content yields porcelain
  `MM`. The X and Y columns answer independent questions, so `diff --quiet main -- <path>` exits 0
  while the index holds a blob that is in no commit.
- Required change: an entry that carries both an index delta and a working-tree delta must not
  resolve a disposable verdict on the strength of a working-tree comparison alone. The cheapest
  sound rule is to fail closed for `x` in `M A R C` with `y` not a space unless the index blob is
  also accounted for — for example by comparing `rev-parse ":$rel"` against `main:$rel` and against
  `log --find-object`.
- Required tests, both directions: one checked-in fixture carrying an `MM` entry whose working-tree
  content is on `main`, asserting the verdict is not `CONTENT_ON_MAIN` and the aggregate is not
  `ALL_DISPOSABLE`, plus a second entry in the same fixture that must still resolve
  `CONTENT_ON_MAIN`, so a fix that simply disables the rung fails. Add the rung-5 analogue with a
  blob present in history. Acceptance: deleting the new check must make at least one checked-in test
  fail.
- Note on file size: `cleanup_worktrees_dirt_lib.sh` is at 481 of the 500-line limit, leaving 19
  lines of headroom.

### N4 — the guard registry gate can be satisfied without exercising a guard

- Severity: **PARTIAL, blocking**, under the standing criterion "if the gate can still be satisfied
  without genuinely exercising a guard, that is a blocking finding".
- Location: `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:338-373` (the `EXEMPT` arm
  of Obligation 5 and Obligation 6's sibling rule).
- Problem: 20 of the 37 marker ids are not pinned by the third test, and all 20 are arithmetic-only.
  For any of them an executor may name a scenario in which the ladder never reaches the guard; both
  admissible constants are then unobservable on both channels, Obligation 6's sibling rule is
  satisfied vacuously, and the row passes as `EXEMPT`. Obligation 4 is no obstacle because it
  requires only that the *unmutated* run emit a `DIRTFILE|` record, not that the ladder reach the
  guard.
- Demonstrated: replacing the shipped `staged-probe-skip-head` row with
  `EXEMPT / dirt_unique / s/((first == 1))/((0))/` plus the fixed reason token leaves all three gate
  tests passing (`1..3, 3 ok`), even though the shipped registry proves that guard separable under
  `dirt_staged_tree_is_commit`.
- AC-47's text discloses this with the literal `EXEMPT is scenario-scoped`, so this is a limitation
  of the specified strength, not a false claim. The disclosure documents the hole; it does not close
  it.
- Required change, in order of preference: (a) require an `EXEMPT` row to demonstrate that the
  ladder reached the guard under its named scenario — for instance by asserting a specific argv
  invocation — which turns "never reached" from a way to pass into a way to fail; and (b) restate
  AC-47's floor so every marker id is pinned by kind, not 17 of 37.
- Second, larger issue behind N4: the registry gate detects a *dead guard*, not a *missing
  comparison*. The defect class that has recurred for three consecutive cycles — R1, N1, N3 — is a
  missing comparison, and the gate passes cleanly on a tree containing N3. Cycle 3's acceptance set
  should state the property over the inputs to a verdict: for every disposable verdict the ladder
  can emit, the git reads that produced it must account for every location holding the entry's
  content — working tree, index, and `HEAD` — with a checked-in scenario per (status-code class,
  verdict) pair that reaches a disposable verdict.

## Non-Blocking Findings

| ID | Title | Suggested action |
|---|---|---|
| P1 | `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% line coverage, zero changed lines on this branch | Separate issue; cycle 1's O4, still open |
| P2 | `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` cites `.gitignore:67`; observed is `.gitignore:68` | One-character correction; reasoning unaffected |
| P3 | `cleanup_worktrees_dirt_lib.sh` at 481/500 and `cleanup_worktrees_lib.sh` at 496/500 | Plan the N3 fix within 19 lines or extract; this is cycle 1's F7/F9 constraint |
| P4 | The registry's `GUARD_RE` predicate forces markers only onto arithmetic comparisons; a newly added `[[ ... ]]` verdict guard would not be pulled in automatically | AC-47 states this scope, so no defect against the criterion; fold into the N4 remediation |

## Carried Forward Unchanged

Cycle 1's O2, O3, and O5, and F7 through F14, retain the dispositions recorded in
`evidence/other/deferred-findings.2026-09-08T07-00.md`. AC-31 and AC-37 remain PARTIAL on
environmental grounds (denied tree-digest command; issue #510), both adjudicated as non-blocking in
`feature-audit.2026-09-08T23-30.md`.

## Acceptance-Criteria Reconciliation

All 47 criteria in `spec.md` are checked and all 47 are satisfied as written. Neither N3 nor N4 maps
to any existing criterion. No box should be unchecked by cycle 3; two criteria should be added, one
for the N3 property and one replacing or strengthening AC-47 per the recommendation above.

## CI Re-dispatch

The docs-only advance from `7d7a661f` to `454bd523` touches nothing under `scripts/`,
`.claude/lib/bash/`, or `tests/`, so it is not material to the shell-coverage gate. The N3
remediation will change the classifier library, which makes a re-dispatch necessary on its own
merits.

## Suggested Order of Work

1. N3 — the live data-loss path, with both directions pinned and the file-size constraint respected.
2. N4 — strengthen the `EXEMPT` obligation and the pin floor.
3. Add the two acceptance criteria and correct P2.
4. Restart the toolchain loop from stage 1 and re-dispatch `_shell-coverage.yml` at the new head.
