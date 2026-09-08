# Remediation Inputs — cleanup-worktrees report-mode visibility gaps (#631)

- **Cycle entry timestamp:** 2026-09-07T14-49
- **Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631`
- **Work mode:** `full-bug` (AC source: `spec.md` only)
- **Base branch:** `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
- **Head:** `local-work-631-r2` @ `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`
- **Blocking finding count:** 2
- **Trigger:** audit FAIL findings + unmet acceptance criteria (AC5 FAIL, AC6 UNVERIFIED)

## Audit artifacts that produced these findings

- `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/policy-audit.2026-09-07T14-49.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/code-review.2026-09-07T14-49.md`
- `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/feature-audit.2026-09-07T14-49.md`
- PR context (regenerated at head SHA during the audit): `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`

---

## R1 — CHILD_OF short-circuit changes classification outcome

**Severity: Blocking**
BLOCKING

- **Files:** `scripts/bash/cleanup_worktrees_report_records_lib.sh` (lines 317-463, specifically the phase-2b inheritance at 431-447 and the prose invariant at 336-356); `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md` (the "`CHILD_OF` outcome-preservation invariant" section and AC3/AC5).
- **Current behavior (proven, not inferred):** `classify_all_branches` emits `BRANCH|X|NOT_MERGED` plus `CHILD_OF|X|Y` whenever X is a git ancestor of some Y that resolved exactly `NOT_MERGED`. A branch already merged into `main` is an ancestor of `main`, and therefore an ancestor of every branch descending from `main`. Such a branch flips from `MERGED_CLEAN` to `NOT_MERGED` and is no longer deleted in apply mode.

  Reproduction against `tests/fixtures/cleanup_worktrees/stub-bin/git` with three branches
  (`main` protected/current; `feature-merged` whose tip is an ancestor of `main`;
  `feature-unmerged` descending from `main` with one unique residual):

  ```
  pre-change  classify_branch : BRANCH|feature-merged|MERGED_CLEAN
  post-change classify_all_branches:
                                BRANCH|feature-merged|NOT_MERGED
                                CHILD_OF|feature-merged|feature-unmerged

  pre-change  run_apply       : BRANCH|feature-merged|MERGED_CLEAN
                                ACTION|branch-delete|feature-merged|OK
  post-change run_apply       : BRANCH|feature-merged|NOT_MERGED
                                CHILD_OF|feature-merged|feature-unmerged
                                (no ACTION line)
  ```

  Fixture keys used: `merge-base.feature-merged.rc=0`, `merge-base.feature-merged.main.rc=0`,
  `merge-base.feature-unmerged.rc=1`, `merge-base.main.feature-unmerged.rc=0`, plus the ladder
  data resolving `feature-unmerged` to `NOT_MERGED`. Full transcript in
  `code-review.2026-09-07T14-49.md`, section "Reproduction (Blocker)".

- **Expected behavior:** the short-circuit must change classification cost only, never
  classification outcome, for every branch and every verdict — this is spec.md's declared hard
  invariant. Concretely: for any branch X, the `BRANCH|X|<state>` line emitted by
  `classify_all_branches` must equal the line `classify_branch X` would emit, and the apply-mode
  allowlist decision for X must be identical, whether or not the short-circuit fires.

