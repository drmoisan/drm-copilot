# cleanup-worktrees-report-mode-visibility-gaps (Remediation Plan)

- **Issue:** #631
- **Branch:** `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
- **Parent:** Epic `cleanup-merged-worktrees-hardening`, child B
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07T14-40
- **Status:** Draft — preflight revision round 3 applied in place (same file path; no sibling plan
  file was created)
- **Version:** 2.0 (remediation cycle following feature-review)
- **Work Mode:** full-bug (`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/issue.md:12`)
- **AC source:** `spec.md` `## Acceptance Criteria` (11 items); this cycle closes AC3 and AC5
- **Remediation source:** `remediation-inputs.2026-09-07T14-40.md` (R-01 blocking, R-02, R-04)
- **Predecessor plan:** `plan.2026-09-06T23-03.md` (retained; not edited by this cycle)

**Fail-closed evidence rule:** every baseline, regression, and final-QA artifact required below must
exist with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields before its owning
task may be checked off. A missing or incomplete artifact leaves the task unchecked.

**Evidence location:** all evidence in this plan resolves under
`docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/<kind>/`
(`remediation-baseline/`, `regression-testing/`, `qa-gates/`, `other/`). No `artifacts/`-rooted
evidence path is used anywhere in this plan.

---

## Execution-role split (mandatory; this session's tool grants)

This session's Bash tool denies any `wsl` invocation outright, and no `bats` or `kcov` binary exists
on the Windows PATH. The `atomic-executor` delegate additionally has no Bash grant reaching `bash`,
`wsl`, `bats`, `shfmt`, or `shellcheck`. Every task below therefore carries an explicit owner tag:

- `[EXECUTOR]` — file authoring and editing only, using Read/Grep/Glob/Edit/Write. The executor MUST
  NOT attempt any command beginning `bash`, `wsl`, `bats`, `shfmt`, `shellcheck`, `kcov`, `wc`, or
  `poetry`. Acceptance conditions for these tasks are file-content observations the executor can make
  with Read and Grep.
- `[ORCHESTRATOR-RUN]` — the orchestrator runs the command itself and writes the evidence artifact.
  Local commands (`bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`,
  `wc -l`, `git status --porcelain`, `poetry run pytest`) run in the orchestrator's own session, where
  `shfmt` and `shellcheck` are on the Windows PATH. The `test` and `test --coverage` stages are not
  runnable locally (no `bats`, no `kcov`), so they run through
  `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
  and the orchestrator reads the resulting run log.

The `_shell-coverage.yml` workflow (verified at `.github/workflows/_shell-coverage.yml:51-55`) runs
exactly two shell-qc stages: `bash scripts/bash/shell-qc.sh check` and
`bash scripts/bash/shell-qc.sh test --coverage`. There is no separate non-coverage `test` step, and
`run_test_coverage` (`scripts/bash/shell_qc_lib.sh:294`) executes the same bats suites under kcov that
`run_test` (`scripts/bash/shell_qc_lib.sh:226`) executes bare. The `test`-stage evidence in this plan
is therefore taken from the bats TAP totals printed by the `Run shell-qc test with coverage` step of
the dispatched run, and each such artifact records `Command: bash scripts/bash/shell-qc.sh test --coverage`
— the command actually executed — rather than a command that was not run.

`gh workflow run --ref <branch>` dispatches branch HEAD only. Every `[ORCHESTRATOR-RUN]` dispatch task
below is therefore preceded by a commit and push of the phase's work, and the artifact records the
dispatched commit sha.

---

## Design decisions settled by this plan (not left to the executor)

### D1 — The `CHILD_OF` verdict short-circuit is removed; the record becomes informational

R-01 requires that the short-circuit "must not fire for a branch that the unchanged ladder would
resolve to any state other than `NOT_MERGED`." The plan establishes below that **no cut point in
`classify_branch`'s ladder satisfies that requirement**, and therefore removes verdict inheritance
entirely rather than moving the cut.

The claim under test is: *`X` is a git ancestor of `Y`, and `Y` resolved exactly `NOT_MERGED`,
therefore `X` resolves `NOT_MERGED`.* Counterexamples exist at three successive rungs
(`classify_branch`, `scripts/bash/cleanup_worktrees_lib.sh:313-448`):

- **Rung 2 (`classify_ancestry`, `cleanup_worktrees_lib.sh:57-78`).** `X` merged into `main` by a merge
  commit is an ancestor of `main`, so rung 2 yields `MERGED_CLEAN`. `X` is simultaneously a git
  ancestor of any branch `Y` created from a `main` that already contains `X`'s merge. This is CR-01's
  Evidence 2 and the ordinary steady state of this repository.
- **Rung 3 (`classify_content_neutral`, `cleanup_worktrees_lib.sh:80-103`).** `X` whose net diff
  against `main` is empty yields `MERGED_CONTENT_NEUTRAL` while still being an ancestor of an unmerged
  `Y`. This is CR-01's Evidence 1, reproducible in the feature's own `child_of_not_merged` fixture,
  which supplies no `diff-quiet.feature-child.rc` (verified: the file is absent from
  `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/`).
- **Rung 5 (`classify_residual_commit`, `cleanup_worktrees_lib.sh:190-257`).** This rung decides each
  residual commit by comparing the **branch tip's** blob against `main`'s
  (`_blob_equal "$branch" main "$relpath"`, `cleanup_worktrees_lib.sh:228` and `:246`). `X`'s tip and
  `Y`'s tip are different trees, so the same residual commit can resolve `CONTENT_ON_MAIN` for `X` and
  `UNIQUE` for `Y`. Worked case: `X` squash-merged onto `main` (so `main:f` equals `X:f`, but no
  patch-id matches and rung 4 marks the commit `+`), with `Y` = `X` plus a later commit that changes
  `f` again. `Y` resolves `NOT_MERGED`; `X` resolves `MERGED_EQUIVALENT`
  (`cleanup_worktrees_lib.sh:423-427`), which is on the apply-mode delete-eligible allowlist
  (`scripts/bash/cleanup_worktrees_actions_lib.sh:409-412`).

Rung 4's `git cherry` marker set is also not inheritable, because `git cherry`'s upstream-side commit
set for `X` is a superset of the one for `Y` whenever `Y` contains `main` commits that `X` lacks; a
cherry-picked ancestor is the counterexample the remediation inputs flag. But rung 5 is decisive on its
own: it is the last rung before the verdict, it is expensive, and it cannot be derived from `Y`'s
result under any topology. **There is no sound cut point.** The chosen cut is therefore "no rungs are
skipped", and D1 is pinned by three executable fixtures (one per delete-eligible state) authored in
Phase 2, not asserted in prose alone.

Consequence for the record: `CHILD_OF|<branch>|<ancestor>` is retained as an advisory, informational
report line. It is emitted when `<branch>` is a git ancestor of `<ancestor>` and **both** resolved
exactly `NOT_MERGED` through their own unchanged ladders. Its emission condition and its wire shape are
unchanged from the shipped implementation; only the claim that it licensed skipping work is withdrawn.
The outcome-preservation invariant becomes provable by construction: the `BRANCH|` line the driver
emits is the byte-identical line `classify_branch` produced.

### D2 — The pairwise ancestry probe is restricted to `NOT_MERGED` branches

Because no verdict is inherited, the pairwise `merge-base --is-ancestor` probe no longer needs to run
before classification. `classify_all_branches` classifies every branch first, then probes only ordered
pairs `(X, Y)` where both `X` and `Y` resolved exactly `NOT_MERGED`. This removes the deferral
machinery entirely and reduces the probe count from `n*(n-1)` to `k*(k-1)`, where `k` is the number of
`NOT_MERGED` branches. This is a direct consequence of D1, not an independent optimization, and it is
what keeps the file within its size budget after the rewrite.

A hard failure (exit above 1) of a probe in the new position must not overwrite an already-correct
`BRANCH|` verdict, since that would itself violate outcome preservation. It therefore emits no
`CHILD_OF` record for that pair, leaves the branch's own `BRANCH|` line untouched, and raises the
driver's return code to 2 so the failure still surfaces in the exit status. A hard failure of the
ladder's own rung-2 probe continues to map to `BRANCH|<name>|ANCESTRY_ERROR` inside `classify_branch`,
unchanged.

### D3 — `cleanup_wt_protected_branches` is removed

`cleanup_wt_protected_branches` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:275-315`) exists
solely to stop a protected branch from inheriting `NOT_MERGED`; its own header states that rationale.
With inheritance removed, `main` is excluded automatically: its ladder verdict is `PROTECTED_CURRENT`,
which is not `NOT_MERGED`, so it never enters the probe set under D2. The function becomes unreachable
dead code and is deleted rather than left to depress coverage.

### D4 — One filesystem scan per report, hoisted into a shared driver in the sibling library

`scan_orphan_dirs` (`cleanup_worktrees_report_records_lib.sh:200`) and `scan_registration_loss`
(`:253`) each call `cleanup_wt_scan_records` independently, and `run_report`
(`scripts/bash/cleanup_worktrees_lib.sh:474-476`) calls both. Both functions gain an optional first
parameter carrying pre-scanned records; when the parameter is absent they scan for themselves, which
keeps the six existing single-function bats tests
(`tests/shell/test_cleanup_worktrees_report_records.bats:30-75`) valid unchanged.

