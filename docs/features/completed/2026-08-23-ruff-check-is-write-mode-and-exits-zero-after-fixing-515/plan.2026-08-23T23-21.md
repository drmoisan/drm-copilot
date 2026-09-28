# 2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing (Plan)

- **Issue:** #515
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-21
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md`, section `## Acceptance Criteria` (10 criteria)
- **Bug report:** `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/issue.md`
- **Research:** `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/research/2026-08-23T21-05-ruff-write-mode-research.md`

**Fail-closed evidence rule:** Every evidence-producing task below names its artifact path. If any required baseline artifact, regression artifact, QA-gate artifact, or coverage-comparison artifact is missing or is missing a required field, the outcome is BLOCKED or INCOMPLETE, never PASS.

**Evidence location:** All evidence resolves under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/` in the canonical kind subfolders `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`. No `artifacts/`-rooted evidence path is valid for this plan.

**Evidence artifact naming:** Each artifact filename below carries a concrete ISO-8601 `yyyy-MM-ddTHH-mm` component. The executor substitutes the actual capture time in that same format when it differs from the planned value, and records the actual time in the artifact's `Timestamp:` field. No other part of a stated filename may change.

**Required artifact fields:** Every command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose gate is expected to produce a non-zero exit code additionally records `ExpectedExitCode:` with that integer.

## Scope Lock

The diff writes exactly two repository files outside this feature folder:

```
pyproject.toml
tests/scripts/dev_tools/test_ruff_config_alignment.py
```

No task in this plan may write any file under `.claude/rules/` or `.github/instructions/`. No task may write `scripts/dev_tools/atomic_executor/qc_runner_loop.py` or `scripts/dev_tools/fix_all_branches_extra.py`. No task may create a file under `docs/features/potential/`. No stdin-based differential integration test is authored; the differential survives only as the manual QA-gate evidence recorded in Phase 3.

## Acceptance-Condition Authoring Notes

Two literals this plan asserts do not yet exist in the tracked tree and are quoted here verbatim so the acceptance-gate rules can attribute them to the tasks that create them: the new test module path `tests/scripts/dev_tools/test_ruff_config_alignment.py`, and the four test function names `test_ruff_config_does_not_enable_fix_mode`, `test_ruff_config_retains_show_fixes`, `test_no_standalone_ruff_config_at_repository_root`, and `test_quality_checks_workflow_still_runs_a_ruff_lint_step`.

Coverage arguments in this plan use the importable dotted `--cov=` form only. `pyproject.toml` is configuration and is not in the measured coverage source set declared at `pyproject.toml:120`, so no coverage argument names a filesystem path.

No acceptance condition in this plan is stated as "the lint stage exits 0" alone. Where the lint stage is asserted, the condition is a before/after working-tree status snapshot pair, per the spec's explicit rejection of the exit-code-only formulation.

### Phase 0 — Policy Reads and Baseline Capture

Contingency for the Phase 0 baselines. Each of P0-T3, P0-T4, P0-T5, and P0-T6 has a Phase 4 counterpart that requires a clean result: P4-T1 requires black to exit 0, P4-T2 requires the linter to exit 0, P4-T3 requires pyright to report zero errors, P4-T4 requires zero failed and zero errored tests, and P4-T5 requires total line coverage at or above 85 percent and total branch coverage at or above 75 percent. Deleting one configuration line cannot move any of those results. If any of P0-T3, P0-T4, P0-T5, or P0-T6 records a non-zero exit code, a non-zero error count, a non-zero failure count, or a coverage figure below either threshold, then the tree carries a pre-existing defect that Phase 4 cannot clear within this plan's scope; for P0-T4 specifically a non-zero exit means a pre-existing fixable violation that the write-mode default has been hiding. In every such case: record the full finding detail in that task's artifact, complete the remaining Phase 0 tasks so the baseline is complete, do not begin P1-T1, and report the condition to the orchestrator as a scope conflict. Do not run any write-mode formatting or fixing command — specifically, do not run the bare `poetry run black .` form and do not pass the linter's explicit fix flag — and do not edit any repository file to clear the findings; every such remediation writes outside the two-file scope lock above.

- [x] [P0-T1] Read the policy files in the order defined by `.claude/skills/policy-compliance-order/SKILL.md` — `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/python.md`, then `.claude/rules/python-suppressions.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/plan-acceptance-gates.md` — and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-instructions-read.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, a `Policy Order:` line, and an explicit list naming all seven files read in that order.
- [x] [P0-T2] Run `git rev-parse HEAD` and `git status --porcelain` from the worktree root and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-git-baseline.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the baseline commit SHA and the verbatim working-tree status text (which later tasks compare against).
- [x] [P0-T3] Run `poetry run black --check .` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-format.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` stating the number of files that would be reformatted.
- [x] [P0-T4] Run `poetry run ruff check --no-fix .` — the explicit read-only form, used for the baseline so the capture cannot mutate the tree under the current fix-mode default — and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-lint.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` stating the total finding count and, when the count is non-zero, each finding's rule code and path.
- [x] [P0-T5] Run `poetry run pyright` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-typecheck.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` stating the error count and the warning count.
- [x] [P0-T6] Run `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-test-coverage.2026-08-23T23-40.md`. The JSON report is required because the `term-missing` `TOTAL` row prints coverage.py's combined `percent_covered` figure, which is neither the line percent nor the branch percent; `artifacts/` is gitignored at `.gitignore:6`, so the report does not appear in any working-tree status snapshot. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the numeric total line-coverage percent computed as `totals.covered_lines` divided by `totals.num_statements` from `artifacts/python/coverage.json`, the numeric total branch-coverage percent computed as `totals.covered_branches` divided by `totals.num_branches` from the same file, the verbatim `TOTAL` row of the term report labelled as the combined figure, and the passed/failed/error test counts.
- [x] [P0-T7] Run `git ls-files -- pyproject.toml tests/scripts/dev_tools/test_ruff_config_alignment.py` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-ruff-config-state.2026-08-23T23-40.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording that `pyproject.toml` is tracked, that `tests/scripts/dev_tools/test_ruff_config_alignment.py` is not listed, and the verbatim text of the `[tool.ruff]` table at `pyproject.toml:88-92` including the fix-mode line at line 91 and `show-fixes = true` at line 92.

