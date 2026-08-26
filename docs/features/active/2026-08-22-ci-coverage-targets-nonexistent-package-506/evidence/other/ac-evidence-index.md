# Acceptance-Criteria Evidence Index (P5-T1)

Timestamp: 2026-08-25T22-41

Task: [P5-T1]
Class: **record-only task.** This task executes no command of its own, so per the plan's evidence
accounting rule it records `Timestamp:` and the substantive content the task text prescribes, and
carries **no** `Command:` row and **no** `EXIT_CODE:` row. Every artifact cited below was produced
by a task that recorded its own command and exit code, so each command remains auditable one hop
away.

Acceptance-criteria source of record: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`,
`## Acceptance Criteria` section. Work Mode is `full-bug`, so that section is the sole
acceptance-criteria source and `user-story.md` is intentionally absent. The section carries exactly
**nineteen** criteria, AC-1 through AC-19. The four impact/severity radios and the one
logs-attached checkbox sit outside that section and are not acceptance criteria.

All paths below are repo-relative. `FEATURE` abbreviates
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506` in the table only;
the full path is written out under each row group heading so no path is ambiguous.

---

## Why exactly four rows were marked `PENDING PHASE 6` when [P5-T1] wrote this index

This section is a historical record of the state [P5-T1] created. All four rows have since been
finalized by [P6-T7] and none remains pending; see the finalization note under the row table below.

Four criteria were deferred to [P6-T7] because the evidence this plan designates for each of them
could not exist until after the first commit at [P6-T1]:

- **AC-12** is a two-form criterion whose landed form is settled only at the Phase 6 pre-authorized
  D3 fallback branch, so which of its two tests is present is not yet known.
- **AC-14** and **AC-15** each state their observable as the committed-diff listing
  `git diff --name-only origin/main...HEAD`. The falsifiable form of both is [P6-T2], which runs
  immediately after the first commit. Their working-tree halves are gated at [P4-T9] and [P4-T10],
  but a working-tree half is not the observable the criterion states.
- **AC-17** requires a green workflow run against the branch head, which is evidenced only by the
  Phase 6 green-run artifact written by [P6-T5].

Checking any of the four off in Phase 5 would mark a criterion complete before its evidence exists,
which the acceptance-criteria tracking rules forbid. All four are finalized by [P6-T7], which
replaces the four rows below.

---

## The nineteen rows

| AC | Criterion (abbreviated) | Verifying test node ID | Verifying artifact |
| --- | --- | --- | --- |
| AC-1 | Workflow contains no `lexile_corpus_tuner` token | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_workflow_names_no_foreign_coverage_target` | `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md` |
| AC-2 | Pytest step uses bare `--cov` with `--cov-branch` | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_uses_bare_cov_with_branch` | `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md` |
| AC-3 | Pytest step emits the JSON coverage report | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_emits_json_coverage_report` | `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md` |
| AC-4 | Live corrected run measures a non-empty denominator | not test-carried; live-measurement observable | `FEATURE/evidence/baseline/corrected-coverage-command-repro.md` |
| AC-5 | A deliberate line-coverage regression fails the build | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_line_coverage_below_floor_exits_non_zero` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-6 | The branch floor is enforced independently of the line floor | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_branch_coverage_below_floor_exits_non_zero` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-7 | Both floors are inclusive at the boundary | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_line_coverage_at_floor_is_accepted` and `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_branch_coverage_at_floor_is_accepted` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-8 | A double breach reports both metrics | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_both_metrics_below_floor_are_both_reported` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-9 | Absent branch data fails loudly | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_absent_branch_data_exits_non_zero` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-10 | A missing or unparseable report fails loudly | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_missing_report_file_exits_non_zero` and `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_unparseable_report_exits_non_zero` | `FEATURE/evidence/regression-testing/checker-unit-tests-pass.md` |
| AC-11 | Enforcement step invokes the module with both floors | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_invokes_the_checker_with_both_floors` | `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md` |
| AC-12 | Enforcement step runs on every Python matrix leg | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg` | `FEATURE/evidence/qa-gates/d3-fallback-disposition.md` |
| AC-13 | Codecov step uses the declared `files` input key | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_codecov_step_uses_the_declared_files_input` | `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md` |
| AC-14 | `pyproject.toml` is unmodified by this change | not test-carried; committed-diff observable | `FEATURE/evidence/qa-gates/committed-diff-scope.md`, re-run at the post-merge head in `FEATURE/evidence/qa-gates/post-merge-toolchain-verification.md` |
| AC-15 | None of the four blocked policy files is modified | not test-carried; committed-diff observable | `FEATURE/evidence/qa-gates/committed-diff-scope.md`, re-run at the post-merge head in `FEATURE/evidence/qa-gates/post-merge-toolchain-verification.md` |
| AC-16 | The modified workflow passes actionlint | not test-carried; actionlint exit-code observable | `FEATURE/evidence/qa-gates/final-workflow-actionlint.md` |
| AC-17 | A green workflow run exists against the branch head | not test-carried; workflow-run observable | `FEATURE/evidence/qa-gates/green-workflow-run.md` |
| AC-18 | The full toolchain passes in a single pass | not test-carried; four-exit-code transcript observable | `FEATURE/evidence/qa-gates/toolchain-single-pass-transcript.md` |
| AC-19 | Repository coverage remains at or above both floors | not test-carried; JSON-report observable | `FEATURE/evidence/qa-gates/workflow-command-coverage-json.md` |

Row count: **19**. Rows marked `PENDING PHASE 6`: **0**.

**Finalized by [P6-T7] on 2026-08-25T23-14.** The four rows that [P5-T1] wrote as `PENDING PHASE 6`
— AC-12, AC-14, AC-15, and AC-17 — have been replaced with their landed evidence, and all nineteen
criteria are now checked in `spec.md`.

- **AC-12** landed in its **primary** form. [P6-T6] took its skip branch, so the enforcement step was
  not narrowed and `test_threshold_step_runs_on_every_matrix_leg` is the test that carries the
  criterion. The alternative-form test `test_threshold_step_is_narrowed_to_the_pinned_leg` is absent
  from `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, so the criterion's
  "exactly one of the two tests is present" condition holds. No follow-up issue was required, because
  the follow-up-issue link is an obligation of the action branch only.