The single scan is performed by a new `run_report_scans` in the sibling library, which scans once and
calls `scan_stale_refs`, then `scan_orphan_dirs`, then `scan_registration_loss` in that order.
`run_report` replaces its three call lines with one call to `run_report_scans`. Placing the hoist in
the sibling library rather than inline in `run_report` preserves the documented emission order, keeps
the new logic in the file that owns it, and reduces `cleanup_worktrees_lib.sh` by two lines against a
verified current count of 491 (AC8's cap is 500).

### D5 — Both scan roots derive from the main worktree path

`cleanup_wt_scan_roots` (`cleanup_worktrees_report_records_lib.sh:110-143`) prints the bare relative
string `.claude/worktrees` at line 131, before reading `parse_worktree_list` at line 133. The `printf`
moves after that read and becomes `"${main_wt}/.claude/worktrees"`, alongside the existing
`"${main_wt}-wt"` derivation at line 140, so both roots share one derivation and one failure path. When
`parse_worktree_list` hard-fails, the function emits no root at all; `cleanup_wt_scan_records` already
returns 0 with no record for an empty root list (`:160-162`), so the advisory records degrade to
silence rather than to a misleading CWD-relative scan. The `CLEANUP_WT_ORPHAN_ROOTS` override branch
(`:122-130`) is unchanged.

**Correction to the review artifacts:** CR-04 and R-04 both state that "only the
`CLEANUP_WT_ORPHAN_ROOTS` override branch is currently exercised". Re-derived against the current tree,
the opposite is true: a repository-wide search for the literal `CLEANUP_WT_ORPHAN_ROOTS` under `tests/`
returns no match, and no test names `cleanup_wt_scan_roots` at all. Only the derived branch is reached,
and only indirectly through `scan_orphan_dirs`/`scan_registration_loss`. This plan therefore adds three
tests for the function — derived, override, and hard-failure — rather than the one the inputs asked
for.

### D6 — Observability for the single-scan property

The checked-in scan stub (`tests/fixtures/cleanup_worktrees/stub-bin/scan`) currently writes nothing to
stderr, so scan invocations cannot be counted. It gains one `printf ... >&2` argv-log line mirroring
the git stub's (`tests/fixtures/cleanup_worktrees/stub-bin/git:57`). This edit touches a fixture shared
by every scenario, so Phase 1 records a call-site audit and Phase 2's dispatch acts as its regression
gate: the fail-before artifact must enumerate the `not ok` set and confirm it contains only the tests
this plan deliberately turns red.

The audit's blast radius, re-derived in full for P1-T2, is two call sites out of ten: the report-mode
test in `tests/shell/test_cleanup_worktrees_cli.bats` and the `report()` helper in
`tests/shell/test_cleanup_worktrees_detached.bats` are the only places that both retain stderr and
reach `run_report`. Every other site either suppresses stderr or invokes only `run_apply`,
`classify_branch`, `classify_all_branches`, or the `cleanup_wt_scan_bin` resolver, none of which
executes the scan stub. Neither of the two exposed sites carries an `$output` equality assertion or an
unanchored line count, so the added line changes no assertion's value.

---

## Scope boundary

**In scope, this cycle:** R-01 (blocking), R-02, R-04, and the `spec.md` / SKILL.md corrections those
three require.

**Explicitly out of scope, this cycle** (deferred by the calling orchestrator as minor follow-ups; no
task in this plan touches them): R-05 (per-file coverage rows in the evidence artifact), R-06
(`scan_helper_gitfile_name` production-default test and the `set -euo pipefail` placement in
`cleanup_worktrees_scan_helper.sh`), R-07 (AC6 sequencing evidence), R-08 (the `usage()` "report and
apply mode" label, the missing `CLEANUP_WT_SCAN_GITFILE_NAME` override entry, and `run_report`'s
advisory-scan `rc` handling per CR-06). CR-07, CR-08, and CR-10 remain non-blocking observations and
are not addressed.

Because R-07 is deferred, spec.md's AC6 remains unchecked after this cycle. Phase 7 records that
explicitly so the state on disk is not mistaken for an oversight.

**Bounded documentation scope for `spec.md`.** Phase 6 corrects the `short-circuit` framing only where
it is load-bearing: the two `## Repro & Evidence` / `### In scope` bullets, the outcome-preservation
invariant's preamble and report-mode bullet, the performance paragraph, the three `CHILD_OF` Test
Strategy items, AC3, and AC5. It additionally corrects the invariant section's pairwise-probe
hard-failure paragraph (P6-T3), which carries no occurrence of `short-circuit` but does describe the
verdict-overwrite mechanism D2 removes.

The literal `short-circuit` occurs on twenty-eight lines of `spec.md` today. Phase 6 removes twelve of
them: lines 45 and 87 (P6-T5), 163 and 170 (P6-T1), 174 (P6-T2), 318 and 322 (P6-T4), 374 and 376
(P6-T6), and 426, 427, and 428 (P6-T8). Sixteen occurrences therefore remain after this cycle, at
lines 28, 60, 106, 119, 152, 182, 185, 186, 198, 259, 291, 303, 312, 455, 457, and 465 (line numbers
as of this plan's authoring, before Phase 6's edits shift them). Line 376 is deliberately absent from
that residue list because P6-T6 corrects it rather than leaving it: it is the third `CHILD_OF` Test
Strategy item, it states the apply-mode property that AC5(b) states, and leaving it describing a
"`CHILD_OF`-short-circuited" branch while P6-T8 rewrites AC5(b) would leave the specification
internally inconsistent on the one criterion this cycle checks off.

Three of the sixteen remaining occurrences sit inside the apply-mode outcome bullet, which P6-T2
preserves verbatim because its `awk`-extraction reasoning and its allowlist conclusion are correct as
written; the remaining thirteen sit in sections no remediation item in this cycle touches. Leaving
them is a decision, not an omission: a full terminology sweep of `spec.md` is a larger documentation
change than R-01, R-02, and R-04 require, and no acceptance criterion in this cycle is checked off on
the strength of any of those sixteen lines. Because sixteen occurrences survive, no task in Phase 6
may assert a whole-file no-match condition on the literal `short-circuit`; every such assertion in
this plan is scoped to the line range its task rewrites.

---

## Acceptance Criteria Inventory (this remediation cycle)

- **R-01** — `classify_all_branches` never reports a verdict other than the one `classify_branch`
  produces for that branch; the two vacuous outcome-preservation tests are replaced with
  same-branch/same-scenario comparisons; three counterexample fixtures pin the cut point; the
  pre-existing `child_of_*` fixtures and assertions are re-verified and updated where the corrected
  algorithm changes their expected output.
- **R-02** — exactly one `cleanup_wt_scan_records` invocation per `run_report` call, pinned by a test
  that counts scan-stub invocations; `scan_registration_loss`'s "one consistent view of the filesystem"
  docstring becomes true.
- **R-04** — `cleanup_wt_scan_roots` derives `.claude/worktrees` from the main worktree path; the
  derived, override, and hard-failure branches each carry a test.
- **AC3** — `CHILD_OF` positive/negative bats pair, with the criterion text corrected (P6-T7) to the
  informational-record contract D1 establishes, and with both members of the pair — the positive test
  (P2-T6) and the negative test (P2-T15) — restated to describe that contract.
- **AC5** — the outcome-preservation invariant, verified as two non-vacuous properties in report mode
  and apply mode, with the criterion text corrected (P6-T8) and the invariant section's pairwise-probe
  hard-failure paragraph corrected (P6-T3) to describe the delivered contract: the driver never
  substitutes a verdict of its own, so the invariant holds by construction, no short-circuit is
  described, and a hard pairwise-probe failure surfaces in the return code without overwriting any
  branch's verdict.
- **AC8** — every touched bash and bats file stays at or under the 500-line cap.
- **AC9** — the full toolchain loop passes with bash line coverage >= 85%.

---

### Phase 0 — Policy Reads and Remediation Baseline

- [x] [P0-T1] `[EXECUTOR]` Read `CLAUDE.md` in full. Acceptance: no file changes; the task is checked
      only after the file has been read in this session.
- [x] [P0-T2] `[EXECUTOR]` Read `.claude/rules/general-code-change.md` in full, noting the 500-line
      file-size cap in its File Size Limit section. Acceptance: read confirmed.
- [x] [P0-T3] `[EXECUTOR]` Read `.claude/rules/general-unit-test.md` in full, noting the no-temp-file
      test policy, the `tests/` mirror-layout requirement, and the 85% line / 75% branch thresholds
      (line coverage applies to bash; bash has no branch-coverage gate). Acceptance: read confirmed.
- [x] [P0-T4] `[EXECUTOR]` Read `.claude/rules/shell.md` in full, noting the four-stage toolchain order
      (format, check, test, test --coverage), the `SHELL_QC_<TOOL>_BIN` seam convention, and the
      500-line cap restated for shell files. Acceptance: read confirmed.
- [x] [P0-T5] `[EXECUTOR]` Write the policy-read evidence artifact at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/phase0-instructions-read.2026-09-07T14-40.md`
      containing `Timestamp:`, `Policy Order:` (the four files above, in order), and the explicit list
      of files read. Acceptance: the file exists and contains all three fields.
- [x] [P0-T6] `[ORCHESTRATOR-RUN]` Run `bash scripts/bash/shell-qc.sh format`. This is a write-mode
      command: `run_format` (`scripts/bash/shell_qc_lib.sh:204-224`) rewrites files in place and prints
      nothing on a clean run, so its exit code alone cannot distinguish a no-op run from a repairing
      one. Immediately afterward run `git status --porcelain -- scripts/bash tests/shell tests/fixtures`
      and record its output verbatim. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-format.2026-09-07T14-40.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that carries the porcelain
      output verbatim. Acceptance: `EXIT_CODE: 0` and the porcelain observation is present.
- [x] [P0-T7] `[ORCHESTRATOR-RUN]` Run `bash scripts/bash/shell-qc.sh check`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-check.2026-09-07T14-40.md`
      with the four required fields; `Output Summary:` states the shfmt-diff and shellcheck results.
      Acceptance: `EXIT_CODE: 0`.
- [x] [P0-T8] `[ORCHESTRATOR-RUN]` Push the branch, then dispatch
      `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
      and read the completed run's log. Record the baseline test evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-test.2026-09-07T14-40.md`
      with `Timestamp:`, `Command: bash scripts/bash/shell-qc.sh test --coverage`, `EXIT_CODE:`, and an
      `Output Summary:` that records the dispatched commit sha, the run id, the bats TAP plan line
      (`1..N`), the `ok` count, and the `not ok` count. Acceptance: `EXIT_CODE: 0`, the `not ok` count
      is `0`, and the numeric total `N` is recorded (this `N` is the baseline count Phase 2 and Phase 7
      compare against).
- [x] [P0-T9] `[ORCHESTRATOR-RUN]` From the same run log as P0-T8, record the baseline coverage
      evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/remediation-baseline/baseline-test-coverage.2026-09-07T14-40.md`
      with the four required fields; `Output Summary:` must include the literal printed line
      `Bash coverage (lines): NN.N%` produced by `print_coverage_summary`
      (`scripts/bash/shell_qc_lib.sh:291`), with its exact numeric value. Acceptance: `EXIT_CODE: 0` and
      the numeric baseline percentage is recorded, not a placeholder.

### Phase 1 — Scan-Stub Argv Log and Call-Site Audit

- [x] [P1-T1] `[EXECUTOR]` Edit `tests/fixtures/cleanup_worktrees/stub-bin/scan` to write one argv log
      line to stderr for every invocation, mirroring the git stub's line at
      `tests/fixtures/cleanup_worktrees/stub-bin/git:57`. Insert, immediately after the file's
      `set -uo pipefail` line (currently line 22) and before the `scenario=` assignment (currently line
      24), a comment and the statement whose literal text is `printf 'stub-scan: %s\n' "$*" >&2`. Also
      extend the file's header block to state that the invocation log is on stderr so a caller capturing
      stdout via command substitution receives only the canned data, matching the git stub's header
      wording. Acceptance: a Grep of `tests/fixtures/cleanup_worktrees/stub-bin/scan` for the literal
      `stub-scan:` returns exactly two matching lines (the header sentence and the `printf` statement),
      and the `printf` line precedes the line assigning `scenario`.
- [x] [P1-T2] `[EXECUTOR]` Write the scan-stub call-site audit at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/scan-stub-stderr-callsite-audit.2026-09-07T14-40.md`.
      It must enumerate every call site under `tests/` that sets `CLEANUP_WT_SCAN_BIN` and state, for
      each, (a) whether stderr is retained or suppressed and (b) whether a `stub-scan:` argv-log line
      can reach that site's `$output`. A repository-wide search for the literal `CLEANUP_WT_SCAN_BIN`
      under `tests/`, re-derived against the current tree, returns thirteen matches: ten env-setting
      sites across seven `tests/shell/*.bats` files, plus three non-setting prose mentions, at
      `tests/shell/test_cleanup_worktrees_scan_helper.bats:3` (a file-header comment),
      `tests/shell/test_cleanup_worktrees_scan_seam.bats:16` (a `@test` title), and
      `tests/fixtures/cleanup_worktrees/stub-bin/scan:3` (a file-header comment). The ten sites are:
      (1) `report()` (`tests/shell/test_cleanup_worktrees_classification.bats:40-49`, env at line 46) —
      suppresses stderr via `run_report 2>/dev/null` inside its `bash -c` string; reaches the seam
      through `run_report`; no `stub-scan:` line can reach `$output`.
      (2) `apply()` (`tests/shell/test_cleanup_worktrees_deletion.bats:25-33`, env at line 30) —
      retains stderr, but invokes `run_apply`, and a search for `scan_`/`cleanup_wt_scan` in
      `scripts/bash/cleanup_worktrees_actions_lib.sh` and
      `scripts/bash/cleanup_worktrees_detached_lib.sh` returns no match in either file, so apply mode
      never reaches the seam; no `stub-scan:` line can reach `$output`.
      (3) `tests/shell/test_cleanup_worktrees_cli.bats:34`, inline in
      `@test "default report mode emits classification lines and performs no mutation"` (lines 30-45) —
      retains stderr (it runs `bash "${WRAPPER}"` with no redirection) and the wrapper's `main`
      dispatches `run_report` for the empty command (`scripts/bash/cleanup-worktrees.sh:103-105`), so a
      `stub-scan:` line CAN reach `$output`. The test's assertions are two substring-positive checks on
      `BRANCH|feature-wt|MERGED_CLEAN` and `WORKTREE|/repo-wt/feat|feature-wt|` and four
      substring-negative checks on `worktree remove`, `branch -D`, `cherry-pick`, and `worktree add`;
      the scan stub is invoked as `scan-dirs <root> [...]`
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:171` and `:173`), so the new line contains
      none of those six tokens and no assertion changes value.
      (4) `tests/shell/test_cleanup_worktrees_cli.bats:48`, inline in
      `@test "apply mode emits ACTION lines and destructive argv only for eligible states"` (lines
      47-58) — retains stderr, but `--apply` dispatches `run_apply` only
      (`scripts/bash/cleanup-worktrees.sh:106-108`), which reaches no scan function; no `stub-scan:`
      line can reach `$output`.
      (5) `runin()` (`tests/shell/test_cleanup_worktrees_hard_failures.bats:26-37`, env at line 34) —
      suppresses stderr via the trailing `$2 2>/dev/null` in its `bash -c` string; used with
      `run_report` (line 96) and `run_apply` (lines 105 and 113); no `stub-scan:` line can reach
      `$output`.
      (6) `report()` (`tests/shell/test_cleanup_worktrees_detached.bats:31-41`, env at line 38) —
      deliberately retains stderr (stated in that file's header at lines 11-15) and reaches the seam
      through `run_report`, so a `stub-scan:` line CAN reach `$output`. The file contains no
      `[ "$output" = ... ]` equality assertion, and its one count assertion is anchored
      (`grep -c '^WORKTREE|/repo-wt/det'`, line 54), so a line beginning `stub-scan:` matches nothing
      and no assertion changes value.
      (7) `runin()` (`tests/shell/test_cleanup_worktrees_detached.bats:43-47`, env at line 44) —
      retains stderr, and has thirty-two call sites, re-derived against the current tree, which pass
      four distinct invocations: `is_detached_candidate` at lines 69, 71, 73, 75, 77, 79, 81, and 83
      (8 sites); `run_apply` at lines 95, 103, 113, 121, 132, 144, 149, 193, 211, 227, 255, 270, 286,
      and 314 (14 sites); `classify_detached_head` at lines 159, 167, 238, 249, 264, 280, 298, and 308
      (8 sites); and `reverify_detached_delete_eligible` at lines 174 and 324 (2 sites). None of the
      four reaches a scan function: `run_apply` is defined in
      `scripts/bash/cleanup_worktrees_actions_lib.sh:336`, and `is_detached_candidate`,
      `classify_detached_head`, and `reverify_detached_delete_eligible` are defined in
      `scripts/bash/cleanup_worktrees_detached_lib.sh` at lines 41, 64, and 196 respectively; a search
      for `scan_`/`cleanup_wt_scan` returns zero matches in either file, so no scan function is
      reachable through any of the four. No `stub-scan:` line can reach `$output` at this call site.
      (8) `rr()` (`tests/shell/test_cleanup_worktrees_report_records.bats:22-28`, env at line 25) —
      suppresses stderr via the trailing `$2 2>/dev/null`; this is what protects the file's six
      `[ "$output" = ... ]` equality assertions at lines 36, 43, 51, 59, 67, and 74.
      (9) and (10) `tests/shell/test_cleanup_worktrees_scan_seam.bats:17` and `:24`, inline in the two
      `cleanup_wt_scan_bin` tests (lines 16-21 and 23-28) — both set the variable but invoke only the
      resolver `cleanup_wt_scan_bin`, which prints a path and never executes the binary
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:42-59`); no `stub-scan:` line can reach
      `$output`, so the equality assertion at line 20 is unaffected.
      The artifact must additionally record two derived findings. First, no bats helper reaches
      `run_report` or `run_apply` without setting `CLEANUP_WT_SCAN_BIN`, so no test falls back to the
      bundled real scan helper. Second, `classify_all()`
      (`tests/shell/test_cleanup_worktrees_classification.bats:28-38`) retains stderr but is NOT a
      `CLEANUP_WT_SCAN_BIN` setter — it sets only `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`
      (line 36) — and it invokes `classify_all_branches`
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:317-463`), whose body contains no scan
      call, so the seam is unreachable from it on both counts. The artifact must carry `Timestamp:`,
      `SearchScope:`, `SearchPatterns:`, and `SearchResult:` fields recording the searches that
      produced the list. Acceptance: the artifact exists, enumerates all ten `CLEANUP_WT_SCAN_BIN`
      env-setting sites across the seven files named above, separately names the three non-setting
      prose mentions so the thirteen-match total accounts for every match the search returns, states
      for each of the ten sites both (a) and (b), and records the two derived findings. The blast
      radius the artifact establishes is exactly the two sites where a `stub-scan:` line can reach
      `$output`: sites (3) and (6).

### Phase 2 — Fail-Before Fixtures and Tests (R-01, R-02, R-04)

Every test authored in this phase asserts post-fix behavior. Eight of them are deterministically red
against the current tree; that red run is this cycle's fail-before evidence and is captured once, in
P2-T16, tagged `[expect-fail]`. This phase authors, or renames and rewrites, twelve tests in total,
counted by the rule that a test enters this count when its `@test` title is new or changed, because
the title is the identifier the TAP output reports; P2-T11 is therefore excluded, since it edits a
comment block only and leaves its title unchanged. Four of the twelve are green from the moment
P2-T1 lands: P2-T7's same-branch comparison, P2-T12's renamed apply-mode test (both assert a
`NOT_MERGED` verdict the pre-fix driver also produces), P2-T14's `CLEANUP_WT_ORPHAN_ROOTS` override
test (that branch of `cleanup_wt_scan_roots` is unchanged by P3-T1), and P2-T15's renamed
`child_of_merged_equivalent` negative test (a title-and-comment correction whose six executable lines
are unchanged and hold in both the pre-fix and post-fix states). Twelve minus those four is the
eight-item expected-red set P2-T16 enumerates.

The three new `child_of_subject_*` scenarios share a common base file set, defined once here and
referenced by each task below as **the base set**:

- `for-each-ref.out` containing exactly three lines: `feature-child cccc4444`, `feature-parent cccc3333`,
  `main aaaa0000`.
- `rev-parse.abbrev-ref-HEAD.out` containing the single line `main`.
- `rev-parse.show-toplevel.out` containing the single line `/repo/main`.
- `worktree-list.out` containing the four-line porcelain block `worktree /repo/main`, `HEAD aaaa0000`,
  `branch refs/heads/main`, then a trailing blank line (byte-for-byte the shape of
  `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/worktree-list.out`).
- The `feature-parent` ladder set that resolves it to `NOT_MERGED`, mirroring
  `tests/fixtures/cleanup_worktrees/scenarios/unmerged/` renamed: `merge-base.feature-parent.rc`
  containing `1`, `diff-quiet.feature-parent.rc` containing `1`, `cherry.feature-parent.out` containing
  `+ dead0001`, `diff-tree.dead0001.out` containing the single tab-separated line `M<TAB>src/app.py`,
  `rev-parse.feature-parent_src_app.py.out` containing `blobbranchAAA`, and
  `rev-parse.main_src_app.py.out` containing `blobmainBBB`.
- `merge-base.main.rc` containing `1`, so `main` is never recorded as an ancestor-target of another
  branch under the pre-fix code path that Phase 2's fail-before run exercises.

No `merge-base.feature-child.feature-parent.rc` file is supplied in any of the three scenarios. The
stub's target-aware `merge-base` key falls back to the bare `merge-base.feature-child` key
(`tests/fixtures/cleanup_worktrees/stub-bin/git:138-147`), which is also absent, so `respond()` exits 0
and `feature-child` is an ancestor of `feature-parent` in every one of them. That is the property each
scenario needs.

- [x] [P2-T1] `[EXECUTOR]` Make `feature-child` resolve `NOT_MERGED` through its own unchanged ladder in
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/` by adding five files:
      `diff-quiet.feature-child.rc` containing `1`; `cherry.feature-child.out` containing `+ dead0002`;
      `diff-tree.dead0002.out` containing the single tab-separated line `M<TAB>src/child.py`; and
      `rev-parse.feature-child_src_child.py.out` containing `blobchildAAA` alongside
      `rev-parse.main_src_child.py.out` containing `blobmainCCC`. The two blob values differ, so
      `classify_residual_commit` returns `UNIQUE`, `unique_count` is 1 with `minus_present` 0 and
      `content_count` 0, and `classify_branch` reaches `NOT_MERGED`
      (`scripts/bash/cleanup_worktrees_lib.sh:423-437`). The residual sha `dead0002` is deliberately
      distinct from the scenario's existing `diff-tree.dead0001.out`, which belongs to
      `feature-parent`. Rationale to record in this task's commit: without these files the stub exits 0
      for `git diff --quiet main...feature-child`, `classify_content_neutral` returns
      `MERGED_CONTENT_NEUTRAL`, and the fixture is not a valid positive case for a `CHILD_OF` record at
      all. Acceptance: the five listed files exist under that directory with exactly the contents
      quoted, and `merge-base.feature-child.main.rc` (already present, containing `1`) is unmodified.
