# Feature Audit — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T22-57
- **Issue:** #506
- **Work Mode:** `full-bug` — marker at `issue.md` line 13. Per the acceptance-criteria-tracking
  skill, `spec.md` is the **sole** acceptance-criteria source; `user-story.md` is intentionally
  absent and its absence is not a gap.
- **AC source:** `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`,
  `## Acceptance Criteria` section (lines 283-305), 19 criteria, AC-1 through AC-19.
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3` @ `890e2ac9`
- **Baseline:** `origin/main`

## Non-AC checkboxes, excluded

The four Impact/Severity radios (`spec.md` lines 21-24) and the one logs-attached checkbox (line 59)
sit outside the `## Acceptance Criteria` section and are not acceptance criteria. The Test Strategy
section deliberately records the five issue-seeded items as prose dispositions rather than
checkboxes (`spec.md` line 253), so the AC section is the sole checkbox-tracked list. This audit
evaluates exactly nineteen criteria.

## Check-off action taken by this review

**None.** No checkbox in `spec.md` was modified by this audit.

Per the caller instruction and per plan task P6-T7, AC-12, AC-14, AC-15, and AC-17 are the
orchestrator's to finalize after the green run. This review reports their evidence status and does
not check them off. The fifteen already-checked criteria were verified rather than re-checked; no
newly-passing criterion was found among the unchecked four that this reviewer is authorized to
check, because AC-17 does not pass and AC-12/AC-14/AC-15 are reserved to P6-T7 by the plan.

---

## Verification Method

Verdicts are backed by one of three evidence classes, never by prose inspection:

1. **Test node ID** — the test was collected and executed in this review worktree at the current
   branch head. All fifteen node IDs below were confirmed present by
   `pytest --collect-only` and all fifteen passed (`15 passed in 0.08s`).
2. **Command observable** — the command was re-run in this review worktree, or its recorded
   `EXIT_CODE:` was read from an evidence artifact that exists on disk.
3. **Artifact figure** — a numeric value read from a coverage artifact present on disk.

---

## Acceptance Criteria Evaluation

