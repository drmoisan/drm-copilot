# Feature Audit — Issue #506, CI coverage targets a nonexistent package

- Timestamp: 2026-08-25T23-03
- Reviewer: feature-review agent
- Branch: `bug/ci-coverage-targets-nonexistent-package-506-r2` @ `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a`
- Baseline: `origin/main` @ `8ca66c1db827cbfb59261ca0b85bb5b7a766908e`, merge base `183ed0ada42ba437fb5cb49dac9057a6ace540b5`
- Work mode: `full-bug` (marker at `issue.md` line 13)
- AC source of record: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`, `## Acceptance Criteria`
- Criteria evaluated: 19 (AC-1 through AC-19)

## AC Source Resolution

The work-mode marker in `issue.md` reads `- Work Mode: full-bug`. Per the
`acceptance-criteria-tracking` skill, `full-bug` resolves the acceptance-criteria source to `spec.md`
only. `user-story.md` is intentionally absent, and `spec.md` line 9 records why: the defect is
internal to the CI pipeline and has no user-facing narrative. That is consistent with the mode. No
fail-closed normalization was required.

All nineteen criteria are markdown checkbox items under the exact heading `## Acceptance Criteria`
(`spec.md` lines 283-305).

## Verification Method

Each criterion was evaluated against direct evidence gathered by this reviewer, not against the
recorded evidence artifacts alone. Where a criterion names a test, the test's presence was confirmed
by reading the file and its passing status by executing it. Where a criterion states an observable,
the observable was reproduced. Recorded evidence artifacts are cited as corroboration, and where a
recorded artifact and an independent measurement both exist, both are shown.

Commands run by this reviewer:

- `git diff --name-only origin/main...HEAD` and `git status --porcelain`
- `poetry run pytest tests/scripts/dev_tools/test_check_python_coverage_thresholds.py tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py -q` → 15 passed in 0.08s
- `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` on the three changed Python files
- `gh run view 32924210756 --json ...` and `gh api .../runs/32924210756/jobs`
- Direct read of `artifacts/python/coverage.json` `totals`
- `grep -in "lexile" .github/workflows/_quality-checks.yml`
- `grep -rn "test_threshold_step_is_narrowed_to_the_pinned_leg" tests/`

## AC Evaluation Table