- [x] [P2-T2] `[EXECUTOR]` Create
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_subject_merged_clean/` containing the base
      set plus `merge-base.feature-child.main.rc` containing `0`. Rung 2 therefore resolves
      `feature-child` to `MERGED_CLEAN` while it remains a git ancestor of the `NOT_MERGED`
      `feature-parent`. This is the rung-2 counterexample from D1. Acceptance: the directory exists and
      contains the base set plus `merge-base.feature-child.main.rc` with the content `0`.
- [x] [P2-T3] `[EXECUTOR]` Create
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_subject_content_neutral/` containing the base
      set plus `merge-base.feature-child.main.rc` containing `1`, and deliberately **no**
      `diff-quiet.feature-child.rc` file. The absent key makes the stub exit 0 for
      `git diff --quiet main...feature-child`, so rung 3 resolves `feature-child` to
      `MERGED_CONTENT_NEUTRAL` while it remains a git ancestor of the `NOT_MERGED` `feature-parent`.
      This is the rung-3 counterexample from D1, and it is the shape CR-01's Evidence 1 found inside the
      feature's own positive fixture. Acceptance: the directory exists and contains the base set plus
      `merge-base.feature-child.main.rc` with the content `1`, and contains no file named
      `diff-quiet.feature-child.rc`.
- [x] [P2-T4] `[EXECUTOR]` Create
      `tests/fixtures/cleanup_worktrees/scenarios/child_of_subject_merged_equivalent/` containing the
      base set plus five files that resolve `feature-child` to `MERGED_EQUIVALENT` at rung 5:
      `merge-base.feature-child.main.rc` containing `1`; `diff-quiet.feature-child.rc` containing `1`;
      `cherry.feature-child.out` containing `+ eqvc0001`; `diff-tree.eqvc0001.out` containing the single
      tab-separated line `M<TAB>docs/readme.md`; and `rev-parse.feature-child_docs_readme.md.out` and
      `rev-parse.main_docs_readme.md.out` **both** containing `blobsame111`. Equal blob values make
      `classify_residual_commit` return `CONTENT_ON_MAIN`, so `unique_count` is 0 and `classify_branch`
      emits `MERGED_EQUIVALENT` (`scripts/bash/cleanup_worktrees_lib.sh:423-427`) while `feature-child`
      remains a git ancestor of the `NOT_MERGED` `feature-parent`. This is the rung-5 counterexample
      from D1 and is the fixture that makes the chosen cut point testable rather than asserted: a design
      that ran rungs 1 through 4 and then inherited would still report `NOT_MERGED` here. Acceptance:
      the directory exists and contains the base set plus the five listed files with exactly the
      contents quoted, and the two `rev-parse.*_docs_readme.md.out` files have identical content.
- [x] [P2-T5] `[EXECUTOR]` Create `tests/fixtures/cleanup_worktrees/scenarios/report_single_scan/`
      containing `worktree-list.out` (the same four-line main-worktree block as the base set) and
      `scan-dirs.out` containing exactly two lines:
      `/repo/main/.claude/worktrees/agent-old|0|NA|128K` and `/repo/main-wt/half-gone|1|0|32K`. The
      first line is the `ORPHAN_DIR` shape (`has_gitfile` 0, unregistered); the second is the
      `WARN|registration-lost` shape (`has_gitfile` 1, `gitdir_target_exists` 0). Both record paths sit
      under the roots that D5's derivation produces from the main worktree path `/repo/main`. No
      `for-each-ref.out` is supplied, so `enumerate_branches` yields an empty branch list and the
      scenario exercises only the scan half of `run_report`. Acceptance: the directory exists and
      `scan-dirs.out` contains exactly the two quoted lines.
- [x] [P2-T6] `[EXECUTOR]` Rewrite the assertions of the existing `@test` titled
      `"child_of_not_merged: CHILD_OF short-circuit skips feature-child's expensive rungs"` in
      `tests/shell/test_cleanup_worktrees_classification.bats` (currently lines 153-170). Rename it to
      `"child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict"`. Keep
      the three positive assertions on `BRANCH|feature-child|NOT_MERGED`,
      `BRANCH|feature-parent|NOT_MERGED`, and `CHILD_OF|feature-child|feature-parent`. Delete the three
      argv-log absence assertions (the `cherry main feature-child` absence check, the `cccc4444` absence
      check, and the `rev-list --reverse --no-merges` absence check) and replace them with one presence
      assertion that `$output` contains `cherry main feature-child`, which proves the subject's own
      ladder ran. Update the test's comment block to state that the driver runs the unchanged ladder for
      every branch and that `CHILD_OF` records an ancestry relationship rather than an inherited
      verdict. Additionally update the comment block of the `classify_all()` helper itself (currently
      lines 28-38 of the same file), whose lines 29-35 state that the helper exists "so the CHILD_OF
      short-circuit can be asserted on its own terms" and that "the CHILD_OF tests read that merged log
      to prove the expensive ladder rungs were never invoked for a short-circuited branch"; both
      sentences describe the mechanism D1 removes. Restate them as: the helper drives
      `classify_all_branches` directly, independent of `run_report`'s wiring, and retains stderr so the
      tests can read the git stub's `stub-git:` argv log as positive proof that each subject's own
      ladder ran. The helper's `run env` line must not be modified. Acceptance: a Grep of the file for
      the literal `cherry main feature-child` shows it inside this test as a positive containment
      assertion; a Grep for the literal `cccc4444` returns no match anywhere in the file (currently one
      match, on line 167, so the condition is failable); and a Grep of the `classify_all()` helper
      block — from its `classify_all() {` opening line to its closing `}`, currently lines 28 through
      38, named by its opening literal rather than by absolute line numbers because the restated
      comment may change the block's length — for the literal `short-circuit` returns no match
      (currently two matches within it, on lines 30 and 35, so that condition is failable too). The
      third condition may not be widened to a whole-file search: line 82 of the same file carries a
      correct, out-of-scope `short-circuit` occurrence describing the ladder's own rung-3
      `diff --quiet` early exit, so a whole-file no-match assertion would be unsatisfiable.
- [x] [P2-T7] `[EXECUTOR]` Replace the body of the existing `@test` titled
      `"child_of_not_merged: report-mode BRANCH line is unchanged by the short-circuit"` in
      `tests/shell/test_cleanup_worktrees_classification.bats` (currently lines 195-207) with a
      same-branch, same-scenario comparison. Rename it to
      `"child_of_not_merged: the driver's BRANCH line equals the ladder's own for the same branch"`. The
      body must call `classify_all child_of_not_merged`, capture the single line matching
      `^BRANCH|feature-child|` from `$output` into a local variable, then call
      `cb child_of_not_merged feature-child`, capture the same-shaped line from `$output` into a second
      variable, and assert the two variables are equal and that the value is
      `BRANCH|feature-child|NOT_MERGED`. The existing cross-scenario comparison against
      `cb unmerged feature-unmerged` must be deleted: it compares two different branches in two
      different fixtures and cannot fail for the property it names. Acceptance: the file contains the
      new test title, contains no line invoking `cb unmerged feature-unmerged` inside this test, and the
      test body invokes both `classify_all child_of_not_merged` and `cb child_of_not_merged feature-child`.
- [x] [P2-T8] `[EXECUTOR]` Append `@test "child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported"`
      to `tests/shell/test_cleanup_worktrees_classification.bats`. It calls
      `classify_all child_of_subject_merged_clean`, asserts `$status` is 0, asserts `$output` contains
      `BRANCH|feature-child|MERGED_CLEAN`, asserts `$output` does not contain
      `BRANCH|feature-child|NOT_MERGED`, and asserts `$output` does not contain
      `CHILD_OF|feature-child|`. It then calls `cb child_of_subject_merged_clean feature-child` and
      asserts its `$output` equals `BRANCH|feature-child|MERGED_CLEAN`, pinning driver-and-ladder
      agreement. The comment must state that the subject is a git ancestor of the `NOT_MERGED`
      `feature-parent`, so this test is the regression guard against reintroducing verdict inheritance
      at rung 2. Acceptance: the file contains the quoted test title and the literal
      `BRANCH|feature-child|MERGED_CLEAN`.
- [x] [P2-T9] `[EXECUTOR]` Append `@test "child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported"`
      to `tests/shell/test_cleanup_worktrees_classification.bats`, structured exactly as P2-T8 but
      against `child_of_subject_content_neutral` and asserting the state token
      `MERGED_CONTENT_NEUTRAL` in both the driver output and the direct `cb` output, with the same two
      absence assertions on `BRANCH|feature-child|NOT_MERGED` and `CHILD_OF|feature-child|`. The comment
      must identify this as the rung-3 counterexample. Acceptance: the file contains the quoted test
      title and the literal `BRANCH|feature-child|MERGED_CONTENT_NEUTRAL`.
- [x] [P2-T10] `[EXECUTOR]` Append `@test "child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported"`
      to `tests/shell/test_cleanup_worktrees_classification.bats`, structured exactly as P2-T8 but
      against `child_of_subject_merged_equivalent` and asserting the state token `MERGED_EQUIVALENT` in
      both the driver output and the direct `cb` output, with the same two absence assertions. The
      comment must state that this scenario is the reason the cut point is "no rungs skipped": the
      subject's merged-ness is only discoverable at rung 5, which compares the branch tip's blob against
      `main` and therefore cannot be derived from any ancestor's result. Acceptance: the file contains
      the quoted test title and the literal `BRANCH|feature-child|MERGED_EQUIVALENT`.
- [x] [P2-T11] `[EXECUTOR]` Update only the comment block of the existing `@test` titled
      `"child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR"`
      (`tests/shell/test_cleanup_worktrees_classification.bats:186-193`) to record that under the
      corrected driver the scenario's `merge-base.feature-child.rc` value of `128` is consumed by
      `classify_ancestry`'s own rung-2 probe inside `classify_branch`, because that probe also falls
      back to the bare `merge-base.feature-child` key, and that the fail-closed mapping to
      `BRANCH|feature-child|ANCESTRY_ERROR` with a non-zero driver return is unchanged. The two
      assertions must not be modified. Acceptance: the two assertion lines
      (`[ "$status" -ne 0 ]` and the containment check on `BRANCH|feature-child|ANCESTRY_ERROR`) are
      byte-identical to their current form, and the comment above them names `classify_ancestry`.
- [x] [P2-T12] `[EXECUTOR]` Rewrite the existing `@test` titled
      `"apply mode allowlist is unaffected by a CHILD_OF short-circuit"` in
      `tests/shell/test_cleanup_worktrees_deletion.bats` (currently lines 130-140) and append one new
      test beside it. (1) Rename the existing test to
      `"apply mode emits no deletion for a NOT_MERGED branch carrying a CHILD_OF record"`, keep its four
      assertions against `${SCEN}/child_of_not_merged` unchanged, and update its comment to state that
      `feature-child` now resolves `NOT_MERGED` through its own ladder under that fixture (P2-T1), so
      the assertion is no longer satisfied by an inherited verdict. (2) Append
      `@test "apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch"`,
      which calls `apply "${SCEN}/child_of_subject_merged_clean"` and asserts `$output` contains
      `BRANCH|feature-child|MERGED_CLEAN`, contains `ACTION|branch-delete|feature-child|OK`, and
      contains `BRANCH|feature-parent|NOT_MERGED`. This is the apply-mode expression of R-01's stated
      impact: the pre-fix driver reports `NOT_MERGED` for this branch and it is silently never deleted.
      Acceptance: the file contains both quoted test titles and the literal
      `ACTION|branch-delete|feature-child|OK`.
- [x] [P2-T13] `[EXECUTOR]` Extend `setup()` in `tests/shell/test_cleanup_worktrees_report_records.bats`
      (currently lines 10-20) with `LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"` and
      `DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"`, and add a helper named
      `report_raw` immediately after the existing `rr()` helper (currently lines 22-28). `report_raw`
      takes a scenario name, runs `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}"
      CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1"` with a `bash -c` string that sources `ELIB`, `LIB`, `RLIB`,
      and `DLIB` in that order and then invokes `run_report`, and — unlike `rr()` — carries no
      `2>/dev/null` redirection, so the scan stub's `stub-scan:` argv log merges into `$output`. Its
      comment must state that the retained stderr is what makes the invocation count assertable.
      Acceptance: a Grep of the file for the literal `report_raw` returns at least the helper
      definition, and a Grep for the literal `cleanup_worktrees_detached_lib.sh` returns at least one
      match.
- [x] [P2-T14] `[EXECUTOR]` Append four `@test` blocks to
      `tests/shell/test_cleanup_worktrees_report_records.bats`:
      (1) `@test "cleanup_wt_scan_roots derives both roots from the main worktree path"` — calls
      `rr orphan_dir_present "cleanup_wt_scan_roots"`, asserts `$status` is 0, asserts
      `"${#lines[@]}"` equals 2, asserts `"${lines[0]}"` equals `/repo/main/.claude/worktrees`, and
      asserts `"${lines[1]}"` equals `/repo/main-wt`. The scenario's `worktree-list.out` names
      `/repo/main` as the first stanza, so both roots are derived from that one path.
      (2) `@test "cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override"` — runs the
      resolver with `CLEANUP_WT_ORPHAN_ROOTS` set to the two-element colon-separated value
      `/a/one:/b/two`, asserts `"${lines[0]}"` equals `/a/one` and `"${lines[1]}"` equals `/b/two`, and
      asserts `"${#lines[@]}"` equals 2, proving the override short-circuits the derivation.
      (3) `@test "cleanup_wt_scan_roots emits no root when the worktree listing hard-fails"` — calls
      `rr worktree_list_error "cleanup_wt_scan_roots"` (that scenario supplies `worktree-list.rc`) and
      asserts `$output` is the empty string, so an unresolvable main worktree path yields silence rather
      than a CWD-relative scan.
      (4) `@test "run_report performs exactly one filesystem scan"` — calls
      `report_raw report_single_scan`, asserts `$status` is 0, asserts `$output` contains
      `ORPHAN_DIR|/repo/main/.claude/worktrees/agent-old|128K`, asserts `$output` contains
      `WARN|registration-lost|/repo/main-wt/half-gone`, and asserts that the count of lines in `$output`
      matching the literal `stub-scan: scan-dirs` is exactly 1. The count must be taken with a
      `grep -c` whose failure on a zero count is neutralized (`|| true`) so the assertion reports the
      count rather than aborting the test. This is the R-02 gate: both records are derived from one
      scan, which is what makes `scan_registration_loss`'s "one consistent view of the filesystem"
      docstring true.
      Acceptance: the file contains all four quoted test titles and the literals
      `/repo/main/.claude/worktrees`, `/repo/main-wt`, and `stub-scan: scan-dirs`.