| AC | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| **AC-1** | Workflow contains no `lexile_corpus_tuner` token, case-insensitively | **PASS** | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_workflow_names_no_foreign_coverage_target` — collected and passed at head. Fail-before/pass-after pair recorded at `evidence/regression-testing/workflow-contract-tests-fail-before.md` and `.../workflow-contract-tests-pass-after.md`. Independently confirmed: `grep -i lexile .github/workflows/_quality-checks.yml` returns no match. |
| **AC-2** | Pytest `run` block contains `--cov-branch` and no `--cov=`-prefixed token | **PASS** | `...::test_pytest_step_uses_bare_cov_with_branch` — collected and passed. The test tokenizes the step's `run` value obtained via `yaml.safe_load` + `shlex.split`, exactly as the criterion specifies. Workflow lines 74-79 confirm: `poetry run pytest --cov --cov-branch \ --cov-report=xml \ --cov-report=json:... \ --cov-report=term-missing`. |
| **AC-3** | Pytest `run` block contains `--cov-report=json:artifacts/python/coverage.json` | **PASS** | `...::test_pytest_step_emits_json_coverage_report` — collected and passed. Token present verbatim at workflow line 77. |
| **AC-4** | Live corrected run measures a non-empty denominator and produces the JSON report; `poetry env info --path` recorded | **PASS** | `evidence/baseline/corrected-coverage-command-repro.md`: `EXIT_CODE: 0`; `TOTAL` row `14953 1102 5492 558 91%`; `totals.num_statements` = **14953** > 0. Environment provenance recorded at `evidence/baseline/python-environment-provenance.md` command 3 of 6 (`poetry env info --path` → `C:\Users\DanMoisan\repos\drm-copilot\.venv`, `EXIT_CODE: 0`) with an explicit containment probe at command 4 because the interpreter belongs to a different checkout. Independently confirmed at head: `artifacts/python/coverage.json` exists (1,599,291 bytes) with `totals.num_statements` = 15014 > 0. |
| **AC-5** | A deliberate coverage regression fails the build | **PASS** | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py::test_line_coverage_below_floor_exits_non_zero` — collected and passed. Supplies `percent_statements_covered` 84.9, asserts `exit_code != 0` and `"line coverage" in captured.err`. Recorded at `evidence/regression-testing/checker-unit-tests-pass.md`. |
| **AC-6** | Branch floor enforced independently of the line floor | **PASS** | `...::test_branch_coverage_below_floor_exits_non_zero` — collected and passed. Supplies branch 74.9 with statements 90.0 (above its floor), asserts non-zero exit and `"branch coverage"` in stderr, so the branch failure is proven independent of the line metric. |
| **AC-7** | Both floors inclusive at the boundary | **PASS** | Two tests, both collected and passed: `...::test_line_coverage_at_floor_is_accepted` (85.0 → exit 0) and `...::test_branch_coverage_at_floor_is_accepted` (75.0 → exit 0). Implementation confirms: `check_python_coverage_thresholds.py` line 123 uses `if percentage < floor`, so equality passes. |
| **AC-8** | A double breach reports both metrics, not only the first | **PASS** | `...::test_both_metrics_below_floor_are_both_reported` — collected and passed. Supplies 60.0 / 50.0 and asserts both `"line coverage"` and `"branch coverage"` appear in the same `captured.err`. |
| **AC-9** | Absent branch data fails loudly rather than silently disabling the gate | **PASS** | `...::test_absent_branch_data_exits_non_zero` — collected and passed. Supplies a `totals` mapping with `percent_statements_covered` 90.0 and **no** `percent_branches_covered` key; asserts non-zero exit and the literal `"branch data was not collected"` in stderr. That literal is emitted at `check_python_coverage_thresholds.py` line 179. |
| **AC-10** | A missing or unparseable report fails loudly, message names the report path | **PASS** | Two tests, both collected and passed: `...::test_missing_report_file_exits_non_zero` and `...::test_unparseable_report_exits_non_zero`. Each asserts `report_argument in captured.err`, so the message is proven to name the path rather than degrade to a bare trace. |
| **AC-11** | Enforcement step present and invokes the module with both floors | **PASS** | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_invokes_the_checker_with_both_floors` — collected and passed. Locates the step whose `run` contains `check_python_coverage_thresholds` and asserts `--min-line` is immediately followed by `85` and `--min-branch` by `75`. Workflow lines 81-86 confirm. |
| **AC-12** | Enforcement step runs on every Python matrix leg | **PASS (evidence exists; checkbox correctly left unchecked pending P6-T7)** | `...::test_threshold_step_runs_on_every_matrix_leg` — **collected and passed at head**. It asserts `"if" not in step` for the enforcement step. Direct inspection of workflow lines 81-86 confirms the step carries no `if` key, unlike the Codecov step at line 88 which does. The criterion's "exactly one of the two tests is present" condition holds: `test_threshold_step_is_narrowed_to_the_pinned_leg` is absent from the file (confirmed by the 15-node collection listing). See note below. |
| **AC-13** | Codecov step uses the declared `files` input key | **PASS** | `...::test_codecov_step_uses_the_declared_files_input` — collected and passed. Parses via `yaml.safe_load`, locates the step whose `uses` names `codecov/codecov-action`, asserts `files` present and `file` absent in its `with` mapping. Workflow line 91 confirms `files: ./coverage.xml`. |
| **AC-14** | `pyproject.toml` is unmodified by this change | **PASS (evidence exists; checkbox correctly left unchecked pending P6-T7)** | Stated observable re-run at head in this review: `git diff --name-only origin/main...HEAD -- pyproject.toml` → **empty**. Full 43-path diff listing contains no `pyproject.toml`. Executor evidence at `evidence/qa-gates/committed-diff-scope.md` (committed-diff gate, P6-T2) and `evidence/qa-gates/worktree-scope-pyproject.md` (working-tree half, P4-T9). |
| **AC-15** | None of the four blocked policy files is modified | **PASS (evidence exists; checkbox correctly left unchecked pending P6-T7)** | Stated observable re-run at head in this review: `git diff --name-only origin/main...HEAD -- .github/instructions/ extensions/drm-copilot/resources/customizations/.github/instructions/` → **empty**. None of `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, or their two bundled mirrors appears in the diff. Executor evidence at `evidence/qa-gates/committed-diff-scope.md` and `evidence/qa-gates/worktree-scope-blocked-policy-files.md`. The D5 human-interaction requirement is recorded, not silently resolved, at `evidence/other/human-interaction-d5.md`. |
| **AC-16** | The modified workflow passes actionlint | **PASS** | `evidence/qa-gates/final-workflow-actionlint.md`: `Command: pwsh -File scripts/dev-tools/run-actionlint.ps1`, `EXIT_CODE: 0`, 0 findings, taken after all Phase 1-3 edits so the final committed state is the state linted. Matching pre-change baseline at `evidence/baseline/workflow-actionlint.md`; intermediate post-edit run at `evidence/qa-gates/workflow-actionlint-post-edit.md`. |
| **AC-17** | A green workflow run exists against the branch head | **FAIL** | No run exists whose head SHA equals `890e2ac9369e5a67f282bb7bc3ca438589427676`. `gh run list --workflow=_quality-checks.yml --branch bug/ci-coverage-targets-nonexistent-package-506-r3` returns **zero runs**. The designated artifact `evidence/qa-gates/green-workflow-run.md` **does not exist**. Plan task P6-T5 is unchecked. See the dedicated section below. |
| **AC-18** | The full toolchain passes in a single pass | **PASS** | `evidence/qa-gates/toolchain-single-pass-transcript.md`: four consecutive exit codes **0, 0, 0, 0** for `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`, in that order, uninterrupted, with the formatter modifying zero files (`448 files left unchanged`). One restart preceded the pass; its cause (a gitignored `.claude/state/` runtime file breaking a pre-existing, unrelated parity test) is recorded at `evidence/other/batch-budget-clear-before-toolchain-restart.md`. The four stage artifacts each exist with `EXIT_CODE: 0`. Independently re-run at head on the three changed Python files: black unchanged, ruff clean, pyright 0/0/0, 15 tests passed. |
| **AC-19** | Repository coverage remains at or above both policy floors under the corrected scope | **PASS** | `evidence/qa-gates/workflow-command-coverage-json.md` command 2 of 4: `15014 92.64686292793392 85.2161278605158`, `EXIT_CODE: 0`. Independently re-read at head from `artifacts/python/coverage.json`: `totals.percent_statements_covered` = **92.64686292793392** >= 85, `totals.percent_branches_covered` = **85.2161278605158** >= 75, `totals.num_statements` = 15014, `meta.branch_coverage` = `true`. Delta record at `evidence/qa-gates/coverage-delta.md` shows both metrics increased against baseline. |