- **AC-14** and **AC-15** are both carried by the committed-diff scope gate. The original [P6-T2]
  artifact records the gate at the pre-merge head `08c9c14f`; because `origin/main` was subsequently
  merged into this branch, the same gate was re-run at the post-merge head and its current result is
  recorded in `FEATURE/evidence/qa-gates/post-merge-toolchain-verification.md`. Both artifacts record
  a PASS verdict for the `pyproject.toml` exclusion, for the four blocked-policy-path exclusions, and
  for the closed write set.
- **AC-17** is carried by the green-run artifact, which records run `32925230528` with conclusion
  `success` at head SHA `e825b5e62f7b816859eee8fae2c7e23ddb40679b`, equal to the branch head at the
  moment the conclusion was read and with a clean working tree in between.

---

## Full artifact paths named by the fifteen non-pending rows, with existence verified

Existence was verified by a recursive listing of
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/` taken at the time of
writing. Every path below appeared in that listing.

| # | Artifact path | Rows that name it | On disk |
| --- | --- | --- | --- |
| 1 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-pass-after.md` | AC-1, AC-2, AC-3, AC-11, AC-13 | **yes** |
| 2 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/checker-unit-tests-pass.md` | AC-5, AC-6, AC-7, AC-8, AC-9, AC-10 | **yes** |
| 3 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md` | AC-4 | **yes** |
| 4 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md` | AC-16 | **yes** |
| 5 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/toolchain-single-pass-transcript.md` | AC-18 | **yes** |
| 6 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md` | AC-19 | **yes** |

Distinct artifact paths named by the fifteen non-pending rows: **six**. All six exist on disk.

Supporting artifacts cited by the rows above but not named as a row's primary evidence, recorded
here for traceability only: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-delta.md`
(the six-value delta record consolidating AC-19's figures) and
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md`
(the added module's own coverage pair). Both exist on disk.

---

## Acceptance for [P5-T1]

| Condition | Result |
| --- | --- |
| The index carries exactly nineteen rows, one per criterion | **PASS** — 19 rows, AC-1 through AC-19, no duplicate and no omission |
| Exactly four rows are marked `PENDING PHASE 6` | **PASS** — 4 rows |
| The four pending rows are exactly AC-12, AC-14, AC-15, and AC-17 | **PASS** |
| Every artifact path named by the other fifteen rows exists on disk | **PASS** — six distinct paths, all present |

Verdict: **PASS.**

---

## Structural-counts block — amended by [P5-T2]

Timestamp: 2026-08-25T22-41

Task: [P5-T2]
Class: **record-only task.** No `Command:` row and no `EXIT_CODE:` row, per the plan's evidence
accounting rule.

[P5-T2] marked exactly the fifteen criteria other than AC-12, AC-14, AC-15, and AC-17 in the
`## Acceptance Criteria` section of
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`, changing only
the checkbox state from `- [ ]` to `- [x]` and touching no other text in the document.

### The five recorded numbers

| # | Number | Value |
| --- | --- | --- |
| 1 | Pre-edit total line count of `spec.md` | **345** |
| 2 | Post-edit total line count of `spec.md` | **345** |
| 3 | Criterion lines in the `## Acceptance Criteria` section | **19** |
| 4 | Criterion lines checked after the edit | **15** |
| 5 | Criterion lines unchecked after the edit | **4** |

Both line counts were obtained by the same deterministic method, a newline count over the whole
file, so they are directly comparable. The file's last content line is line 345 and it is
newline-terminated.

The four criterion lines left unchecked are exactly **AC-12, AC-14, AC-15, and AC-17**, at
`spec.md` lines 298, 300, 301, and 303 respectively. The fifteen checked criterion lines are AC-1
through AC-11 (lines 287-297), AC-13 (line 299), AC-16 (line 302), AC-18 (line 304), and AC-19
(line 305).

Corroborating structural measurement, recorded because it is a second and independent way for the
edit to fail: the change to `spec.md` measures **15 lines added and 15 lines removed**, so exactly
fifteen lines were rewritten in place and no line was added, removed, or wrapped.

### Why this task deliberately asserts no committed diff

`spec.md` is untracked at `origin/main` until [P6-T1], so a `git diff` of that path against
`origin/main` produces no output whatever the executor did, and a condition phrased against it
would be satisfied by emptiness — the same class of defect this work item exists to repair. The
four structural conditions below are satisfied only by the exact end state the task is required to
produce, and each of them can fail independently.

### Acceptance for [P5-T2]

| Condition | Result |
| --- | --- |
| **(a)** The `## Acceptance Criteria` section contains exactly nineteen criterion lines | **PASS** — 19 |
| **(b)** Exactly fifteen are checked and exactly four are unchecked | **PASS** — 15 checked, 4 unchecked |
| **(c)** The four unchecked lines are exactly AC-12, AC-14, AC-15, and AC-17 | **PASS** |
| **(d)** The post-edit total line count is identical to the pre-edit total line count | **PASS** — 345 = 345 |

Verdict: **PASS.**

---

## Structural counts for [P6-T7]

Timestamp: 2026-08-25T23-14

[P6-T7] compares against **its own** pre-edit count, not against the value [P5-T2] recorded. The plan
requires this because the [P6-T6] action branch may legitimately have added lines to the Rollout and
Follow-up section in between. In this execution [P6-T6] took its **skip** branch, so no task edited
`spec.md` between [P5-T2] and [P6-T7], no superseding count was recorded, and the two references
coincide at 345. Both values are recorded here regardless, so the comparison is auditable without
relying on that coincidence.

| # | Measurement | Value |
| --- | --- | --- |
| 1 | Pre-edit total line count of `spec.md`, measured by [P6-T7] immediately before its edit | **345** |
| 2 | Post-edit total line count of `spec.md`, measured by [P6-T7] immediately after its edit | **345** |
| 3 | Reference count recorded by [P5-T2] (unchanged; no action-branch supersession) | **345** |
| 4 | Criterion lines in the `## Acceptance Criteria` section | **19** |
| 5 | Criterion lines checked | **19** |
| 6 | Criterion lines unchecked | **0** |

Counts 1 and 2 were obtained by the same deterministic method, a newline count over the whole
document. Counts 4 through 6 were obtained by fixed-string line counts over the checked and unchecked
criterion-line forms.

### Acceptance for [P6-T7]

| Condition | Result |
| --- | --- |
| **(a)** Nineteen criterion lines, of which nineteen checked and zero unchecked | **PASS** — 19 lines, 19 checked, 0 unchecked |
| **(b)** This task's own pre-edit and post-edit line counts are identical | **PASS** — 345 = 345, proving only checkbox states changed |
| **(c)** The index carries exactly nineteen rows and zero `PENDING PHASE 6` rows | **PASS** — 19 rows, 0 pending |
| **(d)** The AC-12 row names exactly one of the two test node IDs, and that test is present | **PASS** — names `test_threshold_step_runs_on_every_matrix_leg`, present once; `test_threshold_step_is_narrowed_to_the_pinned_leg` absent |
| **(e)** The AC-14 and AC-15 rows name the committed-diff scope artifact, which exists and records a PASS verdict for its conditions (b), (c), and (d) | **PASS** — artifact exists; re-run at the post-merge head also records PASS for all four conditions |
| **(f)** The AC-17 row names the green-run artifact, which exists and records a `success` conclusion | **PASS** — run `32925230528`, conclusion `success` |
| **(g)** The [P6-T6] disposition artifact exists and records a `Disposition:` value; an `ACTION` value additionally requires the follow-up-issue link | **PASS** — records `Disposition: SKIPPED`, so the follow-up-issue obligation does not apply |

Verdict: **PASS.** All nineteen acceptance criteria are checked off against evidence that exists on
disk.