### Phase 1 — Regression Test Authored and Failing First

The module follows the structure of the precedent `tests/scripts/dev_tools/test_pyright_config_alignment.py`: resolve the repository root with `Path(__file__).resolve().parents[3]`, read the target file as UTF-8 text, and assert on that text. No subprocess, no fixture file, no temporary file.

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_ruff_config_alignment.py` carrying exactly four test functions named `test_ruff_config_does_not_enable_fix_mode`, `test_ruff_config_retains_show_fixes`, `test_no_standalone_ruff_config_at_repository_root`, and `test_quality_checks_workflow_still_runs_a_ruff_lint_step`, where the first tolerates whitespace and comment variation rather than matching one byte sequence, the third checks both the dotted and undotted root filenames, and the fourth asserts on the Ruff lint invocation in `.github/workflows/_quality-checks.yml` rather than on the step name. Acceptance: `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py --collect-only -q` reports exactly 4 collected items and exits 0, and the collected node IDs are exactly `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode`, `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes`, `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_no_standalone_ruff_config_at_repository_root`, and `tests/scripts/dev_tools/test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step`.
- [x] [P1-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v` against the still-unmodified `pyproject.toml` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T00-05.md`. Acceptance: the run reports 1 failed and 3 passed with the failure being `test_ruff_config_does_not_enable_fix_mode`, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` naming the failing test and quoting its assertion message.
- [x] [P1-T3] Confirm the new module is clean under the read-only Python toolchain, to prevent a format, lint, or type defect in the new module from forcing a Phase 4 loop restart, using the read-only lint form because fix mode is still enabled at this point and the bare form would rewrite the module the plan just authored, by running `poetry run black --check tests/scripts/dev_tools/test_ruff_config_alignment.py`, then `poetry run ruff check --no-fix tests/scripts/dev_tools/test_ruff_config_alignment.py`, then `poetry run pyright tests/scripts/dev_tools/test_ruff_config_alignment.py`, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/new-module-toolchain-precheck.2026-08-24T00-10.md`. Acceptance: all three commands exit 0 and the artifact carries `Timestamp:`, `Command:` (all three, listed), `EXIT_CODE:` for each, and an `Output Summary:` stating that none of the three reported a finding.

### Phase 2 — Configuration Fix

- [x] [P2-T1] Delete the single line that enables fix mode from the `[tool.ruff]` table in `pyproject.toml`, leaving `line-length`, `target-version`, and `show-fixes = true` unchanged. Acceptance: `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode -v` reports 1 passed, 0 failed, 0 errors and exits 0.
- [x] [P2-T2] Verify the `pyproject.toml` edit is a single-line deletion and nothing else by running `git diff --numstat -- pyproject.toml`. Acceptance: the command reports exactly 0 added lines and 1 deleted line for `pyproject.toml`, and `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes -v` reports 1 passed, 0 failed, 0 errors and exits 0.

### Phase 3 — Pass-After Regression and Manual QA-Gate Verification

The scratch inputs used by P3-T4 are created in a directory outside the repository working tree, so no repository file is written by that task and the no-temporary-files-in-tests rule is not engaged (the differential is manual evidence, not a committed test).

- [x] [P3-T1] Run `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v` against the post-change tree and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T00-20.md`. Acceptance: the run collects exactly the four named tests and reports 4 passed, 0 failed, 0 errors with exit code 0, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the four node IDs and the counts.
- [x] [P3-T2] Append a clearly labelled pass-after section to the existing single artifact `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T00-05.md`, recording the same test running green after the deletion. Acceptance: the file contains both runs, the fail-before headline rows `EXIT_CODE: 1` and `ExpectedExitCode: 1` remain the first occurrences in the file, and the appended section records `Pass-After Timestamp:`, `Pass-After Command:`, `Pass-After EXIT_CODE: 0`, and the observed 1-passed result for `test_ruff_config_does_not_enable_fix_mode`.
- [x] [P3-T3] Capture a working-tree status snapshot with `git status --porcelain`, run `poetry run ruff check`, capture a second snapshot with `git status --porcelain`, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-no-write.2026-08-24T00-30.md`. Acceptance: the two snapshot texts are byte-identical, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing both snapshots verbatim plus the explicit statement that they are byte-identical. The acceptance condition is snapshot equality; the recorded exit code is evidence, not the condition. Note for later readers: on a clean tree with no fixable violation present, this snapshot pair is non-discriminating in isolation — it would compare equal whether or not the fix had been applied. It is nevertheless mandatory because the spec's acceptance criterion requires exactly that pair of snapshots; the discriminating power of Phase 3 sits in P3-T4, not here.
- [x] [P3-T4] Create two scratch Python files in a directory outside the repository working tree — one containing an unfixable violation (a reference to an undefined name, rule `F821`) and one containing a fixable violation (an unused import, rule `F401`) — record each file's SHA-256 hash, run `poetry run ruff check` against each, with the current working directory set to the repository worktree root for both runs (this is required: the scratch files have no ancestor linter configuration, so the linter reaches the repository's `[tool.ruff]` table only through its working-directory fallback; run from any other directory it resolves its built-in defaults, where fix mode is already off, and the differential stops discriminating between the pre-change and post-change configuration), re-record each hash, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-manual-differential.2026-08-24T00-35.md`. Acceptance: both runs exit non-zero, the fixable-violation run prints the `[*]` fixable marker for each of its findings rather than a fixed-count line, both before and after hashes are identical for both files, and the artifact carries `Timestamp:`, `Command:` (both, listed), `EXIT_CODE:` for each, `ExpectedExitCode: 1`, and an `Output Summary:` recording the four hashes and the verbatim linter output.

