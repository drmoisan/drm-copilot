# Phase 0 — Cycle-2 finding documents read

Timestamp: 2026-09-08T07-30
Task: [P0-T2]
Branch: bug/cleanup-worktrees-dirt-classifier-632-r2

## Documents read

1. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-inputs.2026-09-08T06-51.md`
2. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/code-review.2026-09-08T06-51.md`
3. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/feature-audit.2026-09-08T06-51.md`
4. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/policy-audit.2026-09-08T06-51.md`

## N1 — rung 4 resolves `CONTENT_ON_MAIN` from a pathspec that matched nothing

- File: `scripts/bash/cleanup_worktrees_dirt_lib.sh`
- Line range named by the finding: `294-305`
- Cited identically in all three finding documents that state a location:
  - `remediation-inputs.2026-09-08T06-51.md`: "Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`"
  - `code-review.2026-09-08T06-51.md`: "**Location:** `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`"
  - `policy-audit.2026-09-08T06-51.md`: "Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`"
- Severity: FAIL, data loss on `--clear-disposable`.
- Mechanism: `git diff --quiet main -- "$rel"` exits 0 both when the compared content is
  identical and when the pathspec selected no paths. Rung 4's tracked half reads exit 0 as
  the former unconditionally. An `AD` entry — added to the index then deleted from the
  working tree, so its content exists only as a staged blob — therefore resolves
  `CONTENT_ON_MAIN`, aggregates `ALL_DISPOSABLE`, and is cleared; `reset --hard` drops the
  index entry and the blob becomes unreachable.
- `feature-audit.2026-09-08T06-51.md` records N1 under "Findings not covered by any
  criterion" and states no criterion in the 45-item set constrains rung 4's inference.

## N2 — four safety guards that no checked-in fixture can distinguish from their absence

- File: `scripts/bash/cleanup_worktrees_dirt_lib.sh`
- The four sites named by the finding: `213`, `301-304`, `311-314`, `336-339`
- Cited identically in the three finding documents that state locations:
  - `remediation-inputs.2026-09-08T06-51.md`: "Locations: `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`, `:336-339`"
  - `code-review.2026-09-08T06-51.md`: "**Locations:** `cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`, `:336-339`"
  - `policy-audit.2026-09-08T06-51.md`: "Locations: `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301-304`, `:311-314`, `:336-339`"

| Site | Guard | Scenario that names it | Verdict with the guard removed, under a separating fixture |
|---|---|---|---|
| 213 | `((total == 0)) && return 1` vacuous-confinement guard | none | `DISPOSABLE_BUILD_ARTIFACT` + `ALL_DISPOSABLE` where the baseline is `UNIQUE`/`HAS_UNIQUE` |
| 301-304 | `((drc > 1))` in rung 4's tracked half | `dirt_tracked_read_errors` | `CONTENT_IN_HISTORY` + `ALL_DISPOSABLE` |
| 311-314 | the `((hrc != 0))` clause of the `hash-object` guard | `dirt_classifier_read_error` | `CONTENT_ON_MAIN` + `ALL_DISPOSABLE` |
| 336-339 | `((lrc != 0))` after `log --find-object` | `dirt_history_read_error` | `CONTENT_IN_HISTORY\|ffff8888` + `ALL_DISPOSABLE` |

- Severity: FAIL against the standing both-directions obligation and the Scenario
  Completeness clause of `.claude/rules/general-unit-test.md`.
- Common mechanism: each fixture supplies a non-zero exit code and no stdout, so a second
  and weaker condition downstream reaches the same verdict.

## Non-blocking carried into scope

- O1 — AC-8's text says "the **ten** `dirt_*` scenarios"; there are 25 and the test enforces
  the on-disk count. Text correction only, not an unchecking.

## Cycle-1 exit status recorded by the finding documents

All six cycle-1 blocking findings (R1, R2, R3, R4, R5, R6a, R6b) are verified closed against
the current tree by both `remediation-inputs.2026-09-08T06-51.md` and
`policy-audit.2026-09-08T06-51.md`. This cycle must not disturb them.

EXIT_CODE: 0
Output Summary: All four cycle-2 finding documents read. N1 is located at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:294-305`; N2 names the four sites `213`,
`301-304`, `311-314`, `336-339` in the same file. The three location-bearing documents agree
on both citations with no discrepancy.