**Tally: 18 PASS, 1 FAIL, 0 PARTIAL, 0 UNVERIFIED.**

---

## The Four Deferred Criteria — Evidence Status

The caller asked for an explicit statement on whether the evidence for AC-12, AC-14, AC-15, and
AC-17 exists yet. It does for three of the four.

| AC | Does its evidence exist now? | Detail |
| --- | --- | --- |
| **AC-12** | **Yes** | The criterion's primary form landed. `test_threshold_step_runs_on_every_matrix_leg` is present in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (lines 134-143), was collected, and passed. The alternative-form test `test_threshold_step_is_narrowed_to_the_pinned_leg` is absent, satisfying the criterion's "exactly one of the two tests is present in the landed change" condition. What is **not** yet settled is not the evidence but the D3 branch selection: P6-T6 cannot confirm the skip branch until P6-T5 reports a `success` conclusion. Should the green run reveal a version-specific shortfall on a leg other than 3.13, the pre-authorized narrowing would replace this test and require a linked follow-up issue. Deferral of the check-off is therefore correct, and no additional evidence needs to be produced on the expected path. |
| **AC-14** | **Yes** | The stated observable — `git diff --name-only origin/main...HEAD` not listing `pyproject.toml` — is satisfied and was re-verified in this review at the current head. The falsifiable committed-diff gate is recorded at `evidence/qa-gates/committed-diff-scope.md` (P6-T2), which exists on disk. Nothing further is required. |
| **AC-15** | **Yes** | The stated observable — the same diff listing none of the four blocked policy paths — is satisfied and was re-verified in this review at the current head. Recorded at the same artifact. Nothing further is required. |
| **AC-17** | **No** | The designated artifact `evidence/qa-gates/green-workflow-run.md` **does not exist**, and no qualifying run exists to record in it. This is the only one of the four whose evidence has not been produced. |