- **Scope note for the planner:** this is not a pure implementation defect. spec.md states the
  same invalid inference rule ("A branch whose tip is already an ancestor of another `NOT_MERGED`
  branch is short-circuited"), and AC3 encodes it. The spec and the affected criteria must be
  amended together with the code. Two considerations the planner must weigh before choosing a fix:

  1. The sound direction of the inference is the descendant one: if a `NOT_MERGED` branch Y is an
     ancestor of X, then X contains Y's unique residual commits and cannot be `MERGED_*`. Note
     that even this does not license the exact token `NOT_MERGED` for X, because X may
     independently carry a partial-merge signal that would make the ladder resolve
     `HAS_UNIQUE_RESIDUALS`. An inheritance that emits the wrong one of those two tokens is still
     an outcome change.
  2. In the originally reported scenario the epic child branches were merged *into* the
     integration branch, i.e. they were ancestors of it. A descendant-direction rule would not
     fire on them, so the gap 9c performance benefit for the reported case largely disappears.
     If the performance objective is to be retained, an alternative (for example, gating the
     existing rule on X additionally not being an ancestor of `main`) needs its own explicit
     soundness argument and its own test, and its extra probe cost must be counted against R5.

- **Verification commands:**
  - `bash scripts/bash/shell-qc.sh test` — the new scenario from R2 must be red before this fix and green after.
  - `bash scripts/bash/shell-qc.sh check` and `bash scripts/bash/shell-qc.sh format` must remain exit 0.
  - Re-run the pre/post `run_report` and `run_apply` sweep across all scenario directories (the method already recorded in `evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md`) with the R2 scenario included, and record `NO_DIFF` under `<FEATURE>/evidence/regression-testing/`.

---

## R2 — Invariant tests cannot fail when the invariant is violated

**Severity: Blocking**
BLOCKING

- **Files:** `tests/fixtures/cleanup_worktrees/scenarios/` (new scenario directory required); `tests/shell/test_cleanup_worktrees_classification.bats` (lines 191-204); `tests/shell/test_cleanup_worktrees_deletion.bats` (lines 130-140).
- **Current behavior:** both tests that name the outcome-preservation invariant pass while the
  invariant is violated.
  - Property (a) test (`classification.bats:191-204`) compares `feature-child` under
    `child_of_not_merged` against a *different* branch (`feature-unmerged`) under a *different*
    fixture (`unmerged`). It asserts record shape, not value invariance for one branch.
  - Property (b) test (`deletion.bats:130-140`) asserts only that a `NOT_MERGED` branch produces
    no deletion `ACTION`. `NOT_MERGED` was never on the delete-eligible allowlist, so the
    assertion holds independently of the invariant.
  - No scenario directory in the repository pairs a delete-eligible branch with a `NOT_MERGED`
    branch. Branch counts across the scenario set: 21 directories with 2 branches, 3 with 3 (the
    new `child_of_*` fixtures, in all of which the short-circuited branch is genuinely unmerged —
    `merge-base.feature-child.main.rc` is `1`). The recorded `NO_DIFF` outcome-preservation sweep
    is bounded by this same fixture set and therefore could not observe the divergence.
- **Expected behavior:** at least one scenario exists in which the short-circuit, if unsound,
  would change a delete-eligible verdict, and at least one test asserts both the report verdict
  and the apply-mode `ACTION` for that scenario.
- **Required fix:** add a scenario directory containing `main`, a branch that resolves
  `MERGED_CLEAN` (or `MERGED_EQUIVALENT`) against `main`, and a `NOT_MERGED` branch that the
  merged branch is a git ancestor of. Add two tests: one asserting
  `BRANCH|<merged-branch>|MERGED_CLEAN` from `classify_all_branches`, and one asserting the
  apply-mode `ACTION|branch-delete|<merged-branch>|OK`. Use checked-in fixture files only; create
  no temporary file.
- **Verification commands:**
  - Confirm the two new tests are red against the current head before R1 is applied, and green after.
  - `bash scripts/bash/shell-qc.sh test` — total count must be >= 337 (335 current + 2).
  - Record the red-then-green observation under `<FEATURE>/evidence/regression-testing/`.

---

## R3 — Filesystem scan executed twice per report; docstring claims otherwise

**Severity: Major**

- **File:** `scripts/bash/cleanup_worktrees_report_records_lib.sh` lines 200, 253, and the docstring at 243-244.
- **Current behavior:** `scan_orphan_dirs` and `scan_registration_loss` each call
  `cleanup_wt_scan_records` independently, so the root resolution (including a
  `parse_worktree_list` git read), the directory walk, and every `du -sh` run twice per report.
  The docstring asserts the two records are "always derived from one consistent view of the
  filesystem", which the code does not provide.
- **Expected behavior:** one scan per report, consumed by both functions, matching the docstring.
- **Required fix:** hoist the scan into `run_report` and pass the record set to both functions, or
  memoize `cleanup_wt_scan_records`. Keep the seam and the hard-failure return semantics intact.
- **Verification commands:** `bash scripts/bash/shell-qc.sh test`; assert via the scan stub's
  invocation count that `scan-dirs` is invoked exactly once per `run_report` call.

---

## R4 — No ordered regression-gate evidence for the shared stub edit (AC6)

**Severity: Major**

- **Files:** `tests/fixtures/cleanup_worktrees/stub-bin/git`; missing artifact
  `<FEATURE>/evidence/regression-testing/stub-git-backward-compat.<timestamp>.md`; plan task P2-T3
  (`plan.2026-09-06T23-03.md:231-241`, unchecked).
- **Current behavior:** spec.md's Backward-compatibility expectations and Manual validation steps
  both require a full existing-suite bats run immediately after the `for-each-ref` and
  `merge-base` stub key edits and before any new scenario fixture is authored on top of them. No
  such run is recorded, and the work landed as a single squashed commit, so the intermediate tree
  state cannot be reconstructed from history.
- **Expected behavior:** the ordered gate is performed and recorded, or its absence is recorded
  explicitly with the reason.
- **Required fix:** apply the two stub key edits alone onto the base tree, run
  `bash scripts/bash/shell-qc.sh test`, and record the exit code and the total test count
  (which must be >= the 321 recorded in `evidence/baseline/baseline-test.2026-09-06T23-03.md`)
  under `<FEATURE>/evidence/regression-testing/stub-git-backward-compat.<timestamp>.md`, with an
  explicit statement that both stub edits pass every pre-existing scenario unchanged. If
  re-deriving the intermediate state is impractical, record that determination and the end-state
  evidence in the same artifact rather than leaving the criterion silent.
- **Verification commands:** `bash scripts/bash/shell-qc.sh test` on the intermediate tree; the
  artifact must carry the four required evidence fields.

---

## R5 — New report-mode cost is unmeasured and plausibly exceeds the savings

**Severity: Major**

- **Files:** `scripts/bash/cleanup_worktrees_report_records_lib.sh` lines 377-398; `scripts/bash/cleanup_worktrees_scan_helper.sh` line 119.
- **Current behavior:** three new costs on the report path. (a) The pairwise ancestry probe spawns
  up to n(n-1) `git merge-base --is-ancestor` processes and never breaks the inner loop after the
  first hit, although at most one resolved target is consumed at line 438; for the 20+ branch
  checkout in the issue that is 400+ additional process spawns. (b) `du -sh` is computed for every
  immediate subdirectory of every scan root, including live registered worktrees, although
  `<size>` is only emitted on `ORPHAN_DIR` records; the issue cites a 6 GB orphan directory. (c)
  That entire walk runs twice, per R3. No runtime measurement appears anywhere in the feature
  folder.
- **Expected behavior:** the gap 9c objective (reduced report runtime) is falsifiable, and the new
  costs are bounded.
- **Required fix:** break the inner probe loop once a usable target is found, or restrict probe
  targets to branches already resolved `NOT_MERGED`; make the size computation lazy so `du` runs
  only for directories that will actually be emitted as `ORPHAN_DIR`; and record a before/after
  report-mode runtime measurement under `<FEATURE>/evidence/other/`.
- **Verification commands:** `bash scripts/bash/shell-qc.sh test`; a timed `run_report` against a
  representative checkout, recorded before and after.

---

## R6 — Error-handling paths of the new code are untested

**Severity: Major**

- **Files:** `scripts/bash/cleanup_worktrees_report_records_lib.sh` (uncovered lines 81-82, 86-87,
  124-129, 135, 159, 161, 173, 176-177, 202, 255, 292, 303, 364, 373, 429, 453);
  `scripts/bash/cleanup_worktrees_scan_helper.sh` (uncovered lines 54, 69, 88-89, 127, 145-146).
- **Current behavior:** 30 of 262 instrumented lines across the two new files are unhit at the
  head SHA, and they are almost entirely the error, fallback, and override branches. Three of the
  untested cases are named explicitly in spec.md's Test Strategy as required edge cases: the
  `ORPHAN_DIR|<path>|unknown` unresolvable-size case, the scan hard-failure case, and the
  unreadable-`.git`-file case. `scan_helper`'s production default pointer-file name `.git`
  (line 69) is never exercised because every test sets the seam.
- **Expected behavior:** `.claude/rules/general-unit-test.md` Scenario Completeness — error-handling
  behavior is covered.
- **Required fix:** add tests for the three spec-named edge cases, for the
  `CLEANUP_WT_ORPHAN_ROOTS` override branch, for the two `scan_stale_refs` git-failure returns,
  and for one `scan_helper` invocation that does not set `CLEANUP_WT_SCAN_GITFILE_NAME`. Use
  checked-in fixtures and stub `.rc` files; create no temporary file.
- **Verification commands:** `bash scripts/bash/shell-qc.sh test --coverage`; the per-file line
  rate for both new files must not decrease, and the named lines must move to non-zero hits in
  `cov.xml`.
- **Note:** repo-wide bash line coverage is 93.4%, above the 85% floor, so this is a
  scenario-completeness gap rather than a threshold breach.

---

## R7 — Documentation, contract, and robustness defects

**Severity: Minor** (five items; group into one phase)

1. `scripts/bash/cleanup_worktrees_report_records_lib.sh:131` — `cleanup_wt_scan_roots` emits the
   CWD-relative literal `.claude/worktrees`. The tool never chdirs to the repository root
   (`cleanup-worktrees.sh:10` resolves only `SCRIPT_DIR`), so run from any other directory the
   root is silently skipped. Separately, that relative path can never match an absolute porcelain
   path through `normalize_wt_path` (which does not absolutize,
   `cleanup_worktrees_enumerate_lib.sh:150-164`), so the registration gate is dead for this root.
   **Fix:** resolve the root against `git rev-parse --show-toplevel`.
2. `scripts/bash/cleanup-worktrees.sh:58` — the usage text heads all four new records
   "(report and apply mode)", but the three scan records are emitted only by `run_report`.
   **Fix:** scope the parenthetical to `CHILD_OF`.
3. `scripts/bash/cleanup_worktrees_lib.sh:475-477` — the three scan calls run after output has
   begun; a hard scan failure sets `rc` but the report continues, contradicting the function's own
   early-abort docstring at 456-459. The three consecutive `|| rc=$?` assignments also use
   last-failure rather than maximum semantics. **Fix:** either capture the scans before the first
   emission and abort on hard failure, or amend the docstring.
4. `scripts/bash/cleanup_worktrees_actions_lib.sh:402-409` — hard-failure detection narrowed from
   "`classify_branch` returned non-zero" to "state == `ANCESTRY_ERROR`"; `classify_branch` can
   return 2 after emitting `HAS_UNIQUE_RESIDUALS` (`cleanup_worktrees_lib.sh:437-443`). Latent,
   not active: no deletion is unlocked and the driver rc still propagates. Also,
   `printf '%s\n' "$cb_out"` emits a blank line when a branch is absent from the driver output.
   **Fix:** return a per-branch status from the driver and guard the `printf` on non-empty output.
5. `scripts/bash/cleanup_worktrees_scan_helper.sh:82-89` — spec.md says an unreadable `.git`
   pointer file is "skipped silently"; the helper returns `0`, so the directory is reported as
   registration-lost. **Fix:** emit `NA` for "pointer present but unreadable";
   `scan_registration_loss:266` already skips any value that is neither `0` nor `1`.

---

## R8 — Missing plan-mandated evidence artifacts

**Severity: Minor**

- **Files:** plan Phases 10 and 11 (`plan.2026-09-06T23-03.md:599-645`), all unchecked; the
  artifacts `<FEATURE>/evidence/other/file-size-cap-verification.<ts>.md`,
  `<FEATURE>/evidence/other/ac11-generic-detection-confirmation.<ts>.md`, and
  `<FEATURE>/evidence/qa-gates/final-{format,check,test,test-coverage}.<ts>.md` do not exist.
- **Current behavior:** every underlying fact was independently established during this audit
  (file sizes by `wc -l`; generic detection by grep and by reading the detection logic;
  format and lint by running `shfmt -d` and `shellcheck -x`; tests and coverage from CI run
  34151370364 and its uploaded `cov.xml`), so no audit claim rests on the missing files. What is
  absent is the durable record the plan requires, including the single-pass loop confirmation.
- **Required fix:** execute Phases 10 and 11 after R1-R6 land and record their artifacts under
  `<FEATURE>/evidence/`. The final coverage artifact must carry the literal
  `Bash coverage (lines): NN.N%` line with a value >= 85.0 alongside the 94.2% baseline.
- **Also reconcile:** 11 Phase 1-7 test tasks are unchecked although the corresponding tests exist
  and pass (321 -> 335 = exactly the 14 `@test` blocks those tasks describe). Check them off so
  the checklist distinguishes delivered work from the genuinely outstanding P2-T3, P10, and P11.

---

## R9 — PR context autoclose candidates

**Severity: Minor**

- **File:** `artifacts/pr_context.summary.txt`, "Close candidates" section.
- **Current behavior:** the regenerated PR context lists `#545` and `#630` under "Auto-close
  issues (author asserted)". Neither is fixed by this branch; both appear in spec.md only as
  explicitly out-of-scope references.
- **Required fix:** ensure the PR body's autoclose list names `#631` only before the PR is opened.
- **Verification:** inspect the rendered PR body before submission.

---

## Do Not Do

- Do not weaken, relax, or delete any acceptance criterion in `spec.md` to make it pass. AC5 must
  be amended only to correct the *inference rule it states*, never to lower the outcome-preservation
  requirement itself.
- Do not delete, skip, or `skip`-annotate any existing bats test.
- Do not add an `exclude` entry, coverage suppression, or lint suppression to make a gate pass.
- Do not create temporary files or scratch git repositories in tests; use checked-in fixtures and
  the established stub seams.
- Do not expand scope beyond R1-R9. In particular, do not implement detached-worktree
  classification (#630), the dirt classifier or `--clear-disposable`, the sanctioned removal
  manifest, or `PRESERVE` consolidation — all are other epic children and explicit non-goals in
  spec.md.
- Do not add automatic deletion of orphan directories or stale refs; AC10 currently passes and
  must continue to.
- Do not exceed the 500-line cap on any shell file. `cleanup_worktrees_lib.sh` is at 491 with only
  9 lines of headroom; put new logic in the sibling library or a new file.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not write evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or
  `artifacts/coverage/`; the canonical location is `<FEATURE>/evidence/<kind>/`.
- Do not edit `.claude/skills/cleanup-merged-worktrees/SKILL.md` without mirroring the change
  byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`;
  the push-down contract test enforces this.

---

## Exit Criteria for This Cycle

The cycle may close when all of the following hold:

1. R1 and R2 are resolved: the new delete-eligible-ancestor scenario is red before the fix and
   green after, and `classify_all_branches` emits, for every branch, the same `BRANCH|` line
   `classify_branch` would emit.
2. The pre/post `run_report` and `run_apply` sweep across all scenario directories, including the
   new one, reports `NO_DIFF` against the pre-change baseline for every pre-existing scenario.
3. R3, R4, R5, and R6 are resolved or explicitly dispositioned with recorded evidence.
4. `bash scripts/bash/shell-qc.sh format`, `check`, `test`, and `test --coverage` all pass in a
   single loop, with the recorded `Bash coverage (lines): NN.N%` value >= 85.0 and no per-file
   regression for the two new files.
5. spec.md's `CHILD_OF` invariant section and AC3/AC5 are amended to state a sound rule, and every
   acceptance criterion is either checked off with evidence or explicitly recorded as unmet.
6. A reaudit produces zero Blocking findings.