- [x] [P2-T15] `[EXECUTOR]` Correct the title and comments — and only the title and comments — of the
      AC3 negative-case `@test` currently titled
      `"child_of_merged_equivalent: no short-circuit when the ancestor is not NOT_MERGED"` in
      `tests/shell/test_cleanup_worktrees_classification.bats` (currently lines 172-184). This is the
      sibling of the positive test P2-T6 rewrites, and it carries the same removed-mechanism
      vocabulary: `short-circuit` on the title line 172 and on the comment line 182 ("No branch in
      this scenario is short-circuited, including main."), and `inherit` on the comment lines 174
      ("so nothing may be inherited") and 180 ("not from an inheritance"). Rename the test to
      `"child_of_merged_equivalent: no CHILD_OF is emitted when the ancestor is not NOT_MERGED"`.
      Restate the comment block to describe the delivered mechanism: under D2 the driver classifies
      every branch first and then probes only ordered pairs drawn from the set of branches that
      resolved exactly `NOT_MERGED`; in this fixture `feature-parent` resolves `MERGED_EQUIVALENT` and
      `main` resolves `PROTECTED_CURRENT`, so that set has the single member `feature-child`, a
      single-member set yields no ordered pair, and no `CHILD_OF` record is emitted. State also that
      `feature-child` reports the `NOT_MERGED` verdict its own ladder produced, which is what the
      `cherry main feature-child` presence assertion reads.
      The test's six executable lines must not be modified in any way: the `classify_all` call at line
      176 and the five assertions at lines 177, 178, 179, 181, and 183.
      This test is green both before and after the Phase 5 rewrite: under the current code the
      short-circuit does not fire because `feature-parent` is not `NOT_MERGED`, and under the
      rewritten driver no pair exists for the same reason, so all five assertions hold in both states.
      It is therefore a renamed-but-still-green test and does not join the expected-red set.
      Acceptance: the file contains the new title verbatim; a Grep of this `@test` block — from its
      `@test "child_of_merged_equivalent:` opening line to its closing `}`, currently lines 172 through
      184, named by its opening literal rather than by absolute line numbers because the restated
      comment block may change the block's length — for the literal `short-circuit` returns no match
      (currently two matches within it, on lines 172 and 182, so the condition is failable); a Grep of
      the same block for the literal `inherit` returns no match
      (currently two matches, on lines 174 and 180, so that condition is failable too); and the six
      executable lines named above — and only those six, not the range they span, since lines 180 and
      182 sit between them and are comments this task does rewrite — are unchanged in content. The
      searches are scoped to this test's own line range deliberately: the file retains one occurrence
      of `short-circuit` at line 82
      (`@test "content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit"`), which
      correctly describes the ladder's own rung-3 `diff --quiet` early exit, is unrelated to the
      `CHILD_OF` mechanism D1 removes, and is out of scope for this cycle, so a whole-file no-match
      assertion would be unsatisfiable. Line 82 is the only occurrence of either token that survives
      in this file once P2-T6, P2-T7, and this task have landed; P2-T12 removes the two occurrences in
      `tests/shell/test_cleanup_worktrees_deletion.bats`, which is a different file.
- [x] [P2-T16] `[ORCHESTRATOR-RUN]` `[expect-fail]` Commit and push Phases 1 and 2, then dispatch
      `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
      and read the completed run's log. Record the fail-before evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/regression-testing/fail-before-r01-r02-r04.2026-09-07T14-40.md`
      with `Timestamp:`, `Command: bash scripts/bash/shell-qc.sh test --coverage`, `EXIT_CODE:`,
      `ExpectedExitCode: 1`, and an `Output Summary:` that records the dispatched commit sha, the run
      id, and the verbatim list of every `not ok` line the run printed. Acceptance: `EXIT_CODE` is
      non-zero, and the `not ok` list consists of exactly these eight test titles and no others:
      `child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict`;
      `child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported`;
      `child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported`;
      `child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported`;
      `apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch`;
      `cleanup_wt_scan_roots derives both roots from the main worktree path`;
      `cleanup_wt_scan_roots emits no root when the worktree listing hard-fails`;
      `run_report performs exactly one filesystem scan`. The eighth title is red at this point for a
      reason independent of the other seven: Phase 4 has not landed, so `run_report` still calls
      `scan_orphan_dirs` and `scan_registration_loss`, each of which scans for itself
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:200` and `:253`), and the count of
      `stub-scan: scan-dirs` lines is 2 rather than the asserted 1. Any additional `not ok` line beyond
      these eight is a regression introduced by this phase — most plausibly by P1-T1's shared-fixture
      edit — and must be investigated and fixed before Phase 3 begins. Note for the reader of this
      artifact: `run_test_coverage` stops at the first failing test directory
      (`scripts/bash/shell_qc_lib.sh:294-305`), so if `tests/shell` fails the `tests/bash` suites may
      not have run; record that fact when it applies.

### Phase 3 — R-04: Derive Both Scan Roots From the Main Worktree Path

- [x] [P3-T1] `[EXECUTOR]` Restructure `cleanup_wt_scan_roots` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (function body currently lines 110-143) so
      that both roots derive from one `parse_worktree_list` read. Move the `printf` currently at line
      131 to after the `parse_worktree_list` capture and the `main_wt` extraction (currently lines
      132-138), and change its argument from the bare string `.claude/worktrees` to
      `"${main_wt}/.claude/worktrees"`, emitted inside the same `if [[ -n $main_wt ]]` guard that
      already gates the `"${main_wt}-wt"` emission and immediately before it, so the two roots keep
      their current order. On a `parse_worktree_list` hard failure the function returns 0 having emitted
      no root at all. Update the function's header comment to state the new derivation and to replace
      the sentence claiming a hard failure "drops only the derived second root". Acceptance: a Grep of
      the file for the literal `"${main_wt}/.claude/worktrees"` returns exactly one match, and a Grep
      for a `printf` line whose argument is the bare quoted string `.claude/worktrees` returns no match.

### Phase 4 — R-02: One Filesystem Scan Per Report

- [x] [P4-T1] `[EXECUTOR]` Give `scan_orphan_dirs` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (function body currently lines 185-232) an
      optional first parameter carrying pre-scanned records. When `$#` is greater than 0 the function
      uses `$1` verbatim as the record text and performs no scan; otherwise it calls
      `cleanup_wt_scan_records` exactly as it does today and returns that call's non-zero exit code
      unchanged on a hard failure. The `$#` test, not an emptiness test on the value, is what
      distinguishes "records supplied and empty" from "no records supplied". Document the parameter in
      the function header. Acceptance: the function header documents an optional records argument, and
      the function body contains exactly one `cleanup_wt_scan_records` call, reached only on the
      no-argument branch.
- [x] [P4-T2] `[EXECUTOR]` Apply the identical optional-parameter change to `scan_registration_loss`
      (function body currently lines 234-273), and correct its header sentence that currently reads
      that the two records "are always derived from one consistent view of the filesystem" so that it
      states the mechanism that now makes it true: the caller scans once and passes the same records to
      both functions, and a direct call with no argument scans for itself. Acceptance: the function
      body contains exactly one `cleanup_wt_scan_records` call, reached only on the no-argument branch,
      and the header names the caller-supplied-records mechanism.
- [x] [P4-T3] `[EXECUTOR]` Add `run_report_scans` to
      `scripts/bash/cleanup_worktrees_report_records_lib.sh`, placed immediately after
      `scan_registration_loss`. It performs one guarded parent-shell capture of
      `cleanup_wt_scan_records`; on a non-zero capture it calls `scan_stale_refs`, emits no scan-derived
      record, and returns the scan's exit code. Otherwise it calls `scan_stale_refs`, then
      `scan_orphan_dirs` with the captured records, then `scan_registration_loss` with the same captured
      records, in that order, and returns the maximum non-zero return observed. Its header must state
      that it is the sole report-mode entry point for the three advisory scans and that it exists so
      exactly one filesystem scan and one `du` pass occur per report. Acceptance: the file defines
      `run_report_scans`, its body contains exactly one `cleanup_wt_scan_records` call, and it calls
      `scan_stale_refs`, `scan_orphan_dirs`, and `scan_registration_loss` in that textual order.
- [x] [P4-T4] `[EXECUTOR]` Replace the three consecutive call lines in `run_report`
      (`scripts/bash/cleanup_worktrees_lib.sh:474-476`, currently `scan_stale_refs || rc=$?`,
      `scan_orphan_dirs || rc=$?`, `scan_registration_loss || rc=$?`) with the single line
      `run_report_scans || rc=$?`, leaving the preceding `check_main_freshness` call (line 473) and the
      following `WORKTREE|` emission loop (lines 477-483) untouched. Update `run_report`'s header
      sentence that names the three scans so it names `run_report_scans` as the single call that emits
      them in the documented order. Acceptance: a Grep of `scripts/bash/cleanup_worktrees_lib.sh` for
      the literal `run_report_scans` returns matches only inside `run_report` and its header comment,
      and a Grep of the same file for the literal `scan_orphan_dirs` returns no match.

### Phase 5 — R-01: Sound Classification Driver

- [x] [P5-T1] `[EXECUTOR]` Rewrite `classify_all_branches` in
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (function body currently lines 317-463)
      per D1 and D2. The new body must: capture `enumerate_branches` with `|| rc=$?` and return git's
      exit code on a hard failure before emitting any line, exactly as today (currently lines 361-365);
      classify **every** enumerated branch by calling `classify_branch` once, recording its captured
      output and reading its state from the first `BRANCH|` line's third field with the existing
      `awk -F'|' '/^BRANCH\|/{print $3; exit}'` extraction (currently line 406), and raising `rc` to the
      maximum per-branch return code observed; then, for every ordered pair `(X, Y)` with `X != Y` where
      **both** `X` and `Y` recorded the state exactly `NOT_MERGED`, run
      `cleanup_wt_git merge-base --is-ancestor "$X" "$Y"` with its exit code captured via `|| mrc=$?`,
      treating exit 0 as "X is an ancestor of Y", exit 1 as "not an ancestor", and any exit above 1 as a
      hard failure that emits no `CHILD_OF` record for that pair, leaves `X`'s already-recorded
      `BRANCH|` line untouched, and raises `rc` to at least 2; append
      `CHILD_OF|X|<Y>` to `X`'s recorded output for the `LC_ALL=C`-first such `Y`, so the record is
      deterministic when a branch has several `NOT_MERGED` ancestor-targets; and finally emit each
      branch's recorded lines in `enumerate_branches`' original order, returning `rc`. The function must
      contain no branch that emits a `BRANCH|` line the ladder did not produce, other than the
      unchanged pre-existing behavior in which `classify_branch` itself emits `ANCESTRY_ERROR`.
      Rewrite the function's header comment to state D1's finding: the ladder's rung 5 decides each
      residual commit by comparing the branch tip's blob against `main`, so a merged-ness verdict cannot
      be derived from any ancestor's verdict at any rung; the `CHILD_OF` record is therefore
      informational and no rung is ever skipped. The header must not retain the sentence "a branch
      contained in a branch that is not merged cannot itself be merged" (currently line 339), which is
      the false premise the rewrite removes. Acceptance: a Grep of the file for the literal
      `cannot itself be merged` returns no match; a Grep for the literal `BRANCH|$x|NOT_MERGED` returns
      no match; the file still contains the literal `CHILD_OF|` and the function still calls
      `classify_branch`.
- [x] [P5-T2] `[EXECUTOR]` Delete `cleanup_wt_protected_branches` from
      `scripts/bash/cleanup_worktrees_report_records_lib.sh` (function body currently lines 275-315),
      together with the deferred-branch protection block inside the old driver that was its only caller
      (currently lines 419-429). Its documented purpose — preventing a protected branch from inheriting
      `NOT_MERGED` — no longer exists, and under D2 `main` is excluded from the probe set by its own
      `PROTECTED_CURRENT` verdict. Acceptance: a Grep for the literal
      `cleanup_wt_protected_branches` scoped to `scripts/` and `tests/` returns no match. That grep
      returns exactly two matches under `scripts/` today — the function definition at
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:275` and its sole call site at
      `scripts/bash/cleanup_worktrees_report_records_lib.sh:429`, inside the deferred-branch
      protection block — and zero matches under `tests/`, so the condition is failable. Matches
      outside `scripts/` and `tests/` are out of scope for this condition: the literal also appears in
      `docs/features/**` review artifacts, in this plan, in
      `artifacts/orchestration/orchestrator-state.json`, and in
      `.claude/agent-memory/feature-review/project_631_child_of_short_circuit_defect.md`, and this
      cycle edits none of those files, so a repository-wide grep could not reach zero however the
      executor edits the source.
- [x] [P5-T3] `[EXECUTOR]` Update the `CHILD_OF` entry in the library header's report-line contract
      (`scripts/bash/cleanup_worktrees_report_records_lib.sh:27-30`) so it states that the record is
      advisory and informational, that both the branch and the named ancestor resolved exactly
      `NOT_MERGED` through their own unchanged ladders, and that it is emitted alongside — never instead
      of — the branch's own `BRANCH|` line. Remove any wording implying the verdict was inherited or
      that work was skipped. Acceptance: the header's `CHILD_OF|<branch>|<ancestor>` entry contains the
      literal `informational`, and a Grep of the file for the literal `inherit` returns no match.

### Phase 6 — Specification and Skill Documentation Corrections

- [x] [P6-T1] `[EXECUTOR]` Correct the subset-argument paragraph in
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
      (`### The CHILD_OF outcome-preservation invariant`, currently lines 158-171 — the section's
      preamble, ending at the sentence "This must be provable for both report mode and apply mode:"
      and stopping before the two bullets P6-T2 owns). Replace the sentence
      beginning "The subset argument that justifies skipping the expensive rungs holds only in the
      `NOT_MERGED` case" and the one-directional clause that follows it with a statement of D1's
      finding: ancestry determines a branch's state in neither direction, because the ladder's
      rung-5 residual test compares the branch tip's blob against `main` and two branches in an ancestor
      relationship have different tips; a branch that is merged into `main`, is content-neutral against
      `main`, or is content-equivalent to `main` can all be git ancestors of an unmerged branch. State
      that `CHILD_OF` is consequently an informational record and that no ladder rung is skipped for any
      branch. The rewritten preamble must also drop the two remaining mechanism claims it currently
      carries — "The `CHILD_OF` short-circuit MUST preserve that exact `BRANCH|X|NOT_MERGED` outcome"
      (line 163) and "The short-circuit changes classification **cost** only, never classification
      **outcome**." (line 170) — because under D1 there is no short-circuit whose cost or outcome can
      be described. The replacement text must not use the word `subset` or the word `short-circuit`,
      and must place the word `informational` on a single line rather than splitting it across a line
      break. Acceptance: the rewritten preamble contains the literal `informational` (which appears
      nowhere in this section today — its only occurrence in the file is at line 280, outside the
      section), contains no occurrence of the literal `short-circuit` (the preamble carries exactly two
      today, on lines 163 and 170, so the condition is failable), and a single-line token search of the
      whole file
      for the word `subset` returns no match. That token search returns exactly one match today, at
      line 165, so that condition is failable too. The two-word phrase `subset argument` is
      deliberately NOT used as the assertion: it wraps across lines 165 and 166 in the current file, so
      a line-oriented search for it already returns zero matches before any edit and could not fail.
- [x] [P6-T2] `[EXECUTOR]` Correct the two outcome-preservation bullets in the same `spec.md` section
      (currently lines 173-188). The report-mode bullet's clause "and the absence of the skipped rungs'
      side effects" must be replaced with a statement that the `BRANCH|` line is the byte-identical line
      `classify_branch` produced, because the driver calls it for every branch. The apply-mode bullet's
      reasoning about the `awk -F'|' '/^BRANCH\|/{print $3; exit}'` extraction being blind to an
      additive `CHILD_OF` line is correct as written and must be preserved, so no character of the
      apply-mode bullet (currently lines 177-188) may be edited by this task. The replacement text for
      the report-mode bullet must keep the two-word literal `skipped rungs` off every line, not merely
      break it across two, and must not use the word `short-circuit`. Acceptance: the report-mode
      bullet no longer contains the literal `skipped rungs` (currently one match, both words on line
      175, so the condition is failable), no longer contains the literal `short-circuit` (currently one
      match, on line 174, so that condition is failable too), and
      the apply-mode bullet still contains the literal `was never in the allowlist`, which sits
      unbroken on line 187. The longer form `NOT_MERGED was never in the allowlist` is deliberately NOT
      asserted: the file spells that state name with surrounding backticks
      (`` `NOT_MERGED` was never in the allowlist ``), so the unbackticked literal never matches and
      the assertion could not pass however the executor edits the file.
- [x] [P6-T3] `[EXECUTOR]` Correct the pairwise-probe hard-failure paragraph that closes the same
      `### The CHILD_OF outcome-preservation invariant` section (currently lines 190-194, immediately
      after the apply-mode bullet P6-T2 preserves verbatim and immediately before the
      `### Boundaries and invariants to preserve` heading at line 196). It currently states that a
      hard git failure of the new pairwise `merge-base --is-ancestor` probe "maps `X` to
      `ANCESTRY_ERROR`", which describes the mechanism D2 removes: under D2 the pairwise probe runs
      **after** classification, so mapping a probe failure onto `X`'s verdict would overwrite an
      already-correct `BRANCH|` line and would itself break the outcome-preservation invariant this
      very section states. Restate the paragraph as the delivered contract: a pairwise probe exiting
      above 1 emits no `CHILD_OF` record for that pair, leaves the branch's own `BRANCH|` line exactly
      as `classify_branch` produced it, and raises the driver's return code to 2 so the failure still
      surfaces in the exit status rather than degrading silently to "not an ancestor"; and a hard
      failure of the ladder's own rung-2 ancestry probe inside `classify_branch` is a separate,
      unaffected case that still maps to `BRANCH|<name>|ANCESTRY_ERROR` under the file's documented
      fail-closed convention. The replacement text must place the word `overwrite` unbroken on one
      line and must not reproduce the slash-list
      `enumeration/protection/cherry/diff-tree/ls-tree/rev-list`. This paragraph carries no occurrence
      of the literal `short-circuit`, so correcting it does not change the residue count recorded in
      the Scope boundary section. Acceptance: a single-line token search of `spec.md` for the word
      `overwrite` returns at least one match inside this paragraph (the word occurs nowhere in the
      file today, so the condition is failable), and a single-line token search of the whole file for
      the literal `ls-tree` returns no match (it returns exactly one match today, on line 192, inside
      this paragraph, so that condition is failable too).
- [x] [P6-T4] `[EXECUTOR]` Correct the `#### Performance constraints (latency/throughput/memory)`
      paragraph in the same `spec.md` (currently lines 317-323), which asserts a runtime reduction "by
      skipping the O(commits) `git cherry`/`diff-tree` rungs". Replace it with the delivered position:
      no rung is skipped, because no sound cut point exists; the pairwise ancestry probe is restricted
      to branches that both resolved `NOT_MERGED`, which bounds its cost at `k*(k-1)` probes for `k`
      such branches rather than `n*(n-1)` for `n` branches; and no latency number is asserted as an
      acceptance criterion. The replacement text must write the phrase `no rung is skipped` unbroken on
      one line. Acceptance: the paragraph no longer contains the literal `by skipping` (currently one
      match, both words on line 319, so the condition is failable), and contains the literal
      `no rung is skipped` on a single line.
- [x] [P6-T5] `[EXECUTOR]` Correct the `CHILD_OF` bullet in the `### In scope` list (currently lines
      87-89), which describes the record as "a cost-only classification short-circuit", and the
      `## Repro & Evidence` Expected bullet (currently lines 45-47), which states that such a branch "is
      short-circuited ... instead of re-classifying every commit, reducing report runtime". Both must be
      restated as the informational-record contract. The `Actual:` observations, including the
      approximately six-minute runtime, are historical facts about the 2026-09-06 run and must not be
      edited. Acceptance: neither the In-scope bullet nor the Expected bullet contains the literal
      `short-circuit`, and the `Actual:` block is unmodified.
- [x] [P6-T6] `[EXECUTOR]` Correct the three `CHILD_OF` items in the same `spec.md` `## Test Strategy`
      required-test-case list (currently lines 369-378: the positive case at 369-372, the negative
      case at 373-375, and the apply-mode case at 376-378). The positive case's clause requiring argv-log
      assertions "that none of `X`'s expensive-rung stub keys (`cherry.X`, `diff-tree.*`, `rev-list.X`)
      were invoked" must be replaced with the property the delivered design supports and this plan
      tests: the subject's own ladder ran, and the subject's `BRANCH|` line from the shared driver equals
      the line `classify_branch` produces for the same branch under the same fixture. Add one required
      case naming the three `child_of_subject_*` fixtures and the property they pin, namely that a
      subject resolving `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, or `MERGED_EQUIVALENT` reports that
      verdict even while it is a git ancestor of a `NOT_MERGED` branch. The negative case's clause
      "asserting the short-circuit does not apply" (currently line 374) must be restated as asserting
      that no `CHILD_OF` line is emitted and that `X` reports its own ladder verdict. The apply-mode
      case's phrase "for a `CHILD_OF`-short-circuited `NOT_MERGED` branch" (wrapping across lines 376
      and 377) must be restated as "for a `NOT_MERGED` branch carrying a `CHILD_OF` record", which is
      the property P2-T12's first test actually asserts and which matches the AC5(b) text P6-T8
      writes; the rest of that item, including "no deletion `ACTION` emitted", is correct and is
      preserved. None of the three rewritten items may use the word `short-circuit`. Acceptance: the
      three rewritten items no longer contain the literal `expensive-rung stub keys` (currently one
      match, all three words on line 372, so the condition is failable); a Grep of the whole
      `- Required test cases:` block for the literal `short-circuit` returns no match (the block runs
      from the `- Required test cases:` line, currently 368, to the line before
      `- Edge cases and negative scenarios:`, currently 383, and carries exactly two matches today, on
      lines 374 and 376, so the condition is failable — the block is named by its two boundary
      literals rather than by absolute line numbers because this task adds one required case and
      therefore shifts them); and the list contains the
      literal `child_of_subject_merged_equivalent` on a single line. The Grep is scoped to the
      required-test-case range rather than the whole file because sixteen correct or
      deliberately-out-of-scope occurrences of `short-circuit` remain elsewhere in `spec.md` after
      this cycle, as the Scope boundary section records, so a whole-file no-match assertion would be
      unsatisfiable.
- [x] [P6-T7] `[EXECUTOR]` Amend spec.md's AC3 (currently lines 415-420) to match the corrected
      contract: keep the positive/negative bats-pair requirement and the emission condition, and replace
      the trailing clause "that additionally asserts via argv-log checks that the expensive-rung stub
      keys were not invoked in the positive case" with a requirement that the positive case
      additionally assert the subject's `BRANCH|` line equals the line its own ladder produces under the
      same fixture. Leave the checkbox unchecked; P7-T6 checks it. Acceptance: AC3 no longer contains
      the literal `argv-log`, and its checkbox is `[ ]`.
- [x] [P6-T8] `[EXECUTOR]` Amend spec.md's AC5 (currently lines 424-428) to match the delivered
      contract. Its present text requires the invariant to be verified as "(a) the report-mode
      `BRANCH|<branch>|NOT_MERGED` line's value is unchanged whether or not the short-circuit fires,
      and (b) the apply-mode allowlist decision for a `CHILD_OF`-short-circuited branch is unchanged
      (no deletion `ACTION` emitted for a `NOT_MERGED` branch, short-circuited or not)". Under D1 there
      is no short-circuit, so both clauses name a mechanism the delivered code does not have. Restate
      AC5 as the two properties this plan actually tests: (a) for every branch, the `BRANCH|` line
      `classify_all_branches` emits is byte-identical to the line `classify_branch` produces for that
      same branch under that same fixture — the invariant is true by construction because the driver
      never substitutes a verdict of its own, and `CHILD_OF` is an additive informational record; and
      (b) apply mode emits no deletion `ACTION` for a `NOT_MERGED` branch carrying a `CHILD_OF` record,
      and does emit one for a delete-eligible branch that is a git ancestor of a `NOT_MERGED` branch.
      The replacement text must not use the word `short-circuit` in any form, and must place the token
      `classify_all_branches` unbroken on one line. Leave the checkbox unchecked; P7-T6 checks it.
      This task exists because AC5 was the one `short-circuit`-bearing acceptance criterion that
      P6-T1 through P6-T7 did not reach, and P7-T6 checks AC5 off. Acceptance: AC5's bullet contains
      the literal `classify_all_branches` on a single line, contains no occurrence of the literal
      `short-circuit` (its bullet carries three today, on lines 426, 427, and 428, so the condition is
      failable), and its checkbox is `[ ]`.
- [x] [P6-T9] `[EXECUTOR]` Correct the `CHILD_OF|<branch>|<ancestor>` bullet in
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` (currently lines 88-91), whose final clause
      reads "and records why that verdict was inherited rather than re-derived through the full ladder"
      and wraps across lines 90 and 91. Replace that clause with a statement that both branches
      resolved `NOT_MERGED` through their own full ladders and that the record names the containment
      relationship, so an operator can see that the branch's work is not lost when the named ancestor
      is retained. The replacement text must not use the word `inherited`. No other bullet in the
      Report Line Contract section may be modified. Acceptance: a single-line token search of
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` for the word `inherited` returns no match
      (it returns exactly one match today, at line 91, so the condition is failable), and the four
      literals `ORPHAN_DIR|`, `STALE_REF|`, `CHILD_OF|`, and `WARN|registration-lost|` all remain
      present. The two-word phrase `was inherited` is deliberately NOT used as the assertion: it wraps
      across lines 90 and 91 in the current file, so a line-oriented search for it already returns zero
      matches before any edit and could not fail.
- [x] [P6-T10] `[EXECUTOR]` Mirror the P6-T9 edit byte-identically into
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`,
      whose `CHILD_OF` bullet is currently byte-identical to the repo-side one and carries the same
      wrapped clause at lines 90-91. Acceptance: the two files' `CHILD_OF|<branch>|<ancestor>` bullets
      are byte-identical, verified by reading the same line range in both; and a single-line token
      search of the mirrored file for the word `inherited` returns no match (it returns exactly one
      match today, at line 91, so the condition is failable).
- [ ] [P6-T11] `[ORCHESTRATOR-RUN]` Run
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`
      (node ID verified in the predecessor plan's P9-T3 against
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106-131`). Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/skill-md-mirror-contract.2026-09-07T14-40.md`
      with the four required fields; `Output Summary:` must state the literal pytest summary token
      `1 passed`. Acceptance: `EXIT_CODE: 0` and `1 passed` is recorded.

### Phase 7 — Final QA Loop, Size Cap, and Acceptance-Criteria Reconciliation

- [x] [P7-T1] `[ORCHESTRATOR-RUN]` Run `bash scripts/bash/shell-qc.sh format`, then immediately run
      `git status --porcelain -- scripts/bash tests/shell tests/fixtures` and record its output
      verbatim, for the same write-mode reason stated in P0-T6. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-format.2026-09-07T14-40.md`
      with the four required fields. Acceptance: `EXIT_CODE: 0` and the porcelain observation is
      recorded. If the porcelain output shows this step rewrote any file, commit the rewrite and restart
      the loop from this task.
- [x] [P7-T2] `[ORCHESTRATOR-RUN]` Run `bash scripts/bash/shell-qc.sh check`. Record evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-check.2026-09-07T14-40.md`
      with the four required fields; `Output Summary:` states the shfmt-diff and shellcheck results.
      Acceptance: `EXIT_CODE: 0`. If this step fails, fix and restart the loop from P7-T1.
- [ ] [P7-T3] `[ORCHESTRATOR-RUN]` Commit and push Phases 3 through 6, then dispatch
      `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
      and read the completed run's log. Record the test evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test.2026-09-07T14-40.md`
      with `Timestamp:`, `Command: bash scripts/bash/shell-qc.sh test --coverage`, `EXIT_CODE:`, and an
      `Output Summary:` recording the dispatched commit sha, the run id, the bats TAP plan line, the
      `ok` count, the `not ok` count, and an explicit comparison of the total against the P0-T8 baseline
      count. `Output Summary:` must additionally quote the `ok` line for each of the twelve test titles
      this cycle authored, or renamed and rewrote: `child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict`;
      `child_of_not_merged: the driver's BRANCH line equals the ladder's own for the same branch`;
      `child_of_merged_equivalent: no CHILD_OF is emitted when the ancestor is not NOT_MERGED`;
      `child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported`;
      `child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported`;
      `child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported`;
      `apply mode emits no deletion for a NOT_MERGED branch carrying a CHILD_OF record`;
      `apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch`;
      `cleanup_wt_scan_roots derives both roots from the main worktree path`;
      `cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override`;
      `cleanup_wt_scan_roots emits no root when the worktree listing hard-fails`;
      `run_report performs exactly one filesystem scan`. Acceptance: `EXIT_CODE: 0`, the `not ok` count
      is `0`, the total is not lower than the P0-T8 baseline count, and all twelve titles appear as
      `ok`. If this step fails, fix and restart the loop from P7-T1.
- [ ] [P7-T4] `[ORCHESTRATOR-RUN]` From the same run log as P7-T3, record the coverage evidence at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/qa-gates/final-test-coverage.2026-09-07T14-40.md`
      with the four required fields; `Output Summary:` must include the literal printed line
      `Bash coverage (lines): NN.N%` with its exact numeric value, state that value alongside the P0-T9
      baseline value for a no-regression comparison, and state that bash has no branch-coverage gate per
      `.claude/rules/quality-tiers.md`. Acceptance: `EXIT_CODE: 0` and the recorded percentage is at
      least 85.0. This satisfies AC9 together with P7-T1 through P7-T3.
- [ ] [P7-T5] `[ORCHESTRATOR-RUN]` Run
      `wc -l scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_scan_helper.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/fixtures/cleanup_worktrees/stub-bin/scan`
      and record the exact printed counts at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/file-size-cap-verification.2026-09-07T14-40.md`
      with the four required fields. The pre-remediation counts for the two files closest to the cap
      are 491 for `cleanup_worktrees_lib.sh` and 463 for `cleanup_worktrees_report_records_lib.sh`,
      both re-derived against the current tree in `wc -l` terms (that is, counting newline-terminated
      lines; both files end with a trailing newline, so `wc -l` reports one less than the last line
      number a `cat -n`-style reader displays). Record the post-remediation delta for each. Acceptance: every
      printed count is at most 500. This satisfies AC8.
- [ ] [P7-T6] `[EXECUTOR]` Reconcile the acceptance-criteria checkboxes in `spec.md`. Check AC3 (as
      amended by P6-T7) and AC5 (as amended by P6-T8), citing the P7-T3 evidence artifact for the
      passing test titles that verify each. Leave AC6 unchecked and add no text to it; instead record, in the Acceptance Criteria
      Status block written by P7-T7, that AC6 remains unchecked because R-07 is explicitly deferred
      from this remediation cycle. No other checkbox may change state. Acceptance: AC3's and AC5's
      checkboxes are `[x]`, AC6's is `[ ]`, and the other eight are byte-identical to their
      pre-remediation state.
- [ ] [P7-T7] `[EXECUTOR]` Write the remediation closure record at
      `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/evidence/other/remediation-closure.2026-09-07T14-40.md`
      containing `Timestamp:`, one section per remediation item addressed (R-01, R-02, R-04) naming the
      implementing tasks, the tests that verify it, and the evidence artifact that records the passing
      run; an `Acceptance Criteria Status` block reporting 11 total, 10 checked, 1 remaining, and naming
      AC6 as the remaining item with R-07 as its deferral reason; and a `Deferred:` list naming R-05,
      R-06, R-07, and R-08 as out of scope for this cycle. Acceptance: the artifact exists with all
      three sections populated and the counts consistent with the checkbox state P7-T6 produced.

---

## Acceptance Criteria Traceability

| ID | Description | Implementing Tasks | Test Tasks | Evidence Tasks |
| --- | --- | --- | --- | --- |
| R-01 | Driver never reports a verdict the ladder did not produce; vacuous tests replaced; cut point tested | P5-T1, P5-T2, P5-T3 | P2-T1, P2-T2, P2-T3, P2-T4, P2-T6, P2-T7, P2-T8, P2-T9, P2-T10, P2-T11, P2-T12, P2-T15 | P2-T16, P7-T3 |
| R-02 | Exactly one `cleanup_wt_scan_records` call per `run_report` | P4-T1, P4-T2, P4-T3, P4-T4 | P2-T5, P2-T13, P2-T14 | P1-T2, P7-T3 |
| R-04 | `.claude/worktrees` root derived from the main worktree path | P3-T1 | P2-T14 | P2-T16, P7-T3 |
| AC3 | `CHILD_OF` positive/negative pair under the corrected contract | P5-T1, P6-T7 | P2-T6, P2-T7, P2-T15 | P7-T3, P7-T6 |
| AC5 | Outcome preservation, properties (a) and (b), non-vacuously | P5-T1, P6-T3, P6-T8 | P2-T7, P2-T8, P2-T9, P2-T10, P2-T12 | P7-T3, P7-T6 |
| AC8 | Every touched bash and bats file at or under 500 lines | P4-T3, P4-T4, P5-T2 | — | P7-T5 |
| AC9 | Toolchain loop passes, bash line coverage at least 85% | P7-T1, P7-T2 | P7-T3 | P7-T4 |

## Out-of-Scope Confirmation

No task in this plan touches R-05, R-06, R-07, or R-08. Specifically: no task edits
`scripts/bash/cleanup_worktrees_scan_helper.sh`; no task edits `usage()` in
`scripts/bash/cleanup-worktrees.sh`; no task changes `run_report`'s `rc` accumulation semantics beyond
substituting one call for three (P4-T4 preserves the existing `|| rc=$?` assignment form); no task adds
per-file coverage rows to a coverage artifact; and no task attempts an intermediate-tree dispatch for
AC6's sequencing clause. No task modifies detached-worktree classification, the dirt classifier, the
sanctioned removal manifest, `enforce-epic-worktree-removal-gate.ps1`, `enforce-epic-merge-gate.ps1`,
or the `collect_pr_context` TypeScript overview. No task introduces automatic deletion of an
`ORPHAN_DIR` or `STALE_REF` finding.

---

## Mandatory Adversarial Self-Review — Round 3 (Preflight Revision Delta)

Every citation this plan relies on was re-derived directly against the current repository tree in this
pass. No citation is carried forward from Round 1, from Round 2, from the predecessor plan, or from the
review artifacts; where any of those disagree with the tree, the tree is recorded and the earlier
claim is corrected in the plan text.

Scope note for this revision pass: this pass edited the plan document only. No file under `scripts/`,
`tests/`, `.claude/`, `extensions/`, or `spec.md` was modified by it, so the tree the citations below
describe is the same tree Rounds 1 and 2 observed. That is a reason the citations can still be
correct, not a reason to assume they are: every citation an edit in this pass touched, and every
citation in the sibling region of one, was re-read directly against the tree in this pass. Nine
defects were found and corrected: the seven the Round 2 preflight delta reported — five
citation-precision errors and two coverage gaps in which no task reached a region that describes a
removed mechanism — plus two further internal-consistency errors this pass found on its own by
re-deriving every count in the plan rather than only the counts the delta named. The two additional
findings were both in Round 2's own self-review prose: a whole-file `short-circuit|inherit` match
count for `test_cleanup_worktrees_classification.bats` recorded as eleven when the search returns
thirteen matching lines, and a claim that the two `scan_`/`cleanup_wt_scan` reachability searches are
"the basis for six of the ten call-site verdicts P1-T2 records" when they are the basis for exactly
three. Neither changed a task's acceptance condition, but both were assertions about the tree that the
tree did not support. The corrections are recorded inline below.

Round 3 correction summary (the seven items from the Round 2 preflight delta, plus the count and
cross-reference propagation each one required):

- **F-1.** `runin()` in `tests/shell/test_cleanup_worktrees_detached.bats` has thirty-two call sites,
  not fourteen. Re-derived in this pass by searching the whole file for `runin `: 8 sites pass
  `is_detached_candidate` (69, 71, 73, 75, 77, 79, 81, 83), 14 pass `run_apply` (95, 103, 113, 121,
  132, 144, 149, 193, 211, 227, 255, 270, 286, 314), 8 pass `classify_detached_head` (159, 167, 238,
  249, 264, 280, 298, 308), and 2 pass `reverify_detached_delete_eligible` (174, 324). The verdict is
  unchanged and its reasoning is now stated correctly: `run_apply` is defined at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:336`, and the other three at
  `scripts/bash/cleanup_worktrees_detached_lib.sh:41`, `:64`, and `:196`; a `scan_`/`cleanup_wt_scan`
  search returns zero matches in either file, re-run in this pass, so no scan function is reachable
  through any of the four. P1-T2's site-(7) bullet now carries this breakdown, and the corresponding
  self-review citation below carries the identical correction.
- **F-2.** P5-T2's acceptance condition demanded a repository-wide grep outcome the executor cannot
  produce. Re-derived in this pass: `cleanup_wt_protected_branches` occurs twice under `scripts/`
  (`cleanup_worktrees_report_records_lib.sh:275` definition, `:429` sole call site) and zero times
  under `tests/`, but also twice in `artifacts/orchestration/orchestrator-state.json` and once in
  `.claude/agent-memory/feature-review/project_631_child_of_short_circuit_defect.md` — both files
  confirmed present and matching in this pass, and neither is edited by this cycle. The condition is
  now scoped to `scripts/` and `tests/`, where it is failable and satisfiable.
- **F-3.** `spec.md:190-194` describes the probe-failure-to-`ANCESTRY_ERROR` mapping D2 removes, and
  it sits between the two regions P6-T1 and P6-T2 edit without being covered by either. New task
  P6-T3 corrects it; Phase 6's later tasks were renumbered to stay sequential; and AC5's Implementing
  Tasks column now names P6-T3 alongside P6-T8.
- **F-4.** The AC3 negative-case test `child_of_merged_equivalent`
  (`tests/shell/test_cleanup_worktrees_classification.bats:172-184`) carries `short-circuit` on lines
  172 and 182 and `inherit` on lines 174 and 180. New task P2-T15 renames its title and restates its
  comments without touching its six executable lines; the fail-before dispatch was renumbered to
  P2-T16; and the phase's green-versus-expected-red counts were re-derived rather than incremented.
- **F-5.** `spec.md:376` is a third `CHILD_OF` Test Strategy item carrying `short-circuit`. It is now
  corrected by P6-T6 rather than left as residue, and the Scope boundary section states the full
  arithmetic (28 occurrences today, 12 removed, 16 remaining) with the removing task named for each.
- **F-6.** `.github/workflows/_shell-coverage.yml` is 62 lines, not 63; re-read in this pass and the
  last content line is `if-no-files-found: error` at line 62.
- **F-7.** `CLEANUP_WT_SCAN_BIN` has three non-setting prose mentions under `tests/`, not two; the
  third is the `@test` title at `tests/shell/test_cleanup_worktrees_scan_seam.bats:16`. Re-derived in
  this pass: thirteen matches total, ten env-setting and three prose.

Line-count convention. All total-line-count figures in this section are `wc -l` counts, that is
newline-terminated lines. Every file cited below ends with a trailing newline, so a `cat -n`-style
reader displays one additional, empty final line number. Round 1 recorded that displayed number for
five files, each of which was one too high and was corrected in Round 2
(`cleanup_worktrees_report_records_lib.sh` 464 to 463,
`tests/shell/test_cleanup_worktrees_classification.bats` 208 to 207,
`tests/shell/test_cleanup_worktrees_deletion.bats` 141 to 140,
`tests/shell/test_cleanup_worktrees_report_records.bats` 76 to 75, and `spec.md` 486 to 485), and the
same stale 464 figure was corrected inside P7-T5. Round 2 missed one instance of the same error:
`.github/workflows/_shell-coverage.yml` was recorded as 63 and is 62. It is corrected in this pass.
`scripts/bash/cleanup_worktrees_lib.sh` was re-read to its end and its last content line is 491
(`}` closing `run_report`), so its 491 figure was already a `wc -l` count and is unchanged.

Citations re-derived in this pass:

- `scripts/bash/cleanup_worktrees_report_records_lib.sh` — full file re-read in this pass, 463 lines
  total (`wc -l`; last content line 463 is the `}` closing `classify_all_branches`).
  `cleanup_wt_scan_bin` 42-59; `scan_stale_refs` 61-108; `cleanup_wt_scan_roots` 110-143 with the bare
  `printf '%s\n' ".claude/worktrees"` at 131 and the `parse_worktree_list` capture at 133;
  `cleanup_wt_scan_records` 145-183 with the empty-roots early return at 160-162 and the two
  `"$bin" scan-dirs "${roots[@]}"` invocation forms at 171 and 173, which is where the `scan-dirs`
  argv P1-T2 reasons about originates;
  `scan_orphan_dirs` 185-232 with its `cleanup_wt_scan_records` call at 200;
  `scan_registration_loss` 234-273 with its call at 253 and the "one consistent view of the filesystem"
  sentence at 243-244; `cleanup_wt_protected_branches` 275-315; `classify_all_branches` 317-463 with
  the false premise sentence at 339, the pairwise probe loop at 377-398, the phase-2a loop at 400-410,
  the protection block at 419-429, and the inheritance block at 435-447.
- `scripts/bash/cleanup_worktrees_lib.sh` — read in four spans covering lines 1-100, 100-219, 219-300,
  and 300-491. `classify_ancestry` 57-78; `classify_content_neutral` 80-103;
  `classify_cherry_equivalent` 105-174; `_blob_equal` 176-188; `classify_residual_commit` 190-257 with
  the tip-relative blob comparisons at 228 and 246; `select_cherry_pick_candidates` 259-311;
  `classify_branch` 313-448 with the terminal state selection at 423-437; `run_report` 450-491 with
  `check_main_freshness` at 473, the three scan calls at 474-476, the `WORKTREE|` loop at 477-483, and
  `report_detached_worktrees` at 484. The 450-492 span was re-read in this pass: the last content line
  is 491, so the total is 491 in `wc -l` terms, matching the feature audit's AC8 figure.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — `reverify_delete_eligible` 238-270;
  `remove_worktree_safe` 272-299; `delete_branch` 301-315 emitting `ACTION|branch-delete|<name>|OK` at
  310; `delete_candidate` 317-334; `run_apply` 336-417 with the per-name extraction filter at 399-400,
  the state extraction at 402, and the delete-eligible allowlist at 409-412. Searched again in this
  pass for `scan_` and `cleanup_wt_scan`: no match anywhere in the file, so apply mode reaches no scan
  function. The same search returns no match in `scripts/bash/cleanup_worktrees_detached_lib.sh`
  either, so detached reporting and the three detached-classification entry points
  (`is_detached_candidate` at `:41`, `classify_detached_head` at `:64`, and
  `reverify_detached_delete_eligible` at `:196`) reach none of them.
  **Correction.** Round 2 recorded these two searches as "the basis for six of the ten call-site
  verdicts P1-T2 records". Re-derived in this pass, they are the basis for exactly three: sites (2)
  `apply()` in `test_cleanup_worktrees_deletion.bats`, (4) the inline apply-mode case at
  `test_cleanup_worktrees_cli.bats:48`, and (7) `runin()` in
  `test_cleanup_worktrees_detached.bats`. Those are the three sites that retain stderr and reach only
  functions in these two files. The verdicts for sites (1), (5), and (8) rest on stderr suppression
  instead; (3) and (6) are the two sites that DO reach a scan function; and (9) and (10) rest on the
  `cleanup_wt_scan_bin` resolver body at
  `scripts/bash/cleanup_worktrees_report_records_lib.sh:42-59`. Three plus three plus two plus two is
  the full ten.
- `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — `parse_worktree_list` 85-148, confirming the
  emitted record's first field is the raw worktree path (`printf '%s|%s|%s|%s\n'` at 117);
  `normalize_wt_path` 150-164.
- `scripts/bash/cleanup_worktrees_scan_helper.sh` — full file read, 157 lines; not modified by this
  plan.
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — full file read, 246 lines. The argv log at 57; the
  `respond()` no-file behavior at 67-81; the `for-each-ref` pattern-key logic at 109-124; the
  target-aware `merge-base` key with bare fallback at 133-149; the `rev-list` range key at 150-158; the
  `diff --quiet` key at 159-177; the `cherry` key at 178-181; the `diff-tree` last-argument key at
  182-187; the `rev-parse` keys at 202-212. Confirmed that `diff-tree --no-commit-id -r <sha>` and
  `diff-tree --no-commit-id --name-status -r -M <sha>` derive the same `diff-tree.<sha>` key, which is
  why one `.out` file serves both the rung-4 emptiness probe and the rung-5 name-status parse.
- `tests/fixtures/cleanup_worktrees/stub-bin/scan` — full file read, 50 lines; confirmed it writes
  nothing to stderr today, which is why P1-T1 is required for P2-T14's fourth test to be able to fail.
- `tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged/` — directory listing plus the
  contents of `for-each-ref.out` (`feature-child cccc4444`, `feature-parent cccc3333`, `main aaaa0000`),
  `merge-base.feature-child.main.rc` (`1`), `merge-base.feature-parent.rc` (`1`),
  `merge-base.main.rc` (`1`), `diff-quiet.feature-parent.rc` (`1`), `cherry.feature-parent.out`
  (`+ dead0001`), `rev-parse.feature-parent_src_app.py.out` (`blobbranchAAA`),
  `rev-parse.main_src_app.py.out` (`blobmainBBB`), `rev-parse.abbrev-ref-HEAD.out` (`main`),
  `rev-parse.show-toplevel.out` (`/repo/main`), and `worktree-list.out` (the four-line main stanza).
  Confirmed `diff-quiet.feature-child.rc` is absent, which is CR-01's Evidence 1 and the basis for
  P2-T1.
- `tests/fixtures/cleanup_worktrees/scenarios/child_of_merged_equivalent/` and
  `.../child_of_ancestry_probe_error/` — directory listings; `for-each-ref.out` and
  `merge-base.feature-parent.rc` of the former read directly. Re-verified against the corrected
  algorithm: under D1 and D2, `child_of_merged_equivalent`'s three existing assertions
  (`BRANCH|feature-parent|MERGED_EQUIVALENT`, `BRANCH|feature-child|NOT_MERGED`,
  `cherry main feature-child` present, no `CHILD_OF|` line) all still hold, because only
  `feature-child` resolves `NOT_MERGED` and a single-member probe set yields no pair; and
  `child_of_ancestry_probe_error`'s two assertions still hold because its `merge-base.feature-child.rc`
  value of 128 is reached by `classify_ancestry`'s own rung-2 probe through the same bare-key fallback.
  Neither fixture requires a data change; only the latter's comment is updated (P2-T11).
- `tests/fixtures/cleanup_worktrees/scenarios/unmerged/` — full file listing plus the contents of
  `cherry.feature-unmerged.out`, `diff-tree.dead0001.out`, `diff-quiet.feature-unmerged.rc`,
  `rev-list.feature-unmerged.out`, and both `rev-parse.*_src_app.py.out` files. This is the template
  the base set in Phase 2 mirrors.
- `tests/fixtures/cleanup_worktrees/scenarios/residual_on_main/` — file listing; confirmed the
  `MERGED_EQUIVALENT`-at-rung-5 shape (cherry `+`, non-empty diff-tree, equal branch and main blobs)
  that P2-T4 reproduces.
- `tests/fixtures/cleanup_worktrees/scenarios/orphan_dir_present/worktree-list.out` — first stanza path
  `/repo/main`, which is what makes P2-T14's derived-root assertions (`/repo/main/.claude/worktrees`
  and `/repo/main-wt`) exact rather than approximate.
- `tests/fixtures/cleanup_worktrees/scenarios/worktree_list_error/` — file listing; confirmed
  `worktree-list.rc` is present, which is what makes P2-T14's third test reach the
  `parse_worktree_list` hard-failure branch.
- `tests/shell/test_cleanup_worktrees_classification.bats` — 207 lines (`wc -l`). `setup()` 8-19
  (already declares `RLIB` and `SCAN`); `cb()` 21-26; `classify_all()` 28-38, re-read in this pass and
  confirmed to set only `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` at line 36 — it is NOT a
  `CLEANUP_WT_SCAN_BIN` setter, which corrects the claim P1-T2 carried before this revision;
  `report()` 40-49 with its env at line 46 and its `run_report 2>/dev/null`; the
  `child_of_not_merged` positive test 153-170 (its three negative argv assertions at 165, 167, 169);
  `child_of_merged_equivalent` 172-184; `child_of_ancestry_probe_error` 186-193; the vacuous
  outcome-preservation test 195-207. A repository-wide search for `cccc4444` under `tests/` returns
  one match in this file, at line 167, plus three `for-each-ref.out` fixture lines, so P2-T6's
  no-match acceptance is failable and is scoped to this file.
  **Correction (F-4).** A case-insensitive whole-file search for `short-circuit|inherit`, run in this
  pass, returns thirteen matching lines in this file: lines 30 and 35 (the `classify_all()` helper comment,
  covered by P2-T6); 82 (the `@test` title
  `"content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit"`); 153 and 155 (the
  positive test's title and comment, covered by P2-T6); 172, 174, 180, and 182 (the
  `child_of_merged_equivalent` negative test's title and comments); and 195, 196, 198, and 203 (the
  vacuous outcome-preservation test, whose body and title P2-T7 replaces). Round 2's plan covered
  every one of these except line 82 and the four in the negative test. Line 82 is deliberately out of
  scope: it correctly describes the ladder's own rung-3 `diff --quiet` early exit and is unrelated to
  the `CHILD_OF` mechanism D1 removes, so it is left alone — which is why P2-T6's and P2-T15's
  no-match conditions are scoped to the `classify_all()` helper block and to the
  `child_of_merged_equivalent` `@test` block respectively, named by their opening literals, rather
  than being widened to a whole-file search that could never reach zero. The four in the negative
  test are the genuine gap: that test is the sibling P2-T6 stopped one test short of, and new task
  P2-T15 now covers it. The negative test's own line range was re-read in this pass: its executable
  lines are the `classify_all` call at 176 and the assertions at 177 (`[ "$status" -eq 0 ]`), 178
  (`BRANCH|feature-parent|MERGED_EQUIVALENT`), 179 (`BRANCH|feature-child|NOT_MERGED`), 181
  (`cherry main feature-child` present), and 183 (no `CHILD_OF|`), and P2-T15 forbids editing any of
  them.
- `tests/shell/test_cleanup_worktrees_deletion.bats` — 140 lines (`wc -l`). `setup()` 10-23;
  `apply()` 25-33 with its env at line 30 and no stderr redirection; the vacuous apply-mode test
  130-140, re-read in this pass, with its title carrying `short-circuit` on line 130, a comment
  carrying it again on line 132, and its four assertions at 136, 137, 138, and 139. P2-T12 renames the
  title and rewrites the comment, removing both occurrences, and keeps the four assertions unchanged;
  those two lines are the only occurrences of the literal in this file.
- `tests/shell/test_cleanup_worktrees_report_records.bats` — full file re-read in this pass, 75 lines
  (`wc -l`). `setup()` 10-20 (declares `ELIB` and `RLIB` but not `LIB` or `DLIB`, which is why P2-T13
  is required before P2-T14's fourth test can source `run_report`); `rr()` 22-28 with its env at line
  25 and its trailing `2>/dev/null`; the six existing scan tests 30-75, whose six `$output` equality
  assertions sit at lines 36, 43, 51, 59, 67, and 74.
- `tests/shell/test_cleanup_worktrees_hard_failures.bats` — `setup()` 12-24; `runin()` 26-37 re-read in
  this pass, confirming its env at line 34 and that its `bash -c` string appends `2>/dev/null`, so
  P1-T1's new stderr line cannot reach any assertion in that file; its `run_report` call at 96 and its
  `run_apply` calls at 105 and 113.
- `tests/shell/test_cleanup_worktrees_cli.bats` — read lines 1-60 in this pass. `setup()` 8-16; the
  report-mode test 30-45 with its env at line 34, no stderr redirection, and its six substring
  assertions at 38, 39, 41, 42, 43, and 44; the apply-mode test 47-58 with its env at line 48. This
  file was absent from P1-T2's list before this revision and is one of the two sites where a
  `stub-scan:` line can reach `$output`.
- `tests/shell/test_cleanup_worktrees_detached.bats` — read lines 1-55, plus a whole-file search for
  `runin ` re-run in this pass. Header note that both helpers retain stderr at 11-15; `setup()`
  17-29; `report()` 31-41 with its env at line 38; `runin()` defined at 43-47 with its env at line 44.
  **Correction (F-1).** Round 2 recorded that `runin()` has fourteen call sites and that all of them
  pass `run_apply`. It has thirty-two, passing four distinct invocations: `is_detached_candidate` at
  69, 71, 73, 75, 77, 79, 81, and 83; `run_apply` at 95, 103, 113, 121, 132, 144, 149, 193, 211, 227,
  255, 270, 286, and 314; `classify_detached_head` at 159, 167, 238, 249, 264, 280, 298, and 308; and
  `reverify_detached_delete_eligible` at 174 and 324. Round 2's fourteen was the `run_apply` subset
  only. The verdict for this site is unchanged — no `stub-scan:` line can reach `$output` — but its
  basis is broader than Round 2 recorded: `run_apply` is defined at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:336`, and `is_detached_candidate`,
  `classify_detached_head`, and `reverify_detached_delete_eligible` at
  `scripts/bash/cleanup_worktrees_detached_lib.sh:41`, `:64`, and `:196`; a `scan_`/`cleanup_wt_scan`
  search re-run in this pass returns zero matches in either file, so none of the four reaches a scan
  function. Also re-verified in this pass: the anchored count assertion
  `grep -c '^WORKTREE|/repo-wt/det'` at line 54, and that a search of the whole `tests/shell` tree for
  `[ "$output" = ` returns no match in this file, so no equality assertion here can be perturbed by an
  added stderr line. This file's `report()` is the second of the two sites where a `stub-scan:` line
  can reach `$output`.
- `tests/shell/test_cleanup_worktrees_scan_seam.bats` — full file read, 28 lines (`wc -l`). Its two
  tests at 16-21 and 23-28 set `CLEANUP_WT_SCAN_BIN` at lines 17 and 24 but invoke only
  `cleanup_wt_scan_bin`, which echoes a path and never executes the binary, so the equality assertion
  at line 20 cannot be perturbed by P1-T1. **Correction (F-7).** Line 16 is the `@test` title
  `"cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override"`, which mentions
  `CLEANUP_WT_SCAN_BIN` without setting it. Round 2's P1-T2 text counted two non-setting prose
  mentions under `tests/` and omitted this one. The re-derived whole-`tests/` search in this pass
  returns thirteen matches: ten env-setting sites (`test_cleanup_worktrees_classification.bats:46`,
  `test_cleanup_worktrees_detached.bats:38` and `:44`, `test_cleanup_worktrees_deletion.bats:30`,
  `test_cleanup_worktrees_cli.bats:34` and `:48`, `test_cleanup_worktrees_scan_seam.bats:17` and
  `:24`, `test_cleanup_worktrees_report_records.bats:25`, and
  `test_cleanup_worktrees_hard_failures.bats:34`) across seven `tests/shell/*.bats` files, plus three
  non-setting mentions at `test_cleanup_worktrees_scan_helper.bats:3`,
  `test_cleanup_worktrees_scan_seam.bats:16`, and
  `tests/fixtures/cleanup_worktrees/stub-bin/scan:3`. The ten-site enumeration in P1-T2 is unchanged
  and confirmed complete; only the prose-mention count was wrong.
- `scripts/bash/cleanup-worktrees.sh` (`main`) — re-read in this pass at 94-119: the empty and
  `report` commands dispatch `run_report` at 103-105, and `--apply`/`apply` dispatch `run_apply` at
  106-108. This is what establishes that the cli suite's apply-mode test cannot reach the scan seam.
- `scripts/bash/shell_qc_lib.sh` — `print_coverage_summary`'s
  `printf 'Bash coverage (lines): %s%%\n'` at 291 and `run_test_coverage` at 294, with its documented
  "stopping at the first failure" behavior at 302-303, both re-read in this pass because P2-T16's
  edited text cites them.
- Repository-wide search for the literal `CLEANUP_WT_ORPHAN_ROOTS` under `tests/` — no match; and a
  repository-wide search for `cleanup_wt_scan_roots` and `cleanup_wt_scan_records` — matches only in
  `scripts/bash/cleanup_worktrees_report_records_lib.sh` and in `docs/features/**` review artifacts,
  with no match in any test file. This is the basis for the D5 correction to CR-04's parenthetical.
- Repository-wide search for the literal `cleanup_wt_protected_branches`, re-run in this pass.
  **Correction (F-2).** Round 2 recorded matches "only in
  `scripts/bash/cleanup_worktrees_report_records_lib.sh` and in `docs/features/**` review artifacts",
  and P5-T2's acceptance condition was written against that claim. The re-derived match set is wider:
  `scripts/bash/cleanup_worktrees_report_records_lib.sh:275` (the definition) and `:429` (the sole
  call site, inside the deferred-branch protection block); five lines of this plan and three lines
  across `remediation-inputs`, `policy-audit`, and `feature-audit` under `docs/features/**`;
  `artifacts/orchestration/orchestrator-state.json` (2 occurrences); and
  `.claude/agent-memory/feature-review/project_631_child_of_short_circuit_defect.md` (1 occurrence).
  The last two files were confirmed present and confirmed matching by a direct per-file search in this
  pass, and neither is edited by any task in this cycle, so P5-T2's original repository-wide no-match
  condition was unsatisfiable. P5-T2 now scopes the grep to `scripts/` and `tests/`, where it returns
  two matches today and must return zero after the deletion, and states the out-of-scope files
  explicitly. There is no match under `tests/` today, which is consistent with D3's claim that the
  function is untested dead code once inheritance is removed.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` — the Report Line Contract bullets at 80-94, with
  the `CHILD_OF` bullet at 88-91. Re-read in this pass: the clause ends `...records why that verdict
  was` on line 90 and continues `inherited rather than re-derived through the full ladder.` on line
  91, so the two-word phrase `was inherited` spans the line break and a line-oriented search for it
  returns zero matches before any edit. The single word `inherited` occurs exactly once in the file,
  on line 91, which is why P6-T9 now asserts that token instead.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  — lines 86-93 read in this pass and confirmed byte-identical to the repo-side file over the
  `CHILD_OF` bullet at 88-91, with the same single `inherited` occurrence on line 91. This is what
  makes P6-T10's byte-identity acceptance a real comparison rather than an assumption.
- `scripts/bash/cleanup-worktrees.sh` (`usage`) — `usage()` text at 40-91. Confirmed the `CHILD_OF` sentence at
  62-63 states only the emission condition and makes no claim about inheritance or skipped work, so no
  `usage()` edit is required by this cycle and R-08's two `usage()` items stay out of scope.
- `scripts/bash/shell_qc_lib.sh` — `run_test` 226-254; `extract_cobertura_line_rate` 256-275;
  `print_coverage_summary` 277-292.
- `.github/workflows/_shell-coverage.yml` — 62 lines (`wc -l`; last content line 62 is the
  `if-no-files-found: error` key, re-verified in this pass; Round 2 recorded 63, which was the
  `cat -n`-displayed empty line number produced by the file's trailing newline, and is corrected
  here). The two shell-qc steps at 51-55, which is
  the basis for this plan's execution-role split and for recording
  `Command: bash scripts/bash/shell-qc.sh test --coverage` on the `test`-stage artifacts.
- `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md` — 485
  lines (`wc -l`; last content line 485 is the closing `Links:` continuation, re-read in this pass).
  The invariant section 158-194, re-read in this pass, with the word `subset` occurring exactly once
  in the whole file, at line 165, and the phrase it opens wrapping onto line 166; the report-mode
  bullet 173-176 carrying `skipped rungs` unbroken on line 175; the apply-mode bullet 177-188 carrying
  `` `NOT_MERGED` was never in the allowlist `` on line 187, with the state name backticked, which is
  why P6-T2 now asserts the shorter `was never in the allowlist`; the In-scope `CHILD_OF` bullet at
  87-89; the Expected bullet at 45-47; the performance paragraph at 317-323 with `by skipping`
  unbroken on line 319; the Test Strategy required-case list opening at line 368
  (`- Required test cases:`); the acceptance criteria at 407-448 with AC3 at 415-420 (`argv-log` on
  line 419), AC5 at 424-428 (three occurrences of `short-circuit`, on lines 426, 427, and 428, which
  is the defect P6-T8 now corrects), and AC6 at 429-432. The literal `informational` occurs exactly
  once in the file, at line 280, outside every section this plan edits, so P6-T1's positive assertion
  is failable. `classify_all_branches` occurs at 220, 248, and 466 and nowhere inside AC5's 424-428
  range, so P6-T8's positive assertion on it is failable too.
  **Correction (F-3).** The invariant section does not end at line 188. Lines 190-194, re-read in this
  pass, are a pairwise-probe hard-failure paragraph stating that a probe exit above 1 "maps `X` to
  `ANCESTRY_ERROR`". That is the verdict-overwrite mechanism D2 removes, and no Round 2 task reached
  it: P6-T1 stops at 171 and P6-T2 covers 173-188. New task P6-T3 corrects it. Its two assertion
  tokens were derived in this pass rather than assumed: `ls-tree` occurs exactly once in the whole
  file, on line 192 inside this paragraph (as part of the slash-list
  `enumeration/protection/cherry/diff-tree/ls-tree/rev-list`), so the negative assertion is failable;
  and `overwrite` occurs nowhere in the file today, so the positive assertion is failable. Both are
  single words and therefore wrap-immune. This paragraph carries no occurrence of `short-circuit`, so
  it does not change the residue arithmetic.
  **Correction (F-5).** The `short-circuit` residue count was one too low. A whole-file search re-run
  in this pass returns twenty-eight lines carrying the literal: 28, 45, 60, 87, 106, 119, 152, 163,
  170, 174, 182, 185, 186, 198, 259, 291, 303, 312, 318, 322, 374, 376, 426, 427, 428, 455, 457, and
  465. Round 2's Scope boundary paragraph listed sixteen survivors and omitted line 376 from both the
  survivor list and the removal set, so the accounting did not close. Line 376 opens a third
  `CHILD_OF` Test Strategy item — the apply-mode case at 376-378, immediately after the positive case
  at 369-372 and the negative case at 373-375 that Round 2's P6-T5 already edited — and it states the
  same apply-mode property AC5(b) states. It is now corrected by P6-T6 rather than declared residue,
  because leaving it while P6-T8 rewrites AC5(b) would leave the specification internally inconsistent
  on the one criterion this cycle checks off. With line 376 removed, twelve occurrences are removed
  and sixteen survive, and the sixteen-line survivor list is unchanged from Round 2's; the Scope
  boundary section now states the full arithmetic with a removing task named for each removed line.
- `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/issue.md` — the
  `- Work Mode: full-bug` marker at line 12, which fixes the mode for this plan per the contract's mode
  source precedence.

Sibling-region checks performed alongside each edited citation:

- `run_report`'s `WORKTREE|` loop (`cleanup_worktrees_lib.sh:477-483`) and its
  `report_detached_worktrees` call (484) sit immediately after the three lines P4-T4 replaces; both were
  re-read and confirmed independent of the scan calls, so substituting one call for three cannot
  reorder or drop them.
- `cleanup_wt_scan_records`'s empty-roots early return (`cleanup_worktrees_report_records_lib.sh:160-162`)
  sits immediately after the `cleanup_wt_scan_roots` consumer loop that P3-T1 changes the input of; it
  was re-read and is what makes D5's "emit no root on hard failure" degrade to silence with exit 0
  rather than to an error.
- `scan_stale_refs` (`:61-108`) sits immediately before `cleanup_wt_scan_roots` and does not consume
  the scan seam at all; it was re-read and confirmed unaffected by P3-T1 and by P4-T1 through P4-T3,
  which is why `run_report_scans` calls it outside the records-passing path.
- `classify_branch`'s rung-1 protection block (`cleanup_worktrees_lib.sh:366-369`) sits immediately
  before the ladder rungs P5-T1 reasons about; it was re-read and is what makes D3's removal of
  `cleanup_wt_protected_branches` safe, because `main` receives `PROTECTED_CURRENT` from that block and
  is therefore excluded from D2's `NOT_MERGED`-only probe set without any separate protection lookup.
- `classify_all_branches`' final emission loop (`cleanup_worktrees_report_records_lib.sh:457-461`) sits
  immediately after the block P5-T1 rewrites; it was re-read and its `enumerate_branches`-order
  guarantee is preserved verbatim by the rewrite's final step.
- The `cb()` helper (`test_cleanup_worktrees_classification.bats:21-26`) sits immediately before
  `classify_all()` and appends `2>/dev/null` to its `classify_branch` invocation; it was re-read and
  confirmed to be the right instrument for the ladder side of P2-T7's, P2-T8's, P2-T9's, and P2-T10's
  equality comparisons, because its `$output` carries the `BRANCH|` line with no argv-log interleaving.
- The `apply()` helper (`test_cleanup_worktrees_deletion.bats:25-33`) sits immediately before the test
  P2-T12 rewrites and retains stderr; it was re-read together with `run_apply` to confirm that no scan
  function is reachable from apply mode, so P1-T1's new `stub-scan:` line cannot appear in that file's
  `$output` and cannot collide with its negative argv assertions.
- The six existing scan tests (`test_cleanup_worktrees_report_records.bats:30-75`) sit immediately
  before the block P2-T14 appends to and call `scan_orphan_dirs` and `scan_registration_loss` with no
  argument; they were re-read and are the reason P4-T1 and P4-T2 use an optional parameter with a
  self-scan fallback rather than a required parameter. Re-checked in this pass against P3-T1 as well,
  because P3-T1 changes the roots those functions scan under: the equality assertion at line 51
  (`ORPHAN_DIR|.claude/worktrees/agent-old|128K`) reads a path that comes from the scenario's
  `scan-dirs.out`, replayed verbatim by a stub that ignores its root arguments
  (`tests/fixtures/cleanup_worktrees/stub-bin/scan:42-50`), so changing the roots changes only the
  argv the stub is handed and leaves all six assertions' values unchanged. Without this check P3-T1
  would carry an unexamined risk of turning a passing sibling test red.

Sibling-region checks added by earlier revision passes and re-confirmed in this one:

- The apply-mode bullet (`spec.md:177-188`) is the sibling of the report-mode bullet P6-T2 edits and
  of AC5, which P6-T8 now edits. It was re-read in full. Its `awk` reasoning and its allowlist
  conclusion are correct under the delivered contract, and P6-T2 forbids editing it, so its three
  `short-circuit` occurrences (lines 182, 185, and 186) survive this cycle by decision. The same is
  true of `spec.md:198` and of twelve further occurrences at lines 28, 60, 106, 119, 152, 259, 291,
  303, 312, 455, 457, and 465, for sixteen survivors in total. The Scope boundary section records that
  residue explicitly, with its full arithmetic, so a later reader does not read it as an oversight.
  Re-checked in this pass: line 376 is NOT a survivor. It was absent from Round 2's tally on both
  sides of the ledger, and P6-T6 now removes it, which is why the survivor list above is unchanged
  while the removal set grew from eleven lines to twelve.
- AC3 (`spec.md:415-420`) sits two bullets above AC5 in the same acceptance-criteria list, separated
  from it only by the `WARN|registration-lost` criterion at 421-423. All three were re-read alongside
  the AC5 edit. AC3's correction is already carried by P6-T7, whose `argv-log` assertion target sits
  unbroken on line 419 and is therefore failable; the `WARN|registration-lost` criterion between them
  is checked `[x]` already, names no removed mechanism, and is left untouched, which is consistent
  with P7-T6's requirement that the other eight checkboxes stay byte-identical.
- `tests/shell/test_cleanup_worktrees_cli.bats` and `tests/shell/test_cleanup_worktrees_detached.bats`
  are the siblings P1-T2's original five-site list omitted. Both were read in this pass. They are the
  only two files where P1-T1's new stderr line can reach a test's `$output`, so omitting them left the
  audit unable to bound the blast radius it exists to bound. Both files' assertion shapes were checked
  and neither changes value under the added line. Re-checked in this pass: adding
  `test_cleanup_worktrees_detached.bats` in Round 2 introduced a call-site count that was itself
  wrong, which is F-1 above. The correction does not move either file in or out of the blast radius;
  it only widens the basis for the site-(7) verdict from one reachability search to two.
- `classify_all()` (`test_cleanup_worktrees_classification.bats:28-38`) is the sibling of `report()`
  in the same file. It was re-read and found NOT to set `CLEANUP_WT_SCAN_BIN`, contradicting P1-T2's
  pre-revision text. Re-reading it also surfaced a second, previously unrecorded invalidation: the
  helper's own comment carries `short-circuit` on lines 30 and 35 and states that the tests read the
  argv log to prove the expensive rungs were skipped, which is exactly the claim D1 withdraws. No task
  covered that comment before this pass; P2-T6 now does, and its acceptance condition names the two
  lines.

Sibling-region checks added by this revision pass (Round 3):

- The `child_of_merged_equivalent` test (`test_cleanup_worktrees_classification.bats:172-184`) is the
  sibling of the positive `child_of_not_merged` test P2-T6 rewrites: the two sit adjacent in the same
  file and are the two halves of AC3's required positive/negative pair. Round 2 corrected the positive
  test and the helper comment above it, and stopped one test short. Re-read in full in this pass: its
  title on line 172 and its comments on lines 174, 180, and 182 all describe inheritance or
  short-circuiting. This is the classic sibling-invalidation shape — P2-T6's rewrite makes the file
  internally contradictory, describing one mechanism in one test and its replacement in the adjacent
  one — and it is now covered by P2-T15.
- The `child_of_merged_equivalent` fixture
  (`tests/fixtures/cleanup_worktrees/scenarios/child_of_merged_equivalent/`) is the sibling region of
  that test and was re-listed in this pass to confirm P2-T15 is a comment-only change that keeps the
  test green in both states. The directory supplies `merge-base.feature-child.main.rc`,
  `diff-quiet.feature-child.rc`, `cherry.feature-child.out`, `diff-tree.deadc001.out`,
  `rev-list.feature-child.out`, and differing `rev-parse.feature-child_src_child.py.out` and
  `rev-parse.main_src_child.py.out` blobs, which is the `NOT_MERGED` shape for `feature-child`; and
  `merge-base.feature-parent.rc`, `diff-quiet.feature-parent.rc`, `cherry.feature-parent.out`,
  `diff-tree.res00001.out`, and identical `rev-parse.feature-parent_docs_readme.md.out` and
  `rev-parse.main_docs_readme.md.out` blobs, which is the `MERGED_EQUIVALENT` shape for
  `feature-parent`. `rev-parse.abbrev-ref-HEAD.out` names `main`, so `main` takes rung-1
  `PROTECTED_CURRENT`. Under the current code the short-circuit does not fire because `feature-parent`
  is not `NOT_MERGED`; under the rewritten driver the `NOT_MERGED` probe set has the single member
  `feature-child`, and a single-member set yields no ordered pair. Both states produce the same five
  assertion values, so the test is green before and after P5-T1 and does not join the expected-red
  set. This was verified against the fixture rather than inferred from the test's current pass state.
- `spec.md:190-194` is the sibling region of both `spec.md:158-171` (P6-T1) and `spec.md:173-188`
  (P6-T2): it is the closing paragraph of the same `### The CHILD_OF outcome-preservation invariant`
  section, and the section heading that follows it,
  `### Boundaries and invariants to preserve` at line 196, was read in this pass to fix the
  paragraph's end boundary. Correcting the section's preamble and bullets without correcting this
  paragraph would leave the section asserting an invariant in its first half and describing a
  mechanism that violates it in its last. P6-T3 now covers it.
- `spec.md:376-378` is the sibling of the two Test Strategy items P6-T6 already edited at 369-375 —
  the three are consecutive bullets in one `- Required test cases:` list — and it is also the Test
  Strategy counterpart of AC5(b), which P6-T8 rewrites. It was read in full in this pass and folded
  into P6-T6's scope.
- `test_cleanup_worktrees_classification.bats:82` was re-read in this pass as the sibling of every
  `short-circuit` assertion this plan authors against that file. Its `short-circuit` occurrence
  describes the ladder's own rung-3 `diff --quiet` early exit, is correct, and is out of scope. It is
  the reason no task in this plan asserts a whole-file no-match condition on that file; P2-T6 scopes
  its assertion to the `classify_all()` helper block (currently lines 28-38) and P2-T15 scopes its
  assertion to the `child_of_merged_equivalent` `@test` block (currently lines 172-184), each named by
  its opening literal so the condition survives the length change its own task produces.
- `tests/shell/test_cleanup_worktrees_deletion.bats:130-140` was re-read in this pass as the sibling
  of P2-T15's edit, because it is the other test in the suite whose title carries `short-circuit`. It
  is already covered by P2-T12, whose rename removes the occurrences on lines 130 and 132, so no
  further task is required. `tests/shell/test_cleanup_worktrees_detached.bats:6` and `:141` also carry
  `short-circuits`, but they describe the detached-worktree protection and prunable early exits and
  are unrelated to the `CHILD_OF` mechanism; they are out of scope and no task asserts against them.

Task-ordering satisfiability check (no rule covers this; performed by hand and re-derived in this
pass): P1-T1 precedes P2-T14's scan-count test, so the observable that test reads exists when it runs.
P2-T1 precedes P2-T6 and P2-T7, so `feature-child` resolves `NOT_MERGED` through its own ladder before
any test asserts that it does. P2-T13 precedes P2-T14, so `LIB`, `DLIB`, and `report_raw` exist before
the test that uses them. P2-T15 is a title-and-comment correction with no dependency on any other task
and no effect on any assertion value, so it is satisfiable at its position and its renamed title is
already in place when P2-T16 reads the TAP output; it also must precede P2-T16, because P2-T16's
acceptance condition enumerates `not ok` titles by their post-rename spelling and P2-T15's test must
appear as `ok` under its new title rather than as an unexplained extra. P2-T16 runs while the eight
named tests are red, which is the state its acceptance condition describes; the eighth of those, the
scan-count test, is red at that point specifically because Phase 4 has not landed, so P2-T16 must
precede Phase 4 and does. Every later gate runs after Phase 5, when all eight are green. P6-T3 edits a
paragraph disjoint from P6-T1's and P6-T2's ranges, so the three may run in any order within Phase 6
without one invalidating another's target; P6-T6 likewise edits a range disjoint from P6-T8's. P6-T8
precedes P7-T6, so AC5 carries the corrected text before the task that checks it off runs; the same
holds for P6-T7 and AC3. P0-T6's format run precedes all authoring, so the Phase 7 format run cannot
be a blanket waiver for pre-existing drift. P7-T5's size check runs after all file edits, and P7-T6's
checkbox reconciliation runs after P7-T3 has produced the evidence it cites.

Whole-plan consistency re-check performed in this pass (not limited to the seven delta items): every
task ID in Phases 0 through 7 was read in sequence and confirmed sequential within its phase (P0-T1
through P0-T9; P1-T1 through P1-T2; P2-T1 through P2-T16; P3-T1; P4-T1 through P4-T4; P5-T1 through
P5-T3; P6-T1 through P6-T11; P7-T1 through P7-T7). Every cross-reference to a renumbered task was
located by search and updated: the Phase 2 preamble, the Acceptance Criteria Inventory, the
traceability table's R-01, R-04, AC3, and AC5 rows, P6-T6's and P6-T8's own bodies, P7-T3's title
list, P7-T6's amendment references, and every reference inside this self-review section. Every count
the plan states was re-derived rather than incremented: twelve authored-or-renamed tests, four green
and eight expected-red in Phase 2; twelve titles in P7-T3's list; twenty-eight `short-circuit` lines
in `spec.md` today, twelve removed and sixteen surviving; thirty-two `runin()` call sites; ten
`CLEANUP_WT_SCAN_BIN` env-setting sites and three prose mentions; two `cleanup_wt_protected_branches`
matches under `scripts/` and zero under `tests/`; 62 lines in `_shell-coverage.yml`; thirteen
`short-circuit|inherit` matching lines in `test_cleanup_worktrees_classification.bats`; and three of
the ten P1-T2 call-site verdicts resting on the two library reachability searches. The last two of
those were found wrong in Round 2's prose and are corrected here.

Every acceptance condition authored or edited in this pass was checked against the wrap-tolerant
authoring rules before it was written: `overwrite`, `ls-tree`, `short-circuit`, and `inherit` are all
single-line, single-word, non-interpolated tokens carrying no `<`, `>`, `${`, `$(`, or `%`; each was
counted against the current tree so its pre-edit and post-edit values differ, which is what makes the
condition able to fail; and each no-match condition is scoped to the block its task rewrites rather
than to the whole file, because in every one of the three files concerned a correct, out-of-scope
occurrence of the same token survives this cycle and would make a whole-file assertion unsatisfiable.
No acceptance condition added in this pass asks the executor to select the evidence it is judged
against: P2-T15, P6-T3, and P6-T6 each name the exact file, the exact block, and the exact tokens.

SELF-REVIEW: RE-DERIVED THIS PASS