### Phase 4 — Final Python QA Loop and Coverage Verification

The loop runs formatting, then linting, then type checking, then coverage-enabled tests. If any stage fails or changes a file, restart the loop from P4-T1 and re-record every artifact in this phase.

- [x] [P4-T1] Capture a `git status --porcelain` snapshot as the Phase 4 entry snapshot, then run `poetry run black --check .`, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-format.2026-08-24T00-45.md`. Acceptance: the black run exits 0, and the artifact carries `Timestamp:`, `Command:` (both, listed), `EXIT_CODE: 0` for the black run, and an `Output Summary:` stating that zero files would be reformatted and reproducing the Phase 4 entry snapshot verbatim, which P4-T6 reads as its first operand.
- [x] [P4-T2] Capture `git status --porcelain` immediately before and immediately after running `poetry run ruff check`, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-lint.2026-08-24T00-45.md`. Acceptance: the two snapshots are byte-identical AND the lint exit code is 0; the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` containing both snapshots verbatim, the statement that they are byte-identical, and the reported finding count.
- [x] [P4-T3] Run `poetry run pyright` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-typecheck.2026-08-24T00-45.md`. Acceptance: exit code 0 with 0 errors reported, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating the error count and the warning count.
- [x] [P4-T4] Run `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json` and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-test-coverage.2026-08-24T00-45.md`. The JSON report is required because the `term-missing` `TOTAL` row prints coverage.py's combined `percent_covered` figure, which is neither the line percent nor the branch percent; `artifacts/` is gitignored at `.gitignore:6`, so the report does not appear in any working-tree status snapshot and does not perturb the P4-T2 or P4-T6 snapshot comparisons. Acceptance: exit code 0 with 0 failed and 0 errors, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the numeric total line-coverage percent computed as `totals.covered_lines` divided by `totals.num_statements` from `artifacts/python/coverage.json`, the numeric total branch-coverage percent computed as `totals.covered_branches` divided by `totals.num_branches` from the same file, the verbatim `TOTAL` row of the term report labelled as the combined figure, and the passed test count.
- [x] [P4-T5] Compare the P0-T6 baseline coverage numbers against the P4-T4 post-change coverage numbers and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/coverage-delta-verification.2026-08-24T00-50.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the numeric baseline line and branch percentages, the numeric post-change line and branch percentages, each percentage identified as line or branch and each traced to the `artifacts/python/coverage.json` `totals` field it was computed from, the signed delta for each, the changed-code coverage statement (the diff adds no line to the measured source set `scripts/dev_tools` or `src`, because `pyproject.toml` is configuration and `tests/` is omitted at `pyproject.toml:122-127`), and the explicit verdict that total line coverage is at or above 85 percent, total branch coverage is at or above 75 percent, and neither figure regressed against baseline.
- [x] [P4-T6] Confirm the Phase 4 loop completed in a single pass with no stage having changed a file, by comparing the Phase 4 entry snapshot recorded verbatim in the P4-T1 artifact with a `git status --porcelain` snapshot taken after P4-T4, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T00-55.md`. Acceptance: the two snapshots are byte-identical, all four of P4-T1 through P4-T4 recorded `EXIT_CODE: 0`, and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing both snapshots verbatim and the single-pass verdict.