| AC | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| AC-1 | Workflow contains no `lexile_corpus_tuner` token, case-insensitively | **PASS** | `grep -in "lexile" .github/workflows/_quality-checks.yml` returns no match. `test_workflow_names_no_foreign_coverage_target` present at `test_quality_checks_workflow_contracts.py:83` and passing. Fail-before recorded at `evidence/regression-testing/workflow-contract-tests-fail-before.md`. |
| AC-2 | Pytest step contains `--cov-branch` and no `--cov=` token | **PASS** | Workflow line 76: `poetry run pytest --cov --cov-branch \`. No token beginning `--cov=` appears in the step; `--cov-report=xml` and `--cov-report=json:...` begin `--cov-` but not `--cov=`. `test_pytest_step_uses_bare_cov_with_branch` (line 94) tokenizes via `shlex.split` and asserts `pinned == []`; passing. |
| AC-3 | Pytest step contains `--cov-report=json:artifacts/python/coverage.json` | **PASS** | Workflow line 79 carries the token verbatim. `test_pytest_step_emits_json_coverage_report` (line 108) passing. |
| AC-4 | Live corrected-command run measures a non-empty denominator and produces the JSON report | **PASS** | `evidence/baseline/corrected-coverage-command-repro.md` records a `TOTAL` row at output line 613 with statement count **14953** (> 0), and `EXIT_CODE: 0`. `poetry env info --path` recorded at `evidence/baseline/python-environment-provenance.md:33`, satisfying the which-checkout-was-measured requirement. Independently confirmed by this reviewer: `artifacts/python/coverage.json` exists with `totals.num_statements = 15014 > 0`. |
| AC-5 | A deliberate coverage regression fails the build | **PASS** | `test_line_coverage_below_floor_exits_non_zero` present at `test_check_python_coverage_thresholds.py:74`, supplies `percent_statements_covered: 84.9`, asserts `exit_code != 0` and `"line coverage" in captured.err`. Executed and passing. |
| AC-6 | Branch floor enforced independently of the line floor | **PASS** | `test_branch_coverage_below_floor_exits_non_zero` (line 94) supplies `percent_branches_covered: 74.9` with `percent_statements_covered: 90.0` — above its floor — and asserts non-zero exit plus `"branch coverage"` in stderr. Independence is genuinely tested: the line metric passes in that test, so only the branch comparison can produce the failure. Passing. |
| AC-7 | Both floors inclusive at the boundary | **PASS** | `test_line_coverage_at_floor_is_accepted` (line 44, exactly 85.0) and `test_branch_coverage_at_floor_is_accepted` (line 59, exactly 75.0), each asserting `exit_code == 0`. Both passing. Implementation: `check_python_coverage_thresholds.py:123` uses `percentage < floor`, so equality passes. |
| AC-8 | A run breaching both floors reports both metrics | **PASS** | `test_both_metrics_below_floor_are_both_reported` (line 114) supplies 60.0 / 50.0 and asserts both `"line coverage"` and `"branch coverage"` appear in the same `captured.err`. Passing. |
| AC-9 | Absent branch data fails loudly rather than silently disabling the gate | **PASS** | `test_absent_branch_data_exits_non_zero` (line 135) supplies a `totals` carrying `percent_statements_covered: 90.0` and no `percent_branches_covered` key, asserts non-zero exit and the literal `"branch data was not collected"` in stderr. Passing. Implementation at `check_python_coverage_thresholds.py:178-182`. |
| AC-10 | A missing or unparseable report fails loudly | **PASS** | `test_missing_report_file_exits_non_zero` (line 155) and `test_unparseable_report_exits_non_zero` (line 172), each asserting non-zero exit and the report path present in stderr. Both passing. Both exercise real file-backed paths via the in-memory `mem_fs_path` fixture, creating no temporary file. |
| AC-11 | Enforcement step present and invokes the module with both floors | **PASS** | Workflow lines 82-87 carry the step with `--min-line 85 --min-branch 75`. `test_threshold_step_invokes_the_checker_with_both_floors` (line 119) asserts adjacency — `tokens[tokens.index("--min-line") + 1] == "85"` and the same for `--min-branch`/`75` — not mere presence. Passing. |
| AC-12 | Enforcement step runs on every Python matrix leg | **PASS** | Two independent confirmations. (a) Static: the step mapping at workflow lines 82-87 carries no `if` key; `test_threshold_step_runs_on_every_matrix_leg` present at `test_quality_checks_workflow_contracts.py:134` and passing. (b) The alternative form is absent: `grep -rn "test_threshold_step_is_narrowed_to_the_pinned_leg" tests/` returns no match, so exactly one of the two tests is present as the criterion requires. (c) Runtime: `gh api .../runs/32924210756/jobs` shows `Enforce Python coverage thresholds => success` on 3.10, 3.11, 3.12, and 3.13 individually. D3 disposition SKIPPED is recorded at `evidence/qa-gates/d3-fallback-disposition.md`; no follow-up issue is required on the skip path. |
| AC-13 | Codecov step uses the declared `files` input | **PASS** | Workflow line 94: `files: ./coverage.xml`. No `file` key present. `test_codecov_step_uses_the_declared_files_input` (line 146) asserts both `"files" in with_mapping` and `"file" not in with_mapping`. Passing. |
| AC-14 | `pyproject.toml` unmodified | **PASS** | Independently verified: `pyproject.toml` does not appear in `git diff --name-only origin/main...HEAD` (43 paths, enumerated in the policy audit), and does not appear in `git status --porcelain` (5 paths, all inside the feature folder). Unmodified in both the committed diff and the working tree. Corroborated by `evidence/qa-gates/worktree-scope-pyproject.md`. |
| AC-15 | None of the four blocked policy files modified | **PASS** | Independently verified by exact-path match against `git diff --name-only origin/main...HEAD`: `.github/instructions/python-unit-test.instructions.md` absent; `.github/instructions/python-suppressions.instructions.md` absent; `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` absent; `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` absent. `git status --porcelain` lists none of them. Corroborated by `evidence/qa-gates/worktree-scope-blocked-policy-files.md`. |
| AC-16 | Modified workflow passes actionlint | **PASS** | `evidence/qa-gates/final-workflow-actionlint.md` records `Command: pwsh -File scripts/dev-tools/run-actionlint.ps1`, `EXIT_CODE: 0`, finding count 0, taken after all Phase 1-3 edits so it lints the final committed workflow state. Matches the pre-change baseline at `evidence/baseline/workflow-actionlint.md`, so the edits introduced no new finding. |
| AC-17 | Green workflow run exists against the branch head | **PASS** | Verified live by this reviewer: `gh run view 32924210756` returns `conclusion: success`, `status: completed`, `workflowName: "Quality Checks (reusable)"`, `headSha: 15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a`, which equals `git rev-parse HEAD`. All four matrix jobs concluded `success`. Run URL recorded at `evidence/qa-gates/green-workflow-run.md`. **Caveat:** see NB-1 below — the pending documentation commit will move the head and require this binding to be re-established. |
| AC-18 | Full toolchain passes in a single pass | **PASS** | `evidence/qa-gates/` records `EXIT_CODE: 0` for each of `final-python-format-black.md`, `final-python-lint-ruff.md`, `final-python-typecheck-pyright.md`, and `final-python-test-coverage.md`, with the uninterrupted sequence recorded at `toolchain-single-pass-transcript.md` (verdict PASS; 4136 passed, 5 skipped; no file modified by the formatter). Independently spot-checked by this reviewer on the three changed Python files: black exit 0 with 3 files unchanged, ruff exit 0, pyright 0 errors / 0 warnings. |
| AC-19 | Repository coverage remains at or above both policy floors | **PASS** | Read directly from `artifacts/python/coverage.json` by this reviewer: `totals.percent_statements_covered = 92.64686292793392` (>= 85, margin +7.65) and `totals.percent_branches_covered = 85.2161278605158` (>= 75, margin +10.22). Byte-identical to the figures recorded at `evidence/qa-gates/coverage-delta.md` and `evidence/qa-gates/coverage-threshold-enforcement.md`, the latter recording the enforcement module run end-to-end against the real report with `EXIT_CODE: 0` and empty output on both streams. |

## AC Verdict Counts

| Verdict | Count |
| --- | --- |
| PASS | 19 |
| PARTIAL | 0 |
| FAIL | 0 |
| UNVERIFIED | 0 |
| **Total** | **19** |

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
```

