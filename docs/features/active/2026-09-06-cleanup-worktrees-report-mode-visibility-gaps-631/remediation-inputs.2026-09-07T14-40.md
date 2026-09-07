# Remediation Inputs — issue #631

- Timestamp: 2026-09-07T14-40
- Branch: `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
- Source artifacts:
  - `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/policy-audit.2026-09-07T14-40.md`
  - `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/code-review.2026-09-07T14-40.md`
  - `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/feature-audit.2026-09-07T14-40.md`
- Blocking findings: **1** (R-01). Total remediation-required findings: 6.

## R-01 — Blocking — `CHILD_OF` short-circuit changes classification outcome

- Refs: PA-01, CR-01, CR-02, AC3, AC5
- Files: `scripts/bash/cleanup_worktrees_report_records_lib.sh:431-447`;
  `tests/shell/test_cleanup_worktrees_classification.bats`;
  `tests/shell/test_cleanup_worktrees_deletion.bats`;
  `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/`

**Required:** the short-circuit must not fire for a branch that the unchanged ladder would
resolve to any state other than `NOT_MERGED`. Today the only guard is whether the subject
branch is protected; nothing checks the subject's own relationship to `main`, so a branch
already merged into `main` that is also a git ancestor of an unmerged branch is reported
`NOT_MERGED` and is no longer deleted in apply mode.

Two independent demonstrations are recorded in CR-01. The one reproducible from the
repository as it stands: `child_of_not_merged/` supplies no `diff-quiet.feature-child.rc`,
so the stub exits 0 for `git diff --quiet main...feature-child`, and
`classify_content_neutral` resolves `feature-child` to `MERGED_CONTENT_NEUTRAL` — a
delete-eligible state — while the short-circuit emits `NOT_MERGED`.

**Also required:** the two tests that claim to verify the invariant currently pin the
defect in place and must be rewritten.

- `"child_of_not_merged: report-mode BRANCH line is unchanged by the short-circuit"`
  compares two different branches in two different scenarios. Replace with a comparison
  that holds branch and fixture fixed: run `classify_all_branches` and `classify_branch
  <same branch>` under the same scenario and assert the `BRANCH|` lines are equal.
- `"apply mode allowlist is unaffected by a CHILD_OF short-circuit"` asserts no deletion
  for a branch that the full ladder would classify delete-eligible. It needs a fixture
  where the subject genuinely resolves `NOT_MERGED` through its own ladder.

**Also required:** a new fixture in which the subject branch *is* delete-eligible under
the full ladder (`merge-base.<subject>.main.rc` = 0, or a content-neutral / cherry-
equivalent shape) while being a git ancestor of a `NOT_MERGED` branch. That fixture must
assert the subject's true verdict, not `NOT_MERGED`. It fails today, which is the correct
starting signal.

Design note (not prescriptive): the rungs that establish merged-ness are the cheap ones.
Running rungs 1-3 unconditionally (protection, one `merge-base --is-ancestor X main`, one
`git diff --quiet main...X`) and inheriting only after both come back "not merged"
preserves most of the saving, since the O(commits) cost the spec targets lives in rungs
4-6. Note that a cherry-picked ancestor is also a counterexample at rung 4, so the sound
cut may be after rung 4 rather than rung 3; whichever is chosen, the justification needs
to be written down and tested rather than asserted.

**Spec implication:** `spec.md`'s "subset argument" ("if `Y` resolved to anything else,
`X` being an ancestor of `Y` does not by itself determine `X`'s state") is stated as
one-directional but relied on as bidirectional. `X` being an ancestor of a `NOT_MERGED`
`Y` does not determine `X`'s state either. The spec paragraph should be corrected
alongside the code so the next executor does not re-derive the same flaw.

## R-02 — Major — duplicate filesystem scan per report; docstring claims otherwise

- Refs: CR-03
- Files: `scripts/bash/cleanup_worktrees_report_records_lib.sh:200, 243-244, 253`;
  `scripts/bash/cleanup_worktrees_lib.sh:474-476`

`scan_orphan_dirs` and `scan_registration_loss` each invoke `cleanup_wt_scan_records`
independently, so `run_report` performs two complete scans and two `du -sh` passes over
every candidate directory. The issue this feature fixes cites a 6 GB orphan checkout, and
`scan_registration_loss` never uses the `size` field. `scan_registration_loss`'s docstring
asserts the two records come from "one consistent view of the filesystem"; the code
provides no such guarantee.

Hoist the scan to a single call site (or memoize) and pass records in, which also makes the
docstring true.

## R-03 — Major — outcome-preservation tests are vacuous

Folded into R-01 above; listed separately here only because it may be assigned as its own
task. See CR-02 for the specific assertions and the replacement shape.

## R-04 — Major — `.claude/worktrees` scan root is CWD-relative

- Refs: CR-04
- File: `scripts/bash/cleanup_worktrees_report_records_lib.sh:131`

`cleanup_wt_scan_roots` emits the bare relative path `.claude/worktrees` while deriving its
sibling root absolutely from `parse_worktree_list`. A non-directory root is skipped
silently by the helper, so when the tool runs from anywhere but the main worktree root —
including from a `.claude/worktrees/agent-*` session worktree, which is the skill's normal
operating context — the primary `ORPHAN_DIR` and `WARN|registration-lost` source produces
nothing and reports no error. That is the visibility gap this feature exists to close.

Derive it as `"${main_wt}/.claude/worktrees"` from the `parse_worktree_list` first stanza
already read a few lines below, and add a test pinning the derived root list (only the
`CLEANUP_WT_ORPHAN_ROOTS` override branch is currently exercised).

## R-05 — Minor — coverage evidence lacks per-file rows

- Refs: PA "Coverage Verification"
- File: `evidence/qa-gates/final-test-coverage.2026-09-06T23-03.md`

The artifact preserves only the aggregate `Bash coverage (lines): 93.4%` line. The tier
rule also requires >= 85% line coverage for each new file, and per-file coverage for
`cleanup_worktrees_report_records_lib.sh` and `cleanup_worktrees_scan_helper.sh` cannot be
confirmed from what was recorded. Export the per-file rows from kcov's merged Cobertura
`cov.xml` into the evidence artifact on the next coverage run.

Structural reading of the test sources (see the policy audit) shows three uncovered items
worth attention regardless of the number: the production `.git` default of
`scan_helper_gitfile_name` (R-06), the protected-and-deferred path through
`cleanup_wt_protected_branches`, and `cleanup_wt_scan_roots`' non-override branches
(R-04's test).

## R-06 — Minor — production `.git` default of the scan seam is untested

- Refs: CR-05
- Files: `scripts/bash/cleanup_worktrees_scan_helper.sh:41, 59-70`;
  `tests/shell/test_cleanup_worktrees_scan_helper.bats`

The seam itself is correct — an unset or empty `CLEANUP_WT_SCAN_GITFILE_NAME` falls back
to the literal `.git`, so the production path is not weakened, and the rationale for the
seam is sound and documented. But the only test sets the override, so the fallback literal
is unguarded. Add a test asserting `scan_helper_gitfile_name` returns `.git` with the
variable unset. If that test sources the helper, move the file-scope `set -euo pipefail`
inside the `BASH_SOURCE`/`$0` guard first so sourcing does not mutate the caller's shell
options.

## R-07 — Minor — AC6 sequencing evidence

- Refs: AC6 in the feature audit
- File: `evidence/regression-testing/stub-git-backward-compat.2026-09-06T23-03.md`

AC6 and plan task P2-T3 require the existing suite to pass immediately after the stub edit
and before any new fixture is authored. The recorded run is the post-Phase-9 tree (335
tests), which necessarily post-dates the new fixtures. The substantive property is
verified (no pre-existing scenario directory was modified, and all pass on the final tree),
so the risk is low. Resolve by dispatching the suite against a commit carrying only the
stub edit, or by amending the criterion to state the property actually verified and
recording why the sequenced run was not obtainable (`gh workflow run --ref` dispatches
branch HEAD only; bats cannot run locally in this environment).

## R-08 — Minor — documentation corrections

- Refs: CR-06, CR-09
- Files: `scripts/bash/cleanup-worktrees.sh:58, 78-90`;
  `scripts/bash/cleanup_worktrees_lib.sh:449-460`

1. `usage()` labels all four new records "report and apply mode". Only `CHILD_OF` reaches
   apply mode; the three scan records are report-mode only.
2. `CLEANUP_WT_SCAN_GITFILE_NAME` is missing from `usage()`'s "Environment overrides" list,
   which documents its two siblings.
3. `run_report`'s docstring still promises that a git failure aborts before any line is
   emitted, but the three advisory scans now fold their non-zero returns into `rc` after
   `check_main_freshness` has emitted output. Either make the advisory scans never affect
   `rc` (matching the spec's "never blocks classification" language for
   `WARN|registration-lost`) or move them into the up-front guarded-capture block. Also
   consider `((src > rc))` maximization for consistency with the classification driver's
   `rc` handling twelve lines later.

## Non-blocking observations carried forward (no action required for merge)

- **CR-07**: `run_apply`'s hard-failure gate narrowed from "non-zero rc" to
  "state == `ANCESTRY_ERROR`". I traced every `return 2` in `classify_branch` and confirmed
  no behavioural regression — the one non-`ANCESTRY_ERROR` case emits
  `HAS_UNIQUE_RESIDUALS`, which is off the allowlist, and the driver-level `rc=1` still
  propagates. A regression test would pin an equivalence that currently rests on an
  unenforced invariant in another file.
- **CR-08**: phase 1 costs `n*(n-1)` `git merge-base` process spawns unconditionally. The
  spec declines to assert a latency number, so this is not an AC failure, but combined with
  R-02's duplicate `du` pass and the second `enumerate_branches` call in `run_report`, the
  net runtime direction for the ~6-minute scenario that motivated the feature is unmeasured.
  A recorded before/after on a realistic checkout would convert the performance claim from
  asserted to observed.
- **CR-10**: hoist the loop-invariant `[[ -n ${protected[$x]:-} ]] && break` out of the
  target loop for legibility.
- A directory containing a `.git` *directory* (a nested full clone rather than a worktree)
  reports `has_gitfile=0` and is therefore emitted as `ORPHAN_DIR`. This matches the spec's
  wording ("no `.git` file") and the records are advisory with manual deletion, so it is
  acceptable — but it is worth a sentence in SKILL.md so an operator does not act on such a
  record without checking.