### Phase 5 — Write-Target and Acceptance-Criteria Verification

- [x] [P5-T1] Run `git diff --name-only origin/main...HEAD`, then run `git status --porcelain --untracked-files=all`, and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/other/write-target-verification.2026-08-24T01-00.md`. The second command is required because uncommitted work does not appear in the merge-base diff, and because `git status --porcelain` without `--untracked-files=all` collapses an untracked directory to a single entry. Acceptance: the union of the paths reported by the two commands is exactly `pyproject.toml`, `tests/scripts/dev_tools/test_ruff_config_alignment.py`, and paths under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`; that union contains both `pyproject.toml` and `tests/scripts/dev_tools/test_ruff_config_alignment.py`, so an empty or partial union is a failure and not a pass; the union contains none of `.claude/rules/python.md`, `.github/instructions/python-code-change.instructions.md`, `scripts/dev_tools/atomic_executor/qc_runner_loop.py`, or `scripts/dev_tools/fix_all_branches_extra.py`; and the artifact carries `Timestamp:`, `Command:` (both, listed), `EXIT_CODE:` for each, and an `Output Summary:` reproducing both raw outputs verbatim and the derived union.
- [x] [P5-T2] Mark each of the 10 acceptance criteria in `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md` as checked and write `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/other/acceptance-criteria-traceability.2026-08-24T01-05.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing a 10-row table mapping each acceptance criterion to the plan task and the evidence artifact path that satisfies it, with no row left unmapped, and the `## Acceptance Criteria` section of `spec.md` contains zero unchecked boxes. The unchecked boxes under `Impact / Severity` are not acceptance criteria, are outside the scope of this task, and must remain unchanged.

