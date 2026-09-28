# Remediation Inputs — cleanup-worktrees dirt classifier (Issue #632), cycle 2

- Timestamp: 2026-09-08T06-51 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `ed84aac2`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Blocking count: **2**

## Source Artifacts

- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/policy-audit.2026-09-08T06-51.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/code-review.2026-09-08T06-51.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/feature-audit.2026-09-08T06-51.md`

## Cycle 1 exit status

All six cycle-1 blocking findings are verified closed against the current tree, by
reproduction and by re-applying the pre-fix form to a scratch copy of the library:

| ID | Verdict |
|---|---|
| R1 — rung 1 ignored the porcelain Y column | Closed |
| R2 — unconditional ` -> ` split | Closed |
| R3 — classifier library below the line threshold | Closed (94.05%, verified from the CI Cobertura artifact) |
| R4 — `STAGED_TREE_IS_COMMIT` pinned in one direction | Closed (five directions, all discriminating) |
| R5 — content-blind diff header filter | Closed |
| R6a — undocumented report-mode exit-code change | Closed |
| R6b — `DISPOSABLE_SESSION_ARTIFACT` unreachable | Closed |

## Blocking Findings (2)

### N1 — rung 4 resolves `CONTENT_ON_MAIN` from a pathspec that matched nothing

- Severity: **FAIL**. Data loss on the feature's own destructive flag.
- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`.
- Problem: `git diff --quiet main -- "$rel"` exits 0 both when the compared content is
  identical and when the pathspec selects no paths. Rung 4's tracked half reads exit 0 as
  the former unconditionally. Rung 3 guards against the identical inference at line 213;
  rung 4 does not.
- Reachable status code: `AD` — a file added to the index and then removed from the working
  tree. Its content exists only as a staged blob, in no commit and not on disk.
- Verified against real git 2.53.0.windows.1 in a scratch repository:
  `git diff --quiet main -- <path absent from worktree and main>` exits 0;
  `git status --porcelain` reports `AD staged_only.md`;
  `git hash-object -- staged_only.md` exits 128.