All nineteen checkboxes were already marked `- [x]` in the working-tree `spec.md` when this review
began, having been checked off by the executing agents at `[P5-T*]` and `[P6-T7]`. This reviewer
independently evaluated each criterion as PASS and therefore made no change to `spec.md`. No
criterion required a newly-applied check-off, and no criterion required a check-off to be reverted.

## Baseline Comparison

The audit is relative to `origin/main` @ `8ca66c1d`. The defect being fixed is a property of the
baseline, and both sides of it were measured.

| Property | Baseline (`origin/main`) | Branch head (`15db75d5`) |
| --- | --- | --- |
| Coverage target named in the workflow | `src/lexile_corpus_tuner` — does not exist in this repository | none; the configured `[tool.coverage.run] source` applies |
| Statements measured | 0 (no `TOTAL` row printed) | 15,014 |
| Line coverage reported | none collected | 92.64686292793392 |
| Branch coverage reported | none collected (no `--cov-branch`) | 85.2161278605158 |
| Threshold enforcement in CI | none | new step, all four matrix legs, floors 85 / 75 |
| `coverage.xml` uploaded to Codecov | empty | populated |
| Codecov input key | `file` (undeclared for `codecov/codecov-action@v7`) | `files` (declared) |
| Could the coverage gate fail on a regression? | no | yes |

The defect reproduction is recorded at `evidence/baseline/defective-coverage-command-repro.md` and
the restoration of the defective state for that measurement at
`evidence/baseline/defective-coverage-command-restore.md`. The corrected-command measurement is at
`evidence/baseline/corrected-coverage-command-repro.md`.

Coverage delta across the change:

| Metric | Baseline (corrected command, pre-change tree) | Post-change | Delta |
| --- | --- | --- | --- |
| Line | 92.6302414231258 | 92.64686292793392 | +0.0166 |
| Branch | 85.21485797523671 | 85.2161278605158 | +0.0013 |

Both rose. Adding the new module and its tests did not dilute either metric, because the module's own
coverage (96.72% line, 85.71% branch) exceeds the repository figure on the line metric and is close to
it on the branch metric.

## Scope Fidelity

The delivered change matches the scope declared in `spec.md` `## Scope & Non-Goals` exactly. Every
file in the in-scope list is present in the diff, and no file outside it was touched.

| Declared in scope | Delivered |
| --- | --- |
| `.github/workflows/_quality-checks.yml` | yes — 14-line diff, three coordinated edits |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | yes — new, 324 lines |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | yes — new, 188 lines, 9 tests |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | yes — new, 157 lines, 6 tests |
| Spec, plan, and the feature-folder evidence tree | yes — 39 documentation files |

