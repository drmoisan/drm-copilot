# Remediation Plan — cleanup-worktrees report-mode visibility gaps (#631), cycle 1

- **Issue:** #631
- **Cycle timestamp:** 2026-09-07T14-49
- **Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631`
- **Work Mode:** `full-bug` (persisted marker `- Work Mode: full-bug` at
  `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/issue.md:12`;
  acceptance-criteria source is `spec.md` only)
- **Remediation input (authoritative):**
  `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/remediation-inputs.2026-09-07T14-49.md`
- **Base branch/commit for every differential command in this plan:**
  `origin/epic/cleanup-merged-worktrees-hardening-integration` @
  `6dff80ed4596bec088d548b23013e6077e32c484`
- **Prior plan (reconciled, not superseded, by Phase 10):**
  `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md`

## Scope Boundary

In scope: findings R1 through R9 of the remediation-inputs file, and the six items of its
"Exit Criteria for This Cycle" section.

Out of scope, per the remediation-inputs "Do Not Do" section: detached-worktree
classification (#630), the dirt classifier and `--clear-disposable`, the sanctioned removal
manifest, `PRESERVE` consolidation, automatic deletion of orphan directories or stale refs,
and any edit to `.claude/rules/**` or `.github/instructions/**`.

## Binding Constraints

1. No acceptance criterion in `spec.md` may be weakened, relaxed, or deleted. AC3 and AC5 are
   amended only to replace the unsound inference rule they state; the outcome-preservation
   requirement itself is strengthened, never lowered.
2. No existing bats test may be deleted, skipped, or `skip`-annotated. Exactly two existing
   tests are rewritten in place, both in `tests/shell/test_cleanup_worktrees_classification.bats`
   and both re-derived this pass: the `@test` block at line 153, which carries three negative
   argv assertions asserting the defective skip behavior (rewritten and retitled by P2-T8, with
   P2-T7 extending its fixture so the branch resolves on its own ladder); and the `@test` block
   at line 195, the Finding R2 property-(a) test, which compares two different branches under
   two different fixtures (rewritten and retitled by P2-T9 into a same-branch, same-fixture value
   comparison). The `@test` block count of that file does not decrease, and no `skip` call is
   introduced anywhere.
3. No `exclude` entry, coverage suppression, or lint suppression may be added to make a gate
   pass.
4. No test may create a temporary file or a scratch git repository. All new coverage uses
   checked-in fixtures under `tests/fixtures/cleanup_worktrees/` and the established
   `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_SCAN_BIN`, `CLEANUP_WT_ORPHAN_ROOTS`, and
   `CLEANUP_WT_SCAN_GITFILE_NAME` seams.
5. No shell file may exceed 500 lines. Current sizes re-derived this pass:
   `scripts/bash/cleanup_worktrees_lib.sh` = 491 lines (9 lines of headroom),
   `scripts/bash/cleanup_worktrees_report_records_lib.sh` = 463 lines,
   `scripts/bash/cleanup_worktrees_scan_helper.sh` = 157 lines,
   `scripts/bash/cleanup_worktrees_actions_lib.sh` = 417 lines,
   `scripts/bash/cleanup-worktrees.sh` = 128 lines.
6. Every edit to `.claude/skills/cleanup-merged-worktrees/SKILL.md` is mirrored
   byte-identically into
   `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
7. All evidence is written under
   `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/<kind>/`.
   Writing to `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
   `artifacts/qa-gates/`, `artifacts/evidence/`, or `artifacts/coverage/` is a policy
   violation.

## One Session-Bound Substitution

One value cannot be written literally because it is session-bound. Everywhere it appears in a
command span, the executor substitutes the concrete value and records the substituted command
in the artifact's `Command:` field:

- `<scratchpad>` — the session scratchpad directory supplied to the executor. Nothing is ever
  written into the repository working tree by a task that names it.

No other angle-bracketed token appears inside a command span in this plan. Angle brackets do
appear elsewhere in ordinary prose, in two roles that are descriptive rather than executable:
the report-record shapes such as `ORPHAN_DIR|<path>|<size>`, and the Cobertura XML element name
`<class>`. Neither is a value the executor substitutes.

## Branch and Push Refs (read before Phase 0)

The branch checked out in this worktree is locally aliased `local-work-631-r2`
(`.git/worktrees/agent-a4a8d269a4cd47aef/HEAD` reads `ref: refs/heads/local-work-631-r2`,
re-derived this pass), and its head commit is `02ce5eec8c7a8178e8ad4317b69d1c62afe0f284`
(the contents of `refs/heads/local-work-631-r2`, re-derived this pass). The canonical remote
branch name for this cycle is `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`.

Every push in this plan uses one explicit refspec,
`git push --set-upstream origin local-work-631-r2:bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`,
so the remote ref name is fixed in the plan text and no `gh workflow run --ref` value has to be
derived at runtime. P0-T9 performs the first push; P12-T3 repeats it so the final dispatch sees
the commits added by Phases 1 through 11.

## Toolchain Execution Route (read before Phase 0)

The bash toolchain has two stages that run locally and two that do not, re-derived this pass:

- `bash scripts/bash/shell-qc.sh format` and `bash scripts/bash/shell-qc.sh check` resolve
  `shfmt` and `shellcheck` from the Windows PATH and run locally. The recorded baseline
  `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-check.2026-09-06T23-03.md`
  confirms both ran locally with `EXIT_CODE: 0`.
- `bash scripts/bash/shell-qc.sh test` does **not** fail when `bats` is absent. `run_test`
  (`scripts/bash/shell_qc_lib.sh:240-243`) prints the literal
  `bats not installed; skipping shell tests.` and returns 0. A local invocation that prints
  that literal is **not evidence of a passing suite**; it is evidence that the suite did not
  run.
- `bash scripts/bash/shell-qc.sh test --coverage` fails loudly when `bats` is absent:
  `run_test_coverage` (`scripts/bash/shell_qc_lib.sh:310-313`) prints
  `bats not installed; cannot run shell tests with coverage.` and returns 127.

**Route rule (applies to every `test` and `test --coverage` task in this plan).** Run the
command locally first. If its stdout contains either of the two literals quoted above, the
local run is discarded and the executor dispatches
`gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
(`.github/workflows/_shell-coverage.yml` declares `workflow_dispatch` and takes no inputs;
its `Run shell-qc test with coverage` step runs the identical bats suite that
`shell-qc.sh test` runs, which is the precedent recorded in
`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test.2026-09-06T23-03.md`).
The evidence artifact then records the CI run URL in its `Command:` field, the job conclusion
in `EXIT_CODE:`, and the TAP counts and the `Bash coverage (lines): NN.N%` line in
`Output Summary:`. A dispatch requires the named remote ref to exist and to carry the commits
under test: P0-T9 establishes that before the two Phase 0 dispatch tasks, and P12-T3
re-establishes it before the two Phase 12 dispatch tasks.

## Design Decision for R1 (binding on Phases 2 and 3)

The current rule in `classify_all_branches`
(`scripts/bash/cleanup_worktrees_report_records_lib.sh:431-447`) is: X inherits `NOT_MERGED`
when X is a git ancestor of some Y that resolved exactly `NOT_MERGED`. Re-derived soundness
analysis of both directions against the ladder in `classify_branch`
(`scripts/bash/cleanup_worktrees_lib.sh:313-448`):

- **Ancestor direction (X contained in Y), the rule as written.** Unsound. A branch already
  merged into `main` is an ancestor of `main` and therefore of every branch descending from
  `main`. `classify_ancestry` (`scripts/bash/cleanup_worktrees_lib.sh:57-78`) would resolve
  such an X to `MERGED_CLEAN` at rung 2. The inheritance overwrites that with `NOT_MERGED`,
  and `run_apply`'s allowlist (`scripts/bash/cleanup_worktrees_actions_lib.sh:409-414`) then
  skips a branch it would otherwise delete.
- **Descendant direction (Y contained in X), the direction the remediation-inputs names as
  sound.** It soundly establishes only that X is not an ancestor of `main`, i.e. rung 2
  returns `NOT_ANCESTOR`. It does not establish the `NOT_MERGED` token: X may still resolve
  `MERGED_CONTENT_NEUTRAL` at rung 3 (`scripts/bash/cleanup_worktrees_lib.sh:382-392`, X
  containing Y plus a revert of Y), `MERGED_EQUIVALENT` at rung 4 or 5
  (`scripts/bash/cleanup_worktrees_lib.sh:401-427`), or `HAS_UNIQUE_RESIDUALS` at rung 6
  (`scripts/bash/cleanup_worktrees_lib.sh:428-437`). Emitting `NOT_MERGED` in any of those
  cases is still an outcome change, which the remediation-inputs states explicitly.
- **Consequence.** No ancestry-only inference licenses skipping rungs 3 through 6, in either
  direction. The rung-2 saving the sound direction does license is one
  `git merge-base --is-ancestor` call, which is not the cost the gap 9c objective targeted.

**Decision.** `CHILD_OF` becomes a purely advisory ancestry record. Every branch is classified
by the unchanged `classify_branch` ladder, exactly once, with no inheritance of any kind, which
makes the outcome-preservation invariant an identity rather than an argument. `CHILD_OF|X|Y` is
emitted alongside X's own unchanged `BRANCH|X|<state>` line when all of the following hold:
X's resolved state is neither `PROTECTED_CURRENT` nor `ANCESTRY_ERROR`; X is not in
`cleanup_wt_protected_branches`' set; Y is a distinct branch whose resolved state is exactly
`NOT_MERGED`; and `git merge-base --is-ancestor X Y` exits 0. Y is the first such branch in
`LC_ALL=C` order and the probe loop breaks on that first hit.

The gap 9c report-runtime-reduction objective is therefore **not delivered** by this feature.
Phase 3 records that determination in `spec.md` rather than leaving it implied, and Phase 5
bounds and measures the residual cost the advisory record adds so the trade-off is auditable.

---

### Phase 0 — Policy Reads and Remediation Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md` in full. Acceptance: the file is listed in the P0-T6 artifact's
      `Policy Order:` block; no file in the repository is modified by this task.
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full, noting the 500-line file-size
      cap and the seven-stage toolchain loop. Acceptance: the file is listed in the P0-T6
      artifact's `Policy Order:` block.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full, noting the no-temporary-file
      rule, the Scenario Completeness list, and the Coverage Exclusion Policy. Acceptance: the
      file is listed in the P0-T6 artifact's `Policy Order:` block.
- [ ] [P0-T4] Read `.claude/rules/quality-tiers.md` in full, noting the uniform 85% line-coverage
      threshold and the bash branch-coverage exemption. Acceptance: the file is listed in the
      P0-T6 artifact's `Policy Order:` block.
- [ ] [P0-T5] Read `.claude/rules/shell.md` in full, noting the four-stage bash order
      (format, check, test, test --coverage) and the `Bash coverage (lines): NN.N%` summary
      line. Acceptance: the file is listed in the P0-T6 artifact's `Policy Order:` block.
- [ ] [P0-T6] Write the policy-read evidence artifact at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/phase0-instructions-read.2026-09-07T14-49.md`
      containing `Timestamp:`, `Policy Order:` (the five files of P0-T1 through P0-T5 in that
      order), and an explicit list of the files read. Acceptance: the file exists and contains
      all three field labels.
- [ ] [P0-T7] Run `bash scripts/bash/shell-qc.sh format`. This is a write-mode command whose
      success-case output is empty (`run_format`, `scripts/bash/shell_qc_lib.sh:204-224`,
      returns shfmt's exit code and prints nothing when nothing was rewritten), so the exit code
      alone cannot distinguish a clean run from a repairing one. Immediately afterward run
      `git status --porcelain -- scripts/bash tests/shell tests/fixtures` and record its output.
      Record both at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-format.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating whether the
      porcelain output was empty. Acceptance: the artifact exists with all four fields and its
      `Output Summary:` names the porcelain result explicitly.
- [ ] [P0-T8] Run `bash scripts/bash/shell-qc.sh check`. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-check.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (shfmt diff count and
      shellcheck finding count). Acceptance: the artifact exists with all four fields.
- [ ] [P0-T9] Commit the working tree (which includes `scripts/bash` and `tests/shell`) and push
      this branch with upstream tracking before any Route-rule dispatch task runs, because
      `gh workflow run` resolves its `--ref` against the remote and the local branch alias
      `local-work-631-r2` has no pushed upstream. Run `git add -A`; then
      `git status --porcelain` and record its output; then
      `git commit -m "chore(631): checkpoint before remediation-cycle CI dispatch"` — this single
      `git commit` invocation is skipped when, and only when, the recorded porcelain output is
      empty, since there is then nothing to commit; this task and P12-T3 carry the only two
      explicitly authorized skip branches in this plan, and each is bounded to its own
      `git commit` invocation; then
      `git push --set-upstream origin local-work-631-r2:bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`;
      then `git rev-parse HEAD` and
      `git rev-parse origin/bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`. Record
      every command and its output at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/branch-push-before-dispatch.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that states the
      porcelain result and both SHAs. Acceptance: the artifact exists with all four fields, and
      the SHA recorded for `HEAD` is byte-identical to the SHA recorded for
      `origin/bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`, so the remote ref the
      Route rule dispatches against carries exactly the tree the local baseline was taken from.
- [ ] [P0-T10] Run `bash scripts/bash/shell-qc.sh test` under the Route rule above. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-test.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` carrying the total planned
      test count and the passed/failed tally. Acceptance: the artifact exists with all four
      fields and its `Output Summary:` states a total test count of 335, which is the count of
      `^@test ` blocks under `tests/shell/` re-derived this pass.
- [ ] [P0-T11] Run `bash scripts/bash/shell-qc.sh test --coverage` under the Route rule above.
      Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-test-coverage.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that quotes the
      literal `Bash coverage (lines):` line the run printed. Acceptance: the artifact exists
      with all four fields and its `Output Summary:` contains the literal
      `Bash coverage (lines):` followed by a numeric percentage.
- [ ] [P0-T12] From the `cov.xml` produced by P0-T11 (path `artifacts/pester/kcov/cov.xml`, or
      the uploaded `shell-coverage` artifact when the CI route was taken), extract the
      `line-rate` attribute of the two `<class>` entries whose `filename` attribute ends in
      `cleanup_worktrees_report_records_lib.sh` and `cleanup_worktrees_scan_helper.sh`. Record
      both values at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-per-file-coverage.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact
      records one numeric per-file line rate for each of the two named files. These two numbers
      are the no-regression reference for R6.
- [ ] [P0-T13] Time three consecutive report-mode runs of the unmodified tool against this
      worktree with `time bash scripts/bash/cleanup-worktrees.sh report > /dev/null` (report
      mode performs no mutation). Record the three wall-clock durations at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/report-runtime-before.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` naming the branch count
      reported and the three durations. Acceptance: the artifact records three numeric
      durations and the branch count. This is the "before" half of R5's measurement.

### Phase 1 — R2: Delete-Eligible-Ancestor Scenario Fixture and Discriminating Tests

- [ ] [P1-T1] Create the scenario directory
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_delete_eligible/` with these
      checked-in files and exact contents:
      `for-each-ref.out` = the three lines `feature-merged bbbb1111`, `feature-unmerged dddd5555`,
      `main aaaa0000`;
      `worktree-list.out` = a byte-for-byte copy of
      `tests/fixtures/cleanup_worktrees/scenarios/merged_no_worktree/worktree-list.out`
      (the three lines `worktree /repo/main`, `HEAD aaaa0000`, `branch refs/heads/main`
      followed by the stanza-terminating blank line);
      `rev-parse.abbrev-ref-HEAD.out` = `main`;
      `rev-parse.show-toplevel.out` = `/repo/main`.
      Acceptance: the four files exist with exactly those contents.
- [ ] [P1-T2] Add the ancestry fixture keys to
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_delete_eligible/`:
      `merge-base.feature-merged.rc` = `0`, `merge-base.feature-merged.main.rc` = `0`,
      `merge-base.feature-unmerged.rc` = `1`, `merge-base.main.rc` = `1`.
      Under the stub's documented key scheme
      (`tests/fixtures/cleanup_worktrees/stub-bin/git:133-149`, re-derived this pass) the bare
      `merge-base.feature-merged.rc` key answers both the rung-2 ladder probe against `main`
      and the pairwise `--is-ancestor feature-merged feature-unmerged` probe with exit 0, which
      is precisely the ancestor-of-main-and-of-an-unmerged-branch shape Finding R1 names.
      Acceptance: the four `.rc` files exist with exactly those single-digit contents.
- [ ] [P1-T3] Add the ladder fixture keys that resolve `feature-unmerged` to `NOT_MERGED` in
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_delete_eligible/`:
      `diff-quiet.feature-unmerged.rc` = `1`;
      `cherry.feature-unmerged.out` = `+ dead0003`;
      `diff-tree.dead0003.out` = one tab-separated line `M<TAB>src/unmerged.py` (the name-status
      shape used by
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_merged_equivalent/diff-tree.res00001.out`);
      `rev-parse.feature-unmerged_src_unmerged.py.out` = `blobunmergedA`;
      `rev-parse.main_src_unmerged.py.out` = `blobmainD`.
      Acceptance: the five files exist; the two blob values differ, which is what makes the
      residual resolve `UNIQUE` and therefore the branch resolve `NOT_MERGED` with no
      partial-merge signal.
- [ ] [P1-T4] [expect-fail] Append one `@test` block titled
      `child_of_delete_eligible: a merged branch that is an ancestor of an unmerged branch keeps its own verdict`
      to `tests/shell/test_cleanup_worktrees_classification.bats`, driven through the existing
      `classify_all` helper (defined at
      `tests/shell/test_cleanup_worktrees_classification.bats:28-38`). It asserts
      `[[ "$output" == *"BRANCH|feature-merged|MERGED_CLEAN"* ]]`,
      `[[ "$output" == *"BRANCH|feature-unmerged|NOT_MERGED"* ]]`, and
      `[[ "$output" != *"BRANCH|feature-merged|NOT_MERGED"* ]]`.
      Acceptance: `grep -c '^@test ' tests/shell/test_cleanup_worktrees_classification.bats`
      returns 17 (16 re-derived this pass, plus this one). This block is tagged
      `[expect-fail]`: it is authored against the unfixed driver and is expected to fail until
      P2-T3 and P2-T4 land, because the current inheritance rule emits
      `BRANCH|feature-merged|NOT_MERGED` for this fixture. The auditable fail-before evidence for
      it is the pre-fix transcript recorded by P2-T1 and the fail-before exception dossier
      recorded by P2-T2, which together explain why a bats-level red run cannot be produced
      locally.
- [ ] [P1-T5] [expect-fail] Append one `@test` block titled
      `child_of_delete_eligible: apply mode still deletes the merged ancestor branch`
      to `tests/shell/test_cleanup_worktrees_deletion.bats`, driven through the existing `apply`
      helper (defined at `tests/shell/test_cleanup_worktrees_deletion.bats:25-33`) against
      `"${SCEN}/child_of_delete_eligible"`. It asserts
      `[[ "$output" == *"ACTION|branch-delete|feature-merged|OK"* ]]` and
      `[[ "$output" == *"BRANCH|feature-merged|MERGED_CLEAN"* ]]`.
      Acceptance: `grep -c '^@test ' tests/shell/test_cleanup_worktrees_deletion.bats` returns
      11 (10 re-derived this pass, plus this one). This block is tagged `[expect-fail]` for the
      same reason as P1-T4: under the unfixed driver `feature-merged` is overwritten to
      `NOT_MERGED` and is therefore off the apply-mode allowlist, so no deletion `ACTION` is
      emitted. Its auditable fail-before evidence is the P2-T1 pre-fix transcript and the P2-T2
      fail-before exception dossier.

### Phase 2 — R1: Sound `CHILD_OF` Rule in the Shared Classification Driver

- [ ] [P2-T1] Capture the pre-fix behavior of the new fixture without bats, which is unavailable
      locally: write the current library to the session scratchpad with
      `git show 02ce5eec8c7a8178e8ad4317b69d1c62afe0f284:scripts/bash/cleanup_worktrees_report_records_lib.sh > <scratchpad>/rrlib-prefix.sh`
      (the SHA is pinned to this branch's head as re-derived this pass from
      `refs/heads/local-work-631-r2`, rather than to the ambient `HEAD`, so the transcript is
      taken from a fixed tree whatever P0-T9 has committed by the time this task runs), then run
      `env CLEANUP_WT_GIT_BIN=tests/fixtures/cleanup_worktrees/stub-bin/git CLEANUP_WT_STUB_SCENARIO=tests/fixtures/cleanup_worktrees/scenarios/child_of_delete_eligible bash -c "source scripts/bash/cleanup_worktrees_enumerate_lib.sh && source scripts/bash/cleanup_worktrees_lib.sh && source <scratchpad>/rrlib-prefix.sh && classify_all_branches 2>/dev/null"`.
      Record the full stdout at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/child-of-delete-eligible-fail-before.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the recorded
      stdout contains the line `BRANCH|feature-merged|NOT_MERGED` and does not contain
      `BRANCH|feature-merged|MERGED_CLEAN`, which is the Finding R1 defect observed directly on
      the new fixture. Tagged `[expect-fail]`: this task records a defective pre-fix outcome by
      design.
- [ ] [P2-T2] Write the fail-before exception dossier at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/fail-before-exception.2026-09-07T14-49.md`
      containing `Timestamp:`, `WhyFailingRunImpossible:` (a bats-level red run of the two P1
      tests cannot be produced locally because `bats` is not installed and `wsl` invocations are
      denied, and dispatching CI would require pushing a knowingly-red commit), an alternative
      proof section pointing at the P2-T1 transcript, `SearchScope:`, `SearchPatterns:`, and
      `SearchResult:`. Acceptance: the artifact exists and carries all six field labels.
- [ ] [P2-T3] Rewrite `classify_all_branches` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (currently lines 317-463) to the
      Design Decision above: capture `enumerate_branches` with `|| rc=$?` and return its exit
      code before emitting anything; classify every enumerated branch exactly once with the
      unchanged `classify_branch`, recording per-branch output, per-branch state, and the
      maximum return code; build the `NOT_MERGED` target list in `LC_ALL=C` order; then probe
      only for `CHILD_OF`. Delete the phase-1/phase-2a/phase-2b inheritance machinery entirely,
      including the `ancestor_targets`, `probe_failed`, and `deferred` structures. Acceptance:
      `grep -c 'ancestor_targets' scripts/bash/cleanup_worktrees_report_records_lib.sh` returns
      0, where the count is 5 before this task, so the driver no longer carries the
      inheritance data structure and cannot synthesize a `BRANCH|` state of its own.
- [ ] [P2-T4] In the same function, implement the `CHILD_OF` probe loop: for each branch X in
      `enumerate_branches` order whose recorded state is neither `PROTECTED_CURRENT` nor
      `ANCESTRY_ERROR` and which is not a member of `cleanup_wt_protected_branches`' set, probe
      `cleanup_wt_git merge-base --is-ancestor "$x" "$y"` against each Y in the `NOT_MERGED`
      target list with `Y != X`, capturing the exit code with `|| mrc=$?`; on exit 0 append
      `CHILD_OF|$x|$y` to X's recorded output and `break`; on exit 1 continue; on exit greater
      than 1 emit no `CHILD_OF` for X, leave X's `BRANCH|` line exactly as the ladder produced
      it, raise the driver's return code to at least 2, and `break`. Acceptance: the inner probe
      loop contains exactly two `break` statements — one on the exit-0 path immediately after the
      `CHILD_OF` append, and one on the exit-greater-than-1 path — so the loop cannot continue
      probing after a usable target is found (Finding R5 item a).
- [ ] [P2-T5] Update the two docstrings in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` that state the inheritance
      rationale — `cleanup_wt_protected_branches` (lines 275-290, whose text at 283-284 says a
      protected branch's verdict "must never be replaced by an inherited NOT_MERGED") and
      `classify_all_branches` (lines 317-360, whose text at 347 and 350 describes the inheritance
      and its one-level depth) — to state the advisory contract instead: every branch is
      classified by the unchanged ladder; `CHILD_OF` never determines, replaces, or modifies a
      `BRANCH|` line; a probe hard failure suppresses the record and raises the driver's return
      code without altering any verdict; and the protected-branch exclusion now suppresses the
      advisory record for a protected branch rather than protecting its verdict. Acceptance:
      `grep -c 'inherit' scripts/bash/cleanup_worktrees_report_records_lib.sh` returns 0, where
      the count is 3 before this task (lines 283, 347, 422).
- [ ] [P2-T6] Update the file-header Report line contract block in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (lines 27-30, re-derived this pass)
      so the `CHILD_OF` entry states three things: that the record is advisory only; that the
      probe direction is the one `git merge-base --is-ancestor X Y` actually tests, so the second
      field names a branch that the first field's branch is a git ancestor of, and which itself
      resolved exactly `NOT_MERGED`; and that the record is emitted alongside the branch's own
      unchanged `BRANCH|` line whatever state the ladder resolved for it. The record fields are
      not renamed and their order is not changed. The exact comment text this task writes in
      place of lines 27-30 is:

          #   CHILD_OF|<branch>|<ancestor>             advisory-only ancestry note. The second
          #                                            field names a branch that <branch> is a
          #                                            git ancestor of (the direction
          #                                            merge-base --is-ancestor <branch>
          #                                            <ancestor> tests) and which itself
          #                                            resolved exactly NOT_MERGED. Emitted
          #                                            alongside, never instead of, the branch's
          #                                            own BRANCH| line, whatever state the
          #                                            ladder resolved for that branch.

      The single-line literal this task introduces and this condition asserts is: advisory-only

      Primary acceptance:
      `grep -c 'advisory-only' scripts/bash/cleanup_worktrees_report_records_lib.sh` returns 1,
      where the count is 0 before this task (re-derived this pass over `scripts/bash/`), so the
      condition can only pass if this specific header block was rewritten. Companion acceptance:
      `grep -c 'short-circuit' scripts/bash/cleanup_worktrees_report_records_lib.sh` returns 0,
      where the count is 3 before this phase (lines 284, 350, 424, re-derived this pass). None of
      those three lines is inside this task's own region, which is why the companion condition is
      secondary: lines 284 and 350 are removed by P2-T5 and line 424 by P2-T3. The companion
      condition records that no remaining comment in the file describes the record as a
      classification short-circuit.
- [ ] [P2-T7] Add the ladder fixture keys that make `feature-child` resolve `NOT_MERGED` on its
      own in `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/`, which the
      removal of inheritance now requires: `diff-quiet.feature-child.rc` = `1`;
      `cherry.feature-child.out` = `+ deadc002`;
      `diff-tree.deadc002.out` = one tab-separated line `M<TAB>src/child.py`;
      `rev-parse.feature-child_src_child.py.out` = `blobchildAAA`;
      `rev-parse.main_src_child.py.out` = `blobmainCCC`. These mirror the proven `feature-child`
      key set in
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_merged_equivalent/`, whose test at
      `tests/shell/test_cleanup_worktrees_classification.bats:179` already asserts that key set
      resolves `NOT_MERGED`. Acceptance: the five files exist with exactly those contents, and
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/merge-base.feature-child.main.rc`
      still contains `1`.
- [ ] [P2-T8] Rewrite the assertions of the existing `@test` block at
      `tests/shell/test_cleanup_worktrees_classification.bats:153-170`, retitling it
      `child_of_not_merged: CHILD_OF is advisory and feature-child keeps its own ladder verdict`.
      Replace the three negative argv assertions that assert the expensive rungs were skipped
      (`cherry main feature-child`, `cccc4444`, `rev-list --reverse --no-merges`) with the
      positive assertion `[[ "$output" == *"cherry main feature-child"* ]]`, which proves the
      verdict came from the branch's own ladder — the same proof style the sibling test at
      `tests/shell/test_cleanup_worktrees_classification.bats:181` already uses. Retain the three
      existing positive assertions on `BRANCH|feature-child|NOT_MERGED`,
      `BRANCH|feature-parent|NOT_MERGED`, and `CHILD_OF|feature-child|feature-parent`. The block
      is rewritten, not removed: acceptance is that
      `grep -c '^@test ' tests/shell/test_cleanup_worktrees_classification.bats` returns 17,
      unchanged from P1-T4, and that the file contains no `skip` call.
- [ ] [P2-T9] Rewrite the assertions of the existing `@test` block in
      `tests/shell/test_cleanup_worktrees_classification.bats` at lines 195-207 (re-derived this
      pass), which is the Finding R2 property-(a) test. As written it compares `feature-child` under the
      `child_of_not_merged` fixture against a different branch, `feature-unmerged`, under a
      different fixture, `unmerged`, so it asserts record shape rather than value invariance for
      the branch under test. Retitle the block
      `child_of_not_merged: the driver's BRANCH line for feature-child equals classify_branch's own line`,
      so the title names value invariance rather than the short-circuit, and replace its body
      with a same-branch, same-fixture value comparison:
      `classify_all child_of_not_merged`; `[ "$status" -eq 0 ]`;
      `driver_line="$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|')"`;
      `cb child_of_not_merged feature-child`; `[ "$status" -eq 0 ]`;
      `single_line="$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|')"`;
      `[ "$driver_line" = "$single_line" ]`. The `grep` filter is required because `classify_all`
      (defined at `tests/shell/test_cleanup_worktrees_classification.bats:28-38`) deliberately
      carries no `2>/dev/null`, so bats merges the stub's `stub-git:` argv log into `$output`,
      while `cb` (lines 21-26) does suppress stderr. Acceptance:
      `grep -c '^@test ' tests/shell/test_cleanup_worktrees_classification.bats` returns 17,
      unchanged from P1-T4 and P2-T8, and the file contains no `skip` call.
- [ ] [P2-T10] Re-run the P2-T1 command against the working-tree library (not the scratchpad
      copy) and record the post-fix transcript in the same artifact
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/child-of-delete-eligible-fail-before.2026-09-07T14-49.md`
      under a `## Post-fix observation` heading with its own `Command:` and `EXIT_CODE:`.
      Acceptance: the post-fix stdout contains `BRANCH|feature-merged|MERGED_CLEAN` and
      `CHILD_OF|feature-merged|feature-unmerged`, and does not contain
      `BRANCH|feature-merged|NOT_MERGED`.

### Phase 3 — R1 and R7 item 2: Specification, Skill Contract, and Usage-Text Amendment

- [ ] [P3-T1] Replace the section titled ``The `CHILD_OF` outcome-preservation invariant`` in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      (lines 158-194) with the corrected rule and the three-case soundness analysis recorded in
      this plan's Design Decision section: the ancestor direction is unsound because a branch
      merged into `main` is an ancestor of every branch descending from `main`; the descendant
      direction establishes only rung 2; therefore no ancestry-only inference licenses skipping
      rungs 3 through 6, and `CHILD_OF` is advisory. State the outcome-preservation requirement
      in its strengthened form: for every branch X, the `BRANCH|X|<state>` line emitted by
      `classify_all_branches` is the line `classify_branch X` emits, because
      `classify_all_branches` calls `classify_branch` for every branch unconditionally.
      Acceptance: the replacement section contains the literal `advisory`, and, once P3-T3 and
      P3-T4 have also run,
      `grep -c 'short-circuited' docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      returns 0, where the count is 10 before this phase (lines 45, 60, 186, 198, 259, 312, 322,
      376, 427, 428), re-derived this pass. Lines 372 and 420 carry the literal `expensive-rung`
      rather than `short-circuited` and are therefore not in this count; they belong to the
      P3-T2 condition instead.
- [ ] [P3-T2] Amend AC3 in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      (lines 415-420, re-derived this pass) to state the advisory rule:
      `CHILD_OF|<branch>|<ancestor>` is emitted alongside the branch's own unchanged `BRANCH|`
      line when the branch is a git ancestor of another branch that resolves to exactly
      `NOT_MERGED`, and is absent when no such branch exists or when the branch is protected;
      verified by a positive/negative bats pair. State the probe direction explicitly, because
      the second field's name reads as the opposite of what the probe tests: the second field
      names a branch that `<branch>` is a git ancestor of, and which itself resolved exactly
      `NOT_MERGED`, which is the direction `git merge-base --is-ancestor <branch> <ancestor>`
      tests and the direction the existing fixture `child_of_not_merged` already exercises when
      it asserts `CHILD_OF|feature-child|feature-parent` for a `feature-child` that is the
      ancestor of `feature-parent`. Do not rename the record's fields and do not change their
      order; that is out of scope for this cycle. Remove
      the clause requiring argv-log proof that the expensive rungs were not invoked, because the
      corrected rule invokes them. Acceptance: the rewritten AC3 contains the literal `advisory`,
      and, once P3-T4 has also run,
      `grep -c 'expensive-rung' docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      returns 0, where the count is 3 before this phase (lines 322, 372, 420).
- [ ] [P3-T3] Amend AC5 in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      (lines 424-428) so property (a) reads as a per-branch value-invariance requirement over
      every branch and every verdict — the `BRANCH|X|<state>` line from `classify_all_branches`
      equals the line `classify_branch X` emits — rather than a same-shape comparison against a
      different branch under a different fixture. Name P2-T9's rewritten block
      `child_of_not_merged: the driver's BRANCH line for feature-child equals classify_branch's own line`
      as the test that verifies property (a). Property (b) keeps the apply-mode
      allowlist requirement and additionally requires a delete-eligible branch that is an
      ancestor of a `NOT_MERGED` branch to still emit its deletion `ACTION`. Acceptance: AC5
      contains the literal `child_of_delete_eligible` naming the fixture that makes it
      discriminating, and its outcome-preservation requirement is stated no more weakly than
      before (this is a strengthening edit; the reviewer checks that no requirement text was
      removed without replacement).
- [ ] [P3-T4] Amend every remaining region of
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      that describes `CHILD_OF` as a classification short-circuit or a cost-reduction mechanism,
      so that none of them does. The regions, enumerated from a `grep -n 'short-circuit'` over
      the file re-derived this pass, are: the `## Context` paragraph (line 13); the third
      `Expected:` bullet (45-47); the third `Actual:` bullet (58-60); the `CHILD_OF` bullet of
      `### In scope` (87-89); the last bullet of `### Out of scope / non-goals` (105-107); the
      first Root Cause Analysis paragraph (118-127); `### Design summary (what changes where)`
      (150-156); the first bullet of `### Boundaries and invariants to preserve` (196-198); the
      third bullet of `#### Files/modules to change` (224-226); `#### Data flow and validation
      changes` (254-259); the first bullet of `#### Error handling and logging updates`
      (262-263); the `CHILD_OF` bullet of `#### Inputs/outputs and formats` (289-291); the
      second bullet of `#### Required configuration keys and defaults` (297-304); the second
      bullet of `#### Backward-compatibility expectations` (306-315); `#### Performance
      constraints` (317-323); the first three `Required test cases` bullets (369-378); and the
      second risk bullet and second mitigation bullet of `## Risks & Mitigations` (450-471).
      In the `CHILD_OF` bullet of `#### Inputs/outputs and formats` (289-291), which is the one
      region in this list that restates the record's field contract, also state the probe
      direction explicitly: the second field names a branch that `<branch>` is a git ancestor of,
      and which itself resolved exactly `NOT_MERGED`. Do not rename the fields and do not change
      their order.
      Acceptance:
      `grep -c 'short-circuit' docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      returns exactly 1, where the count is 28
      matching lines before this task (lines 28, 45, 60, 87, 106, 119, 152, 163, 170, 174, 182,
      185, 186, 198, 259, 291, 303, 312, 318, 322, 374, 376, 426, 427, 428, 455, 457, 465,
      re-derived this pass; the six in the range 163-186 are removed by P3-T1 and the three in
      426-428 by P3-T3). The
      single permitted survivor is line 28, inside the
      verbatim quotation of the epic's C2 complexity-band assessment, which is quoted source
      text and is not rewritten; P3-T5 adds the note that supersedes it, and that note is
      phrased without the literal `short-circuit` so the count stays at 1.
- [ ] [P3-T5] Make two additions to
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`.
      First, immediately after the quoted C2 complexity-band assessment (lines 26-29), add a
      sentence recording that the quoted cost-versus-outcome claim is superseded by the corrected
      invariant section, phrased without the literal `short-circuit`. Second, add a paragraph to
      `## Rollout & Follow-up` recording that the gap 9c report-runtime-reduction objective is
      not delivered by this feature, naming the soundness reason, and stating that any future
      attempt requires its own soundness argument and its own test. Acceptance: the file contains
      the literal `not delivered` exactly once and the literal `superseded` exactly once.
- [ ] [P3-T6] Update the `CHILD_OF|<branch>|<ancestor>` bullet in
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` (lines 88-91, re-derived this pass) so
      it describes an advisory ancestry record emitted alongside the branch's own unchanged
      `BRANCH|` line, and remove the clause `records why that verdict was inherited rather than
      re-derived through the full ladder`. State the probe direction explicitly in place of the
      current wording `branch` is a git ancestor of `ancestor`, whose field naming reads as the
      opposite of what the probe tests: the second field names a branch that `branch` is a git
      ancestor of, and which itself resolved exactly `NOT_MERGED`. Do not rename the fields and
      do not change their order. Acceptance:
      `grep -c 'inherited' .claude/skills/cleanup-merged-worktrees/SKILL.md` returns 0, where the
      count is 1 before this task (line 91, re-derived this pass).
- [ ] [P3-T7] Apply the byte-identical mirror of the P3-T6 edit to
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
      Acceptance:
      `git diff --no-index .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
      prints no output and exits 0.
- [ ] [P3-T8] Run
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`
      and record the result at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/skill-md-mirror-contract.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact
      records `EXIT_CODE: 0` and an `Output Summary:` containing `1 passed`.
- [ ] [P3-T9] Edit the advisory-records paragraph in `usage()` in
      `scripts/bash/cleanup-worktrees.sh` (line 58) so the parenthetical
      `(report and apply mode; none unlocks a destructive action)` no longer heads all four
      records: scope `report and apply mode` to `CHILD_OF` alone and state that `ORPHAN_DIR`,
      `STALE_REF`, and `WARN|registration-lost` are emitted by report mode only. This is
      Finding R7 item 2. Acceptance: `bash scripts/bash/cleanup-worktrees.sh --help` exits 0 and
      its output contains the literal `report mode only`; the pre-existing usage substring test
      in `tests/shell/test_cleanup_worktrees_cli.bats`, which checks only
      `Usage: cleanup-worktrees.sh`, still passes.

### Phase 4 — R3 and R7 item 3: One Filesystem Scan per Report, Captured Before Emission

- [ ] [P4-T1] Change `scan_orphan_dirs` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (currently lines 185-232) to accept
      an optional first argument carrying pre-fetched scan records, falling back to calling
      `cleanup_wt_scan_records` itself when the argument is absent so the six existing direct
      call sites in `tests/shell/test_cleanup_worktrees_report_records.bats` keep working
      unchanged. Acceptance: the function's first statement block reads the optional argument,
      and the existing `@test` blocks at
      `tests/shell/test_cleanup_worktrees_report_records.bats:46` and `:54` are unmodified.
- [ ] [P4-T2] Apply the identical optional-argument change to `scan_registration_loss`
      (currently lines 234-273 of the same file). Acceptance: the existing `@test` blocks at
      `tests/shell/test_cleanup_worktrees_report_records.bats:62` and `:70` are unmodified.
- [ ] [P4-T3] Add a new function `report_scan_records` to
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` that calls `cleanup_wt_scan_records`
      exactly once, passes the captured records to both `scan_orphan_dirs` and
      `scan_registration_loss`, also calls `scan_stale_refs`, echoes the combined output, and
      returns the **maximum** of the three return codes (not the last one). Acceptance: the
      P4-T7 test `run_report invokes the filesystem scan exactly once` passes, which it cannot
      do while two independent `cleanup_wt_scan_records` calls remain on the report path.
      Verification of this acceptance is deferred to the Phase 12 CI-dispatch task P12-T4;
      record the named test's TAP `ok` line in that task's evidence artifact and check this task
      off at that point.
- [ ] [P4-T4] Replace the three consecutive scan calls in `run_report` in
      `scripts/bash/cleanup_worktrees_lib.sh` (lines 474-476) with a guarded parent-shell capture
      of `report_scan_records` placed **before** `check_main_freshness` (line 473), returning the
      captured non-zero code before any line is emitted, then emitting the captured output after
      `check_main_freshness`. Acceptance: `grep -n 'scan_stale_refs\|scan_orphan_dirs\|scan_registration_loss' scripts/bash/cleanup_worktrees_lib.sh`
      returns no matches, and the file's total line count is at most 500 as reported by
      `wc -l scripts/bash/cleanup_worktrees_lib.sh`.
- [ ] [P4-T5] Update the `run_report` docstring in `scripts/bash/cleanup_worktrees_lib.sh`
      (lines 451-460) so its early-abort sentence names the scan capture alongside the
      worktree-list and enumerate-branches reads, and so "maximum return code observed" is a
      true statement of the new accumulation. Acceptance: the docstring contains the literal
      `scan` inside its early-abort sentence.
- [ ] [P4-T6] Add an invocation log line `printf 'stub-scan: %s\n' "$*" >&2` to
      `tests/fixtures/cleanup_worktrees/stub-bin/scan` immediately after its `set -uo pipefail`
      line (line 22), mirroring the git stub's log at
      `tests/fixtures/cleanup_worktrees/stub-bin/git:57`, and document it in the stub's header
      comment. Acceptance: the file contains the literal `stub-scan: ` exactly once.
- [ ] [P4-T7] Add `LIB` and `DLIB` assignments for
      `scripts/bash/cleanup_worktrees_lib.sh` and `scripts/bash/cleanup_worktrees_detached_lib.sh`
      to `setup()` in `tests/shell/test_cleanup_worktrees_report_records.bats` (currently lines
      10-20, which define only `ELIB`, `RLIB`, `STUB`, `SCAN`, and `SCEN`), then append one
      `@test` block titled `run_report invokes the filesystem scan exactly once` that invokes
      `run_report` against the `orphan_dir_present` scenario with its own inline
      `run env CLEANUP_WT_GIT_BIN=... CLEANUP_WT_SCAN_BIN=... CLEANUP_WT_STUB_SCENARIO=...` line
      that **does not** append `2>/dev/null`, because the `rr()` helper at lines 22-28 discards
      stderr and the `stub-scan:` log is written to stderr. The block asserts
      `count=$(printf '%s\n' "$output" | grep -c 'stub-scan: scan-dirs')` followed by
      `[ "$count" -eq 1 ]`. Acceptance:
      `grep -c '^@test ' tests/shell/test_cleanup_worktrees_report_records.bats` returns 7 (6
      re-derived this pass, plus this one), and the new block's assertion is 1 rather than 2,
      which is what the pre-change double scan would have produced.

### Phase 5 — R5: Bounded Probe Cost, Lazy Size Computation, and Runtime Measurement

- [ ] [P5-T1] Confirm in `scripts/bash/cleanup_worktrees_report_records_lib.sh` that the probe
      target list built in P2-T4 contains only branches whose resolved state is exactly
      `NOT_MERGED`, and that the inner loop breaks on the first exit-0 probe. Acceptance: the
      P5-T5 artifact states the probe bound as a numeric product of (number of branches) x
      (number of `NOT_MERGED` branches) for the checkout it timed, and states the corresponding
      n(n-1) figure for the same branch count, so the reduction against the pre-change pairwise
      sweep is a recorded number rather than an assertion. Verification of this acceptance is
      deferred to the Phase 12 CI-dispatch task P12-T4; record the named test's TAP `ok` line in
      that task's evidence artifact and check this task off at that point, where the named test
      is the P1-T4 block
      `child_of_delete_eligible: a merged branch that is an ancestor of an unmerged branch keeps its own verdict`,
      whose pass is what demonstrates that the bounded probe still emits the advisory record.
- [ ] [P5-T2] Make the size computation lazy in `scripts/bash/cleanup_worktrees_scan_helper.sh`:
      in `scan_helper_scan_dirs` (lines 101-123) call `scan_helper_dir_size` only when
      `has_gitfile` is `0`, and emit the literal `NA` in the size field otherwise. A directory
      carrying a pointer file can never be an `ORPHAN_DIR`, because `scan_orphan_dirs` requires
      `has_gitfile == "0"` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:222`), so its
      size field is never read. Acceptance: the P5-T4 test
      `scan-dirs skips du for a directory that carries a pointer file` passes; it cannot pass
      unless the pointer-carrying rows report `NA` in the size field. Verification of this
      acceptance is deferred to the Phase 12 CI-dispatch task P12-T4; record the named test's
      TAP `ok` line in that task's evidence artifact and check this task off at that point.
- [ ] [P5-T3] Update the helper's header documentation of the `size` field
      (`scripts/bash/cleanup_worktrees_scan_helper.sh:24-26`, re-derived this pass) to state that
      `NA` is emitted for any directory carrying a pointer file. The exact comment text this task
      writes in place of lines 24-26 is:

          #   size                 best-effort `du -sh` size of <path>, or the literal `unknown`
          #                        when du fails or prints nothing. Size is advisory only, so a
          #                        du failure never fails the scan. The literal NA is emitted
          #                        instead whenever has_gitfile is 1, because scan_orphan_dirs
          #                        reads the size field only for a has_gitfile-0 row; the du
          #                        call is skipped for those rows as a size-not-read
          #                        optimization.

      The single-line literal this task introduces and this condition asserts is: size-not-read

      It is a single hyphenated token with no embedded spaces, so no comment reflow can split it
      across two lines. Acceptance:
      `grep -c 'size-not-read' scripts/bash/cleanup_worktrees_scan_helper.sh` returns 1, where
      the count is 0 before this task (re-derived this pass over `scripts/bash/`).
- [ ] [P5-T4] Append one `@test` block titled
      `scan-dirs skips du for a directory that carries a pointer file` to
      `tests/shell/test_cleanup_worktrees_scan_helper.bats`, run against
      `tests/fixtures/cleanup_worktrees/scan_roots/basic/` with
      `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit`, asserting
      `[[ "$output" == *"/good_wt|1|1|NA"* ]]`, `[[ "$output" == *"/broken_wt|1|0|NA"* ]]`,
      `[[ "$output" == *"/no_git|0|NA|"* ]]`, and `[[ "$output" != *"/no_git|0|NA|NA"* ]]`, the
      last pair proving `du` still runs for the pointer-less directory. Acceptance:
      `grep -c '^@test ' tests/shell/test_cleanup_worktrees_scan_helper.bats` returns 2 (1
      re-derived this pass, plus this one).
- [ ] [P5-T5] Time three consecutive report-mode runs of the modified tool with
      `time bash scripts/bash/cleanup-worktrees.sh report > /dev/null` and record them, the
      P0-T13 "before" durations, the branch count, the derived probe bound from P5-T1, and an
      explicit statement of whether the new report-mode cost is above or below the pre-change
      cost, at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/report-runtime-after.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact
      records three numeric "after" durations and a directional comparison against the three
      "before" durations, so the gap 9c objective is falsifiable from the recorded numbers.

### Phase 6 — R6: Error-Path and Edge-Case Coverage

- [ ] [P6-T1] Create scenario `tests/fixtures/cleanup_worktrees/scenarios/scan_hard_failure/`
      containing `scan-dirs.rc` = `3` and `worktree-list.out` copied from
      `tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_present/worktree-list.out`. Append
      two `@test` blocks to `tests/shell/test_cleanup_worktrees_report_records.bats` asserting
      that `scan_orphan_dirs` and `scan_registration_loss` each return status 3 and produce empty
      stdout under this scenario. Acceptance: both new tests exist and the file's `^@test ` count
      is 9.
- [ ] [P6-T2] Create scenario `tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_unknown_size/`
      containing `scan-dirs.out` with the single line `.claude/worktrees/agent-nosize|0|NA|`
      (empty fourth field) and `worktree-list.out` copied from `orphan_dir_present`. Append one
      `@test` block to `tests/shell/test_cleanup_worktrees_report_records.bats` asserting
      `[ "$output" = "ORPHAN_DIR|.claude/worktrees/agent-nosize|unknown" ]`. This is the
      spec-named unresolvable-size edge case
      (`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md:385-386`).
      Acceptance: the file's `^@test ` count is 10.
- [ ] [P6-T3] Create scenarios
      `tests/fixtures/cleanup_worktrees/scenarios/stale_ref_read_failure/` containing
      `for-each-ref.refs_remotes_.rc` = `3`, and
      `tests/fixtures/cleanup_worktrees/scenarios/stale_ref_remote_failure/` containing
      `for-each-ref.refs_remotes_.out` (one line `refs/remotes/upstream/feature-old`) and
      `remote.rc` = `3`. Append two `@test` blocks to
      `tests/shell/test_cleanup_worktrees_report_records.bats` asserting `scan_stale_refs`
      returns status 3 with empty stdout in each case, covering the two hard-failure returns at
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:80-83` and `:84-88`. Acceptance: the
      file's `^@test ` count is 12.
- [ ] [P6-T4] Append two `@test` blocks to `tests/shell/test_cleanup_worktrees_report_records.bats`
      for `cleanup_wt_scan_roots`: one with `CLEANUP_WT_ORPHAN_ROOTS="/a:/b"` asserting the
      output is exactly the two lines `/a` and `/b` (covering the override branch at
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:122-130`), and one under a scenario
      whose `worktree-list.rc` is `3` asserting status 0 and output exactly `.claude/worktrees`
      (covering the `parse_worktree_list` hard-failure branch at line 133-136). Create scenario
      `tests/fixtures/cleanup_worktrees/scenarios/worktree_list_failure/` with
      `worktree-list.rc` = `3` for the second test. Acceptance: the file's `^@test ` count is 14.
- [ ] [P6-T5] Append one `@test` block to `tests/shell/test_cleanup_worktrees_report_records.bats`
      asserting `cleanup_wt_scan_records` returns 0 and emits nothing when
      `CLEANUP_WT_ORPHAN_ROOTS=":"` yields zero roots, covering
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:160-162`. Acceptance: the file's
      `^@test ` count is 15.
- [ ] [P6-T6] Append two `@test` blocks to `tests/shell/test_cleanup_worktrees_scan_helper.bats`:
      one invoking the helper through `run env -u CLEANUP_WT_SCAN_GITFILE_NAME bash "${HELPER}"
      scan-dirs "${ROOTS}"` against `tests/fixtures/cleanup_worktrees/scan_roots/basic/`,
      asserting `[[ "$output" == *"/good_wt|0|NA|"* ]]` and `[[ "$output" != *"|1|"* ]]` because
      the fixture names its pointer files `dotgit` and carries no file named `.git` (covering the
      default-name branch at `scripts/bash/cleanup_worktrees_scan_helper.sh:64-70`); and one
      invoking
      `bash scripts/bash/cleanup_worktrees_scan_helper.sh not-a-subcommand`, asserting status 2
      and that stderr contains `Usage: cleanup_worktrees_scan_helper.sh scan-dirs` (covering
      `scan_helper_usage` and the dispatch default at lines 125-133 and 144-147). Acceptance:
      the file's `^@test ` count is 4.
- [ ] [P6-T7] Add a fixture directory
      `tests/fixtures/cleanup_worktrees/scan_roots/unreadable/no_gitdir_line/` containing a file
      named `dotgit` whose contents are the single line `not-a-gitdir-pointer`, and append one
      `@test` block to `tests/shell/test_cleanup_worktrees_scan_helper.bats` run with
      `CLEANUP_WT_SCAN_GITFILE_NAME=dotgit` against the root
      `tests/fixtures/cleanup_worktrees/scan_roots/unreadable/`, asserting
      `[[ "$output" == *"/no_gitdir_line|1|NA|NA"* ]]`: `has_gitfile` is 1, the unresolvable
      pointer yields `NA` rather than `0`, and the size field is `NA` per P5-T2. This is the
      spec-named unreadable-pointer edge case
      (`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md:386-387`)
      and depends on the P7-T3 behavior change. Acceptance: the file's `^@test ` count is 5.
- [ ] [P6-T8] Append two `@test` blocks to
      `tests/shell/test_cleanup_worktrees_classification.bats` for `classify_all_branches`
      hard-failure and empty-input paths: one under a scenario whose
      `for-each-ref.refs_heads_.rc` is `3` asserting the driver returns 3 with no `BRANCH|` line
      (covering `scripts/bash/cleanup_worktrees_report_records_lib.sh:362-365`), and one under a
      scenario whose `for-each-ref.out` is a checked-in empty file, asserting status 0 and empty
      stdout (covering lines 372-374; `enumerate_branches` emits nothing and returns 0 for an
      empty ref list, `scripts/bash/cleanup_worktrees_enumerate_lib.sh:80-82`). Create scenarios
      `tests/fixtures/cleanup_worktrees/scenarios/enumerate_failure/` (holding only
      `for-each-ref.refs_heads_.rc` = `3`, which the stub's pattern-specific branch at
      `tests/fixtures/cleanup_worktrees/stub-bin/git:113-119` selects ahead of the bare key) and
      `tests/fixtures/cleanup_worktrees/scenarios/no_branches/` (holding only an empty
      `for-each-ref.out`, which the stub's `refs/heads/` fallback at
      `tests/fixtures/cleanup_worktrees/stub-bin/git:120-122` selects). Acceptance: the file's
      `^@test ` count is 19.
- [ ] [P6-T9] Append one `@test` block to `tests/shell/test_cleanup_worktrees_report_records.bats`
      for `cleanup_wt_protected_branches` under a scenario whose `worktree-list.rc` is `3`,
      asserting the function returns 3 and emits no branch names, covering
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:301-304`. Reuse the
      `worktree_list_failure` scenario created in P6-T4. Acceptance: the file's `^@test ` count
      is 16.

### Phase 7 — R7 items 1, 4, and 5: Remaining Contract and Robustness Defects

- [ ] [P7-T1] Change `cleanup_wt_scan_roots` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (line 131) so the agent-worktree
      root is resolved against `cleanup_wt_git rev-parse --show-toplevel` rather than emitted as
      the CWD-relative literal `.claude/worktrees`: capture the toplevel with `|| rc=$?`, and
      when it resolves to a non-empty value emit `<toplevel>/.claude/worktrees`, otherwise emit
      the bare `.claude/worktrees` so scenarios that supply no `rev-parse.show-toplevel.out` are
      unaffected. Acceptance:
      `grep -c 'show-toplevel' scripts/bash/cleanup_worktrees_report_records_lib.sh` returns at
      least 1, where the count is 0 before this task; and the two existing `@test` blocks at
      `tests/shell/test_cleanup_worktrees_report_records.bats:46` and `:54` still pass, because
      the scan stub replays canned `scan-dirs` records regardless of the root arguments passed
      to it.
- [ ] [P7-T2] Append one `@test` block to `tests/shell/test_cleanup_worktrees_report_records.bats`
      asserting `cleanup_wt_scan_roots` emits `/repo/main/.claude/worktrees` as its first line
      under a scenario supplying `rev-parse.show-toplevel.out` = `/repo/main`. Reuse
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_delete_eligible/`, which P1-T1 gives
      that exact key. Acceptance: the file's `^@test ` count is 17.
- [ ] [P7-T3] Change `scan_helper_gitdir_target_exists` in
      `scripts/bash/cleanup_worktrees_scan_helper.sh` (lines 72-99) to echo `NA` instead of `0`
      when the pointer file cannot be resolved to a target — that is, when the `grep` capture
      returns non-zero or the extracted target is empty after stripping. A resolvable target
      keeps the existing `1`/`0` outcome. `scan_registration_loss` emits its record only when
      the field is exactly `0` (`[[ $target_exists == "0" ]] || continue`,
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:266`), so an `NA` field is skipped
      with no code change there, which makes
      "pointer present but unreadable" skipped silently as
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md:386-387`
      requires. Acceptance: the function contains exactly one `printf '0\n'` call site, which is
      the resolved-but-missing-target case, and the existing `@test` at
      `tests/shell/test_cleanup_worktrees_scan_helper.bats:23` still asserts `/broken_wt|1|0|`.
- [ ] [P7-T4] Guard the `printf '%s\n' "$cb_out"` at
      `scripts/bash/cleanup_worktrees_actions_lib.sh:401` on non-empty `cb_out`, so a branch
      absent from the shared driver's output no longer emits a blank line; and treat an empty
      `cb_out` as a hard failure that sets `rc=1` and continues without any deletion, alongside
      the existing `ANCESTRY_ERROR` case at lines 403-408. The guard the task writes is the
      literal `[[ -n $cb_out ]]`. Acceptance:
      `grep -c 'cb_out ]]' scripts/bash/cleanup_worktrees_actions_lib.sh` returns 1, where the
      count is 0 before this task, and `bash scripts/bash/shell-qc.sh check` still exits 0.
- [ ] [P7-T5] Record the explicit disposition of the remaining half of Finding R7 item 4 — the
      per-branch status channel from the driver — at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/r7-4-per-branch-status-disposition.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The disposition states that
      the channel is not added because no deletion is unlocked by the narrow check (the
      `HAS_UNIQUE_RESIDUALS` state that `classify_branch` can pair with return code 2 is not on
      the allowlist at `scripts/bash/cleanup_worktrees_actions_lib.sh:409-414`) and the driver's
      aggregate return code already propagates every hard failure to `rc` at lines 386-389, which
      the remediation-inputs itself records as "Latent, not active". Acceptance: the artifact
      exists with all four fields and cites both line ranges.

### Phase 8 — R4: Ordered Stub Backward-Compatibility Regression Gate

- [ ] [P8-T1] Materialize the base-branch version of the shared git stub into the session
      scratchpad with
      `git show 6dff80ed4596bec088d548b23013e6077e32c484:tests/fixtures/cleanup_worktrees/stub-bin/git > <scratchpad>/git-base`
      and `chmod +x <scratchpad>/git-base`. Acceptance: the scratchpad file exists and its
      `for-each-ref)` case contains no `pattern_key` variable, confirming it predates the
      key-specificity edit. No file inside the repository is created or modified by this task.
- [ ] [P8-T2] Run the differential sweep that proves the two stub key edits are pure additive
      fallbacks. For every scenario directory under
      `tests/fixtures/cleanup_worktrees/scenarios/` and
      `tests/fixtures/cleanup_worktrees/deletion/` that existed at
      `6dff80ed4596bec088d548b23013e6077e32c484` (enumerate them with
      `git ls-tree --name-only 6dff80ed4596bec088d548b23013e6077e32c484 tests/fixtures/cleanup_worktrees/scenarios/ tests/fixtures/cleanup_worktrees/deletion/`),
      invoke both stubs with `CLEANUP_WT_STUB_SCENARIO` set to that directory for (a)
      `for-each-ref --format=%(refname:short) %(objectname:short) refs/heads/` and (b)
      `merge-base --is-ancestor <branch> main` for every branch named in that scenario's
      `for-each-ref.out`, comparing stdout and exit code between `<scratchpad>/git-base` and
      `tests/fixtures/cleanup_worktrees/stub-bin/git`. These two argv shapes are the only ones
      the two edited cases handle. Acceptance: every comparison is identical, reported as a
      single `NO_DIFF` result with the number of scenario directories and the number of
      comparisons performed.
- [ ] [P8-T3] Record the ordered gate at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/stub-git-backward-compat.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying: the P8-T2
      `NO_DIFF` result with its two counts; the full-suite result and total test count recorded
      in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-test.2026-09-07T14-49.md`
      (P0-T10), which was run on a tree that already carries both stub key edits and is therefore
      the full existing-suite run the spec's Manual validation step requires, and which must
      report at least the 321 tests recorded in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test.2026-09-06T23-03.md`;
      a statement that the ordered intermediate-tree run was re-derived by the P8-T2 differential
      rather than by reconstructing the intermediate commit, because the work landed as a single
      squashed commit; and an explicit statement that both stub edits pass every pre-existing
      scenario unchanged. Acceptance: the artifact exists with all four fields, states the
      `NO_DIFF` result with its two counts, and states a numeric test count of at least 321.

### Phase 9 — Exit Criterion 2: Outcome-Preservation Sweep Across All Scenarios

- [ ] [P9-T1] Materialize the base-branch versions of `scripts/bash/cleanup_worktrees_lib.sh`,
      `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
      `scripts/bash/cleanup_worktrees_actions_lib.sh`, and
      `scripts/bash/cleanup_worktrees_detached_lib.sh` from
      `6dff80ed4596bec088d548b23013e6077e32c484` into the session scratchpad, following the
      method already recorded in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/scan-seam-call-site-verification.2026-09-06T23-03.md`.
      Acceptance: the four scratchpad files exist and none of them references
      `classify_all_branches`.
- [ ] [P9-T2] For every scenario directory that existed at
      `6dff80ed4596bec088d548b23013e6077e32c484` under
      `tests/fixtures/cleanup_worktrees/scenarios/` and
      `tests/fixtures/cleanup_worktrees/deletion/`, run `run_report` under the base libraries and
      under the current tree and compare stdout and exit code byte for byte. Acceptance: the
      comparison reports `NO_DIFF [run_report]` across every pre-existing scenario directory,
      with the directory count stated.
- [ ] [P9-T3] Repeat P9-T2 for `run_apply`. Acceptance: the comparison reports
      `NO_DIFF [run_apply]` across every pre-existing scenario directory, with the directory
      count stated.
- [ ] [P9-T4] For the three `child_of_*` scenarios and the new `child_of_delete_eligible`
      scenario, compare the base-library and current-tree `run_report` output after filtering
      out lines beginning `CHILD_OF|` from the current-tree output. Acceptance: the filtered
      current-tree output is byte-identical to the base-library output for all four scenarios,
      which is the direct demonstration that `CHILD_OF` is purely additive and changes no
      verdict. Note in the artifact that `child_of_not_merged` requires the P2-T7 fixture keys
      to be present in both runs, since fixture files are shared between the two library
      versions.
- [ ] [P9-T5] Record P9-T2 through P9-T4 at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/outcome-preservation-sweep.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` naming the three results and
      the scenario counts. Acceptance: the artifact exists with all four fields and contains the
      literals `NO_DIFF [run_report]` and `NO_DIFF [run_apply]`.

### Phase 10 — R8: Prior-Plan Checklist Reconciliation and Deferred Plan-Mandated Artifacts

- [ ] [P10-T1] In
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md`,
      change the checkbox from `[ ]` to `[x]` for exactly these ten tasks, whose described tests
      exist and pass: `[P1-T4]` (line 153), `[P1-T6]` (167), `[P1-T7]` (174), `[P3-T4]` (269),
      `[P4-T4]` (301), `[P5-T4]` (327), `[P6-T4]` (406), `[P6-T5]` (421), `[P7-T4]` (522),
      `[P7-T5]` (530). Leave `[P2-T3]` (231) unchecked at this task; it is closed by P10-T2.
      Note in the plan's revision log that the remediation-inputs Finding R8 counts eleven
      unchecked Phase 1-7 tasks, which is the ten above plus `[P2-T3]`, and that `[P2-T3]` is
      handled separately because the same finding text names it as genuinely outstanding.
      Acceptance:
      `grep -c '^- \[ \] \[P[1-7]-' docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md`
      returns 1, the remaining `[P2-T3]` line, where the count is 11 before this task.
- [ ] [P10-T2] Check off `[P2-T3]` in the same file once
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/stub-git-backward-compat.2026-09-07T14-49.md`
      exists (Phase 8). Acceptance:
      `grep -c '^- \[ \] \[P[1-7]-' docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md`
      returns 0.
- [ ] [P10-T3] Run `wc -l` over `scripts/bash/cleanup_worktrees_lib.sh`,
      `scripts/bash/cleanup_worktrees_report_records_lib.sh`,
      `scripts/bash/cleanup_worktrees_scan_helper.sh`,
      `scripts/bash/cleanup_worktrees_actions_lib.sh`,
      `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, and
      `scripts/bash/cleanup-worktrees.sh` and record all six counts at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/file-size-cap-verification.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: every recorded
      count is at most 500, and the artifact states each count numerically. This closes the prior
      plan's `[P10-T1]`.
- [ ] [P10-T4] Record the AC11 generic-detection confirmation at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/ac11-generic-detection-confirmation.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The evidence is the output
      of `grep -rn "child" scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup_worktrees_scan_helper.sh`
      restricted to matches that are not the substring `CHILD_OF` or `feature-child`, plus a
      statement that `scan_stale_refs` derives the remote name from the ref itself
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:98-99`) and compares it against the
      configured remote set rather than any hardcoded name, and that no test asserts a fixed
      count of orphan directories or stale refs. Acceptance: the artifact exists with all four
      fields and records zero hardcoded-`child` matches in the two production files. This closes
      the prior plan's `[P10-T2]`.

### Phase 11 — R9: PR Autoclose Scope Determination

- [ ] [P11-T1] Regenerate the PR context by running the collector module directly, so this task
      is executable by the assigned agent: run
      `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/cleanup-merged-worktrees-hardening-integration --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt --repo-root .`.
      The module exposes exactly these options through `parse_args`
      (`scripts/dev_tools/pr_context/collector.py:419-455`) and is CLI-invokable through its
      `if __name__ == "__main__": main()` guard (`collector.py:473-474`), both re-derived this
      pass. The MCP tool `mcp__drm-copilot__collect_pr_context` is deliberately not used here: it
      is not in the `atomic-executor` tool allowlist (`.claude/agents/atomic-executor.md:5-24`,
      which lists only the four `run_poshqc_*` MCP tools), so a task naming it would not be
      executable by the agent this plan is written for. Acceptance: the command exits 0 and the
      regenerated `artifacts/pr_context.summary.txt` contains the section header
      `===== Close candidates =====` — the exact rendering `section("Close candidates")`
      produces, given `SECTION_LINE = "===== {title} ====="`
      (`scripts/dev_tools/pr_context/models.py:12`) and the call site
      `scripts/dev_tools/pr_context/render_pr_helpers.py:215` — and, beneath it, the line
      `Auto-close issues (author asserted):` (`render_pr_helpers.py:219`), whose entries are
      transcribed verbatim into the P11-T2 artifact.
- [ ] [P11-T2] Record the autoclose scope determination at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/pr-autoclose-scope.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. It states that the
      "Auto-close issues (author asserted)" list is derived by
      `scripts/dev_tools/pr_context/collector.py:239-241` from detected issue references, that
      `#630` and `#545` enter that list only as out-of-scope narrative references in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md:100-114`,
      that neither is fixed by this branch, and that the PR body's closing list must therefore
      read `Closes #631` and name no other issue. Acceptance: the artifact exists with all four
      fields and contains the literal `Closes #631` exactly once as the sanctioned list.

### Phase 12 — Final QA Loop and Convergence

Run the four toolchain stages in order — format (P12-T1), lint (P12-T2), test (P12-T4), test
with coverage (P12-T5) — with the branch push P12-T3 interposed before the two Route-rule
dispatch stages so the dispatched CI run sees the commits Phases 1 through 11 added. If any
stage fails or rewrites a tracked file, restart from P12-T1. Every task below executes its
stated command; `SKIPPED` is not a valid outcome for any of them. The single exception is the
one `git commit` invocation inside P12-T3, whose skip branch that task's own text explicitly
authorizes and bounds.

- [ ] [P12-T1] Run `bash scripts/bash/shell-qc.sh format`. Because this is a write-mode command
      that prints nothing on a clean run (`scripts/bash/shell_qc_lib.sh:204-224`), immediately
      run `git status --porcelain -- scripts/bash tests/shell tests/fixtures` and record its
      output as the observation that distinguishes a clean run from a repairing one. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-format.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0`
      and the `Output Summary:` states whether the porcelain output listed any file; if it listed
      any, the loop restarts at P12-T1 after the rewritten files are committed to the working
      tree state.
- [ ] [P12-T2] Run `bash scripts/bash/shell-qc.sh check`. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-check.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` naming the shfmt diff count
      and the shellcheck finding count. Acceptance: `EXIT_CODE: 0` with zero shfmt diffs and zero
      shellcheck findings.
- [ ] [P12-T3] Re-commit the working tree (which includes `scripts/bash` and `tests/shell`) and
      re-push the branch so the Route-rule dispatch in P12-T4 and P12-T5 runs against the commits
      added by Phases 1 through 11, which the P0-T9 push predates. Run
      `git add -A`; then `git status --porcelain` and record its output; then
      `git commit -m "fix(631): remediation cycle 1 for report-mode visibility gaps"` — this
      single `git commit` invocation is skipped when, and only when, the recorded porcelain
      output is empty, which is the same explicitly authorized skip branch stated in P0-T9; then
      `git push origin local-work-631-r2:bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`;
      then `git rev-parse HEAD`,
      `git rev-parse origin/bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`, and
      `git diff --stat 6dff80ed4596bec088d548b23013e6077e32c484..HEAD`. Record every command and
      its output at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/branch-push-before-final-dispatch.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact
      exists with all four fields; the SHA recorded for `HEAD` is byte-identical to the SHA
      recorded for `origin/bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`; and the
      recorded `git diff --stat` output, which is anchored to the base commit rather than to the
      index, names at least `scripts/bash/cleanup_worktrees_report_records_lib.sh` and
      `tests/shell/test_cleanup_worktrees_classification.bats`.
- [ ] [P12-T4] Run `bash scripts/bash/shell-qc.sh test` under the Route rule in this plan's
      header. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` carrying the total planned
      test count and the passed/failed tally. Acceptance: `EXIT_CODE: 0`, zero failed tests, and
      a total count of at least 354 — the 335 blocks re-derived this pass plus the 19 blocks
      added by P1-T4, P1-T5, P4-T7, P5-T4, P6-T1 (2), P6-T2, P6-T3 (2), P6-T4 (2), P6-T5,
      P6-T6 (2), P6-T7, P6-T8 (2), P6-T9, and P7-T2.
- [ ] [P12-T5] Run `bash scripts/bash/shell-qc.sh test --coverage` under the Route rule. Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test-coverage.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0`
      and the `Output Summary:` carries the literal line `Bash coverage (lines): NN.N%` copied
      verbatim from the run with a value of at least 85.0, recorded alongside the 94.2% baseline
      from
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/baseline/baseline-test-coverage.2026-09-06T23-03.md`.
- [ ] [P12-T6] From the `cov.xml` produced by P12-T5, extract the `line-rate` for the `<class>`
      entries whose `filename` ends in `cleanup_worktrees_report_records_lib.sh` and
      `cleanup_worktrees_scan_helper.sh`, and compare each against the corresponding value
      recorded in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-per-file-coverage.2026-09-07T14-49.md`.
      Record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-per-file-coverage.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: neither
      per-file line rate is lower than its P0-T12 value, and the artifact states all four
      numbers.
- [ ] [P12-T7] Confirm P12-T1 through P12-T6 completed in a single pass with no restart, and
      record the confirmation, the ordered list of the six steps, and the restart count at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-loop-single-pass.2026-09-07T14-49.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact
      records a restart count and, if that count is greater than zero, the loop is re-run from
      P12-T1 until a pass with restart count zero is recorded.
- [ ] [P12-T8] Verify that no evidence artifact produced by this cycle lives outside
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/`
      by running
      `ls -d artifacts/baselines artifacts/baseline artifacts/qa artifacts/qa-gates artifacts/evidence artifacts/coverage artifacts/regression-testing artifacts/post-change 2>/dev/null`.
      A directory-listing check is used rather than a `git status` check because `artifacts/` is
      subject to ignore rules, so a porcelain listing could report nothing whether or not a
      forbidden directory exists. Acceptance: the command produces no output, i.e. none of the
      eight forbidden directories exists. `artifacts/pr_context.summary.txt` and
      `artifacts/orchestration/` are permitted and expected.
- [ ] [P12-T9] Update the `## Acceptance Criteria` checkboxes in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      so each of the eleven criteria is either `[x]` with the evidence artifact path named
      inline, or left `[ ]` with an explicit inline note recording it as unmet and why. This
      task runs last because the artifacts it cites, in particular
      `.../evidence/qa-gates/final-test-coverage.2026-09-07T14-49.md` for AC9, do not exist
      until P12-T5 completes. Acceptance: no criterion is left `[ ]` without an inline unmet
      note; the P12-T5 coverage artifact path appears against AC9; the P9-T5 sweep artifact path
      appears against AC5; and the P8-T3 artifact path appears against AC6.