---

## AC-17 in Detail

The criterion requires: a `_quality-checks.yml` run whose conclusion is `success` **and** whose head
SHA equals `git rev-parse HEAD` on the branch, with the run URL recorded in
`evidence/qa-gates/` **before feature review**.

Observed state at this review:

| Fact | Value |
| --- | --- |
| `git rev-parse HEAD` | `890e2ac9369e5a67f282bb7bc3ca438589427676` |
| `origin/bug/ci-coverage-targets-nonexistent-package-506-r3` | `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a` |
| Runs on branch `...-506-r3` | **none** |
| `evidence/qa-gates/green-workflow-run.md` | **absent** |
| Plan P6-T5 checkbox | `- [ ]` |

Two green `workflow_dispatch` runs of `_quality-checks.yml` exist on the sibling ref `...-506-r2`:

| Run | Head SHA | Conclusion |
| --- | --- | --- |
| 32923970683 | `08c9c14f` | success |
| 32924210756 | `15db75d5` | success |

Neither head SHA equals `890e2ac9`, so neither satisfies the criterion as written.

**Mitigating facts, recorded but not accepted as satisfaction.** `890e2ac9` is a merge of
`origin/main` whose second parent is `15db75d5` — the exact SHA of the green run 32924210756. The
four production and test files are byte-identical between those two commits
(`git diff --name-only 15db75d5 HEAD -- <the four paths>` returns empty), and `main` contributed
nothing under `.github/` (`git diff --name-only 15db75d5...origin/main -- .github/` returns empty).
The green run therefore exercised identical workflow content. The gap is one merge commit wide and
is expected to clear on a single re-dispatch.

**Corrective action (plan tasks P6-T3 through P6-T5, re-run against the current head):**

1. `git push --set-upstream origin HEAD` — the remote ref currently stands at `15db75d5`.
2. `gh workflow run _quality-checks.yml --ref bug/ci-coverage-targets-nonexistent-package-506-r3`.
3. Poll to a terminal conclusion; write `evidence/qa-gates/green-workflow-run.md` with the run URL
   and a head SHA equal to `git rev-parse HEAD`.
4. Make no commit between steps 1 and 3; a later commit invalidates the head-SHA binding.

**Note on plan bookkeeping.** P6-T3 (push) and P6-T4 (dispatch) are marked `- [x]` in the plan, but
the remote ref is behind the local head and no run exists on the `-r3` ref. Those check-offs record
the pre-merge state on the `-r2` ref. Both tasks require re-execution. This is a plan-state
observation, not an independent defect in the change under review.

---

## Regression Baseline Verification

The branch does not regress anything relative to `origin/main`:

| Dimension | Baseline | At head | Direction |
| --- | --- | --- | --- |
| Python line coverage | 92.6302414231258 % | 92.64686292793392 % | +0.0166 |
| Python branch coverage | 85.21485797523671 % | 85.2161278605158 % | +0.0013 |
| Statement denominator | 14953 | 15014 | +61, exactly the added module's statement count |
| Test count | 4121 passed, 5 skipped | 4136 passed, 5 skipped | +15, exactly the six workflow-contract tests plus the nine checker tests |
| Failing tests | 0 | 0 | unchanged |
| actionlint findings | 0 | 0 | unchanged |
| Skipped tests | 5 (pre-existing, `test_parallel_manifest_bash_parity.py`) | 5 | unchanged |