Declared non-goals, each verified absent from the diff:

| Declared non-goal | Held |
| --- | --- |
| `pyproject.toml` unmodified | yes — AC-14 |
| The four blocked policy files unmodified | yes — AC-15 |
| Nine residual foreign-token occurrences deferred (D4) | yes — no file under `scripts/dev_tools/atomic_executor/`, no `.vscode/tasks.json`, no `tests/.../test_qc_runner.py` in the diff |
| No `codecov.yml` project status added | yes — no such file in the diff |
| `fail_ci_if_error` stays `false` (D7) | yes — unchanged at workflow line 97 |
| Inert `"src"` source entry not removed | yes — `pyproject.toml` untouched |
| No other language's coverage gate added | yes — no other workflow modified |
| Historical records under `archive/`, `completed/`, `potential/promoted/` not rewritten | yes — no such path in the diff |

No scope creep was found. The change is 14 lines of workflow plus one module and two test files, for a
defect with repository-wide consequences — an appropriately narrow blast radius, and consistent with
`.github/instructions/general-code-change.instructions.md` ("Change only what is needed... If you
uncover deeper design problems, open a new issue instead of widening scope"). The nine known residual
occurrences of the foreign token are deferred with a written rationale and a recommended follow-up
rather than folded in, which is the correct disposition.

## Decision Record Compliance

`spec.md` closes eight decisions (D1-D8). Each was checked against the delivered change.

| Decision | Delivered as decided |
| --- | --- |
| D1 — bare `--cov` with `--cov-branch`, JSON report, `pyproject.toml` untouched | yes |
| D2 — separate step invoking a unit-testable module, not `--cov-fail-under` | yes |
| D3 — enforcement step on all four Python legs | yes; fallback correctly not exercised, disposition SKIPPED recorded |
| D4 — residual occurrences deferred | yes |
| D5 — blocked policy files escalated, not edited | yes; recorded at `evidence/other/human-interaction-d5.md` |
| D6 — both test files under `tests/scripts/dev_tools/` | yes |
| D7 — `fail_ci_if_error` stays `false` | yes |
| D8 — Codecov `file` becomes `files` | yes |

The D3 fallback deserves specific note because it was the one decision with a conditional branch. The
skip branch was taken, and it was taken on evidence rather than by default: all four matrix legs passed
the enforcement step in run `32924210756`, which this reviewer confirmed directly at the step level via
the GitHub jobs API. The action-branch preconditions — a run failing solely because of a coverage
shortfall on a leg other than 3.13 — did not occur. Consequently
`test_threshold_step_is_narrowed_to_the_pinned_leg` was correctly not authored, and no follow-up issue
is required, since the alternative AC-12 form applies only on the action path.

## Outstanding Items

No acceptance criterion is unmet. Two non-AC items carry forward from the policy audit and the code
review.

**NB-1 (Non-blocking, merge precondition).** AC-17 passes at the audited head `15db75d5`. The
orchestrator will commit the five uncommitted feature-folder paths together with the three audit
artifacts this review produces, which moves the branch head. `modified-workflow-needs-green-run`
matches head SHA exactly, so the existing green run will then bind to an ancestor. The delta is
Markdown only and cannot change CI behavior — the same argument `evidence/qa-gates/green-workflow-run.md`
makes for why runs `32923970683` and `32924210756` exercise an identical build — but the rule does not
admit that argument. Before merge, confirm a `success` run against the final head, most naturally the
pull request's own CI run, and record its URL.

**NB-2 (Non-blocking, not AC-bearing).** `scripts/dev_tools/check_python_coverage_thresholds.py`
lines 230 and 236 — the raise bodies for "root is not a JSON object" and "carries no `totals` mapping"
— have no test. They are the module's only uncovered statements and only uncovered branch arcs. No
acceptance criterion requires them: AC-10 covers the missing and unparseable cases and both are tested.
The second condition is nonetheless named in `spec.md` line 197 among validations that "must fail
loudly rather than pass silently", and it is the shape a truncated report takes. Two tests in the
existing file's pattern would close the gap and take the module to 100% on both metrics.

## Verdict

**All nineteen acceptance criteria PASS.** The fix addresses the reported defect at its root, the
change is confined to its declared scope, every declared non-goal holds, all eight recorded decisions
were implemented as decided, and repository coverage rose on both policy metrics under the corrected
measurement scope.

The feature is complete relative to its baseline. Merge readiness depends on the NB-1 green-run
rebinding after the final commit; nothing in the tree requires rework.