- Reproduced end to end using only those observed exit codes:
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||AD|staged_only.md`,
  `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|`, then
  `ACTION|dirt-clear|/repo-wt/dirt|OK` — emitted only after `reset --hard` and `clean -fd`
  both returned 0.
- Not a regression from the R1 fix: a control run with the Y-column gate reverted labels the
  same entry `STAGED_TREE_IS_COMMIT|eeee7777` and still aggregates `ALL_DISPOSABLE`.
- Required change: condition rung 4's positive answer on the path existing. Probe
  `ls-files --error-unmatch -- "$rel"`, or test the working-tree file's presence, before
  trusting exit 0. An exit 0 over an empty pathspec must advance the ladder, which routes
  the entry through the `hash-object` guard to `UNIQUE`.
- Required tests, both directions: a fixture with `AD <path>`,
  `diff-quiet..<path>.rc` of 0 and `hash-object.<path>.rc` of 128, asserting the verdict is
  not `CONTENT_ON_MAIN` and the aggregate is not `ALL_DISPOSABLE`; and a tracked entry
  whose content genuinely equals main's, asserting rung 4 still fires.

### N2 — four safety guards that no checked-in fixture can distinguish from their absence

- Severity: **FAIL** against the standing both-directions obligation and the Scenario
  Completeness clause of `.claude/rules/general-unit-test.md`.
- Locations: `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`,
  `:336-339`.
- Problem: each guard is covered by the coverage report and named by a passing test, but
  removing it leaves every checked-in `dirt_*` scenario byte-identical. The tests hold
  nothing. The mechanism is the same in all four cases: the fixture supplies a non-zero exit
  code and no stdout, so a weaker condition downstream reaches the same verdict.

| Line | Guard | Scenario | Verdict with the guard removed, under a fixture that separates them |
|---|---|---|---|
| 336-339 | `((lrc != 0))` after `log --find-object` | `dirt_history_read_error` | `CONTENT_IN_HISTORY\|ffff8888` + `ALL_DISPOSABLE` |
| 311-314 | the `((hrc != 0))` clause of the `hash-object` guard | `dirt_classifier_read_error` | `CONTENT_ON_MAIN` + `ALL_DISPOSABLE` |
| 301-304 | `((drc > 1))` in rung 4's tracked half | `dirt_tracked_read_errors` | `CONTENT_IN_HISTORY` + `ALL_DISPOSABLE` |
| 213 | `((total == 0)) && return 1` | none | `DISPOSABLE_BUILD_ARTIFACT` + `ALL_DISPOSABLE` where the baseline is `UNIQUE`/`HAS_UNIQUE` |

- Line 213 is the sharpest case: the library header devotes a paragraph to it as a safety
  property, and no checked-in scenario exercises a `*.csproj` entry whose worktree and
  cached diffs are both empty and both succeed.
- Required change: four fixtures. Three are one added `.out` file on an existing scenario
  directory so the failing read carries stdout as well as a non-zero exit; the fourth is an
  existing csproj scenario with both diff payloads emptied and the lower rungs set to miss.
  Each needs one assertion on the resulting verdict and one on the aggregate.
- Acceptance test for the remediation: for each of the four, deleting the guard must make at
  least one checked-in test fail.

## Non-Blocking Findings

| ID | Title | Suggested action |
|---|---|---|
| O1 | AC-8's text says "the **ten** `dirt_*` scenarios"; there are 25, and the test enforces 25 with an on-disk count assertion | One-word correction to the criterion text |
| O2 | The `any_staged` pre-scan issues the bounded probe for a worktree whose only staged entries have a non-space Y column, producing a result no entry consumes. Verified to cause no wrong verdict | Optional: gate the pre-scan on the Y column too, or leave as documented cost |
| O3 | The ` -> ` split gate reads the X column only. Probed across four rename shapes against git 2.53.0 and no `[ M]R` porcelain output was reproducible; an unstaged rename is reported ` D` plus `??` | No action. Recorded as checked |
| O4 | `.claude/lib/bash/compute-concurrency-batches.sh` is at 81.82% line coverage, below the 85% floor, with zero changed lines on this branch | Separate issue; out of this feature's remit |
| O5 | `dirt_build_artifact_added_file` asserts the build-artifact class over a wholly added csproj, which can only fire for a project file consisting solely of `HintPath` lines | No action; noted so the fixture's limited reach is on record |

## Carried Forward Unchanged

F7 through F13 and F14's documentation half remain deferred with the dispositions in
`evidence/other/deferred-findings.2026-09-08T07-00.md`. F7 and F9 remain blocked by
`cleanup_worktrees_lib.sh` at 496 of 500 lines, re-measured at `HEAD`. The ten residual
uncovered lines in the classifier library are confirmed unclosable and none is a fail-closed
branch.

## Acceptance-Criteria Reconciliation

All 45 criteria are checked and all 45 are satisfied as written; no box should be unchecked
by this cycle. AC-8 needs a text correction (O1), not an unchecking.

Neither N1 nor N2 maps to any existing criterion. This is the second consecutive cycle in
which a data-loss defect passed the whole acceptance set. Cycle 2 should add one criterion
covering the general property rather than another instance-specific pair:

> No rung resolves a disposable verdict from a probe whose result does not establish one.
> For every fail-closed guard and every non-empty guard in
> `scripts/bash/cleanup_worktrees_dirt_lib.sh`, a checked-in scenario exists in which
> deleting that guard changes the emitted `DIRTSUM|` aggregate.

That criterion would have caught R1, R2, R5, N1, and all four sites in N2.

## Suggested Order of Work

1. N1 — the live data-loss path, with both its pins.
2. N2 — the four discriminating fixtures. Three are one file each; do them together.
3. Add the general acceptance criterion above and the AC-8 text correction (O1).
4. Restart the toolchain loop from stage 1, re-dispatch the coverage workflow, and
   re-declare AC-31, AC-32, and AC-45.
