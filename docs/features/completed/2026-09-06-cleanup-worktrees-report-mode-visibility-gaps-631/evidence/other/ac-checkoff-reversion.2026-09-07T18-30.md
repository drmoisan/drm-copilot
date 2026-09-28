Timestamp: 2026-09-07T18-30
Command: N/A (documentation correction, not a toolchain command)
EXIT_CODE: 0
Output Summary: Reverted three acceptance-criterion checkboxes in spec.md from `[x]` back to `[ ]`
after fast-forward-merging a concurrent commit that had checked them off without adversarial
verification.

## Context

A concurrent process (a separate agent worktree also resuming issue #631) pushed commit
`fbb1e65b4181fa3596419f289ab841462f799cb8` ("docs(631): complete Phase 10-11 evidence and check
off all 11 ACs") to the canonical branch `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
after this orchestration session had already branched from and reviewed the prior tip
`02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`. `fbb1e65b` is a direct linear descendant of `02ce5eec`
(confirmed via `git merge-base --is-ancestor 02ce5eec fbb1e65b`), so it was incorporated via a
lossless fast-forward merge rather than treated as a conflicting fork.

That commit's spec.md edit checked off all 11 items under `## Acceptance Criteria`, including three
this session's independently-dispatched `feature-review` agent (artifacts `policy-audit.2026-09-07T14-49.md`,
`code-review.2026-09-07T14-49.md`, `feature-audit.2026-09-07T14-49.md`) had already evaluated as
FAIL or UNVERIFIED against the same commit `02ce5eec`, with reproducible evidence:

## Reverted items and why

1. **`CHILD_OF|<branch>|<ancestor>` emission criterion** (the third bullet under `## Acceptance
   Criteria`) — reverted `[x]` -> `[ ]`. `feature-review`'s Finding R1 reproduced, against the
   repository's own git stub, that `classify_all_branches` in
   `scripts/bash/cleanup_worktrees_report_records_lib.sh` emits `CHILD_OF|X|Y` and misclassifies X
   as `NOT_MERGED` whenever X is a git ancestor of any `NOT_MERGED` branch Y — including when X is
   already merged into `main` and is therefore an ancestor of every branch descending from `main`.
   This is not the criterion's stated behavior (limited to true short-circuit cases) and is
   independently reproducible; see `feature-audit.2026-09-07T14-49.md` and
   `remediation-inputs.2026-09-07T14-49.md` Finding R1 for the full transcript.

2. **`CHILD_OF` outcome-preservation invariant criterion** (the fifth bullet) — reverted `[x]` ->
   `[ ]`. Finding R1's reproduction directly violates both named properties: a `MERGED_CLEAN` branch's
   apply-mode allowlist decision changes (no `ACTION|branch-delete|...` is emitted for it once it is
   misclassified as `NOT_MERGED`). Finding R2 additionally shows the existing tests asserting this
   invariant cannot fail even when it is violated (no fixture pairs a delete-eligible branch with a
   `NOT_MERGED` descendant), so a green test suite is not evidence this criterion holds.

3. **`for-each-ref` stub backward-compatibility criterion** (the sixth bullet, AC6) — reverted `[x]`
   -> `[ ]`. The concurrent commit's own evidence artifact
   (`evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md`) cites the same CI
   run (34151370364) this session already reviewed, and observes the full suite passing only in the
   final, fully-assembled state — it does not (and, from a single squashed commit, cannot)
   demonstrate the criterion's literal requirement that the suite passed "immediately after that
   edit, before any new scenario fixtures are authored on top of it." `feature-review` marked this
   UNVERIFIED for the identical reason. This session's remediation plan (Finding R4) requires
   producing that ordered evidence directly (apply the stub edits alone onto the base tree, run the
   suite, record the result) rather than inferring it from the final-state run.

## Items left checked (not reverted)

AC1 (`ORPHAN_DIR`), AC2 (`STALE_REF`), AC4 (`WARN|registration-lost`), AC7 (SKILL.md mirror), AC8
(500-line cap), AC9 (toolchain/coverage, evidenced by the CI run's `Bash coverage (lines): 93.4%`
line), AC10 (no automatic deletion), and AC11 (no fixed numeric counts) were independently evaluated
PASS by this session's `feature-review` against concrete evidence and are left checked.

## Disposition

The three reverted items will be re-evaluated and re-checked (or left unchecked with a recorded gap)
only after the in-progress remediation cycle's Phase 2 (sound `CHILD_OF` rule), Phase 8 (ordered
stub backward-compatibility gate), and Phase 9 (outcome-preservation sweep) land and are
independently verified. No acceptance criterion is checked off in this artifact; this artifact only
documents a correction of a premature checkoff performed by a different process instance.