## Acceptance-Criteria Traceability

| Spec acceptance criterion | Satisfying task(s) |
| --- | --- |
| 1. Fix mode removed; `test_ruff_config_does_not_enable_fix_mode` passes | P2-T1, P3-T1 |
| 2. `show-fixes = true` retained; `test_ruff_config_retains_show_fixes` passes | P1-T1, P2-T2, P3-T1 |
| 3. No root standalone Ruff config; `test_no_standalone_ruff_config_at_repository_root` passes | P1-T1, P3-T1 |
| 4. CI Ruff lint step still invoked; `test_quality_checks_workflow_still_runs_a_ruff_lint_step` passes | P1-T1, P3-T1 |
| 5. Module collects exactly four tests and reports 4 passed; run recorded under `evidence/regression-testing/` | P1-T1, P3-T1 |
| 6. Fail-before and pass-after recorded in a single artifact with the non-zero expectation declared | P1-T2, P3-T2 |
| 7. Merge-base diff lists exactly the authorized paths and none of the prohibited ones | P5-T1 |
| 8. Lint stage performs no write; before/after status snapshots byte-identical, recorded under `evidence/qa-gates/` | P3-T3, P4-T2 |
| 9. Manual differential on scratch inputs outside the repository, with `ExpectedExitCode` declared | P3-T4 |
| 10. Seven-stage toolchain completes in a single pass with no stage having changed a file | P4-T1, P4-T2, P4-T3, P4-T4, P4-T6 |

## Files This Plan Writes

Repository files (2):

```
pyproject.toml
tests/scripts/dev_tools/test_ruff_config_alignment.py
```

Feature documents (2):

```
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md
```

Evidence artifacts (20):

```
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-instructions-read.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-git-baseline.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-format.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-lint.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-typecheck.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-test-coverage.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-ruff-config-state.2026-08-23T23-40.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T00-05.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/new-module-toolchain-precheck.2026-08-24T00-10.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T00-20.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-no-write.2026-08-24T00-30.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-manual-differential.2026-08-24T00-35.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-format.2026-08-24T00-45.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-lint.2026-08-24T00-45.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-typecheck.2026-08-24T00-45.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-test-coverage.2026-08-24T00-45.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/coverage-delta-verification.2026-08-24T00-50.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T00-55.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/other/write-target-verification.2026-08-24T01-00.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/other/acceptance-criteria-traceability.2026-08-24T01-05.md
```

Untracked tool output (1), written by P0-T6 and P4-T4 and not part of the diff:

```
artifacts/python/coverage.json
```

`artifacts/` is gitignored at `.gitignore:6`, so this file is not a repository write, does not appear in the P5-T1 union, and does not perturb the P4-T2 or P4-T6 snapshot comparisons. It is listed here only so that no reader mistakes it for an unplanned write.