No existing test was modified. `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` is not in
the diff, so its assertion on the current `QCRunner.FULL_TEST` argv remains valid, consistent with
the deliberate D4 deferral.

The primary behavioural regression the feature exists to fix is closed: the defective command
recorded at `evidence/baseline/defective-coverage-command-repro.md` produced no `TOTAL` row and no
coverage table at all; the corrected command records `TOTAL 15014 1104 5506 560 91%`. The defect was
reproduced, corrected, and the defective state was restored and re-verified
(`evidence/baseline/defective-coverage-command-restore.md`) so the reproduction is falsifiable
rather than assumed.

---

## Scope Fidelity Against the Spec

| Spec commitment | Observed | Verdict |
| --- | --- | --- |
| In scope: 4 code/test paths + spec + plan + evidence | Diff contains exactly those, plus `issue.md` and the research document, both untracked at `origin/main` and committed unmodified (write-set entries 8 and 9) | **MATCH** |
| Out of scope: `pyproject.toml` | Absent from the diff | **MATCH** |
| Out of scope: nine residual foreign-name occurrences (D4) | None of the named paths appears in the diff | **MATCH** |
| Out of scope: `codecov.yml` project status | No such file in the diff | **MATCH** |
| Out of scope: `fail_ci_if_error` (D7) | Unchanged at `false` (workflow line 94) | **MATCH** |
| Out of scope: removing the inert `"src"` source entry | `pyproject.toml` untouched | **MATCH** |
| Excluded: 4 blocked policy files (D5) | Absent from the diff; escalation recorded at `evidence/other/human-interaction-d5.md` | **MATCH** |
| Excluded: ~170 historical matches under archive/completed/promoted | No path under `docs/features/archive/`, `docs/features/completed/`, or `docs/features/potential/promoted/` in the diff | **MATCH** |
| Invariant: test selection unchanged | Only the measurement scope and the added gate changed; suite grew only by the 15 new tests | **MATCH** |
| Invariant: `--cov-report=xml` still writes `./coverage.xml` | Retained at workflow line 76, matching the upload step's `./coverage.xml` | **MATCH** |
| Invariant: Coverage Exclusion Policy not weakened | No `omit`/`exclude` change anywhere in the diff | **MATCH** |
| Invariant: `ci-workflows.md` not triggered | Confirmed independently — no `shell: pwsh`, no `defaults.run.shell`, `ubuntu-latest`, no deliberately-failing nested command | **MATCH** |

No scope drift. The delivered change is exactly the change the spec committed to.

---

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
- Total AC items: 19
- Checked off (delivered): 15
- Remaining (unchecked): 4
- Items remaining:
  - AC-12. The enforcement step runs on every Python matrix leg.
           (Evidence EXISTS and PASSES; check-off reserved to plan task P6-T7 pending the D3 branch
            selection, which depends on the P6-T5 green-run conclusion.)
  - AC-14. `pyproject.toml` is unmodified by this change.
           (Evidence EXISTS and PASSES; re-verified at head. Check-off reserved to P6-T7.)
  - AC-15. None of the four blocked policy files is modified.
           (Evidence EXISTS and PASSES; re-verified at head. Check-off reserved to P6-T7.)
  - AC-17. A green workflow run exists against the branch head.
           (Evidence DOES NOT EXIST. FAIL. Requires the P6-T3/T4/T5 re-run described above.)
```

This reviewer checked off **nothing**. Fifteen criteria were already checked by plan task P5-T2 and
are confirmed correct; the remaining four are the orchestrator's to finalize at P6-T7, and this
audit does not pre-empt that task.

---

## Verdict

**PARTIAL.**

18 of 19 acceptance criteria pass on evidence verified at the current branch head. The single
failure, AC-17, is a sequencing obligation rather than a defect in the delivered change: no code,
test, or workflow modification is required to satisfy it, only a push and a workflow dispatch
against `890e2ac9` followed by recording the run. The feature itself — a CI coverage gate that
measures a real denominator and can fail on a regression — is delivered, tested, and demonstrated
to discriminate.
