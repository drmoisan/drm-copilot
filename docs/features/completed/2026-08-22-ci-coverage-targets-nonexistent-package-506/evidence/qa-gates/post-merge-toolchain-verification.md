# Post-merge toolchain verification — issue #506

Timestamp: 2026-08-25T22-05

## Why this artifact exists

The Phase 0 through Phase 5 evidence of this work item was captured in the worktree
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad22fbcf94d2d5359` on the branch
`bug/ci-coverage-targets-nonexistent-package-506-r2`, at branch head `08c9c14f`. Execution was then
resumed in a different worktree, `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae6ac3aa9ae64fae4`,
on the branch `bug/ci-coverage-targets-nonexistent-package-506-r3`, and `origin/main` was merged into
that branch before the remaining Phase 6 tasks were executed.

The merge changed the tree the earlier artifacts describe. Those artifacts therefore remain valid
records of the state they measured but are no longer a statement about the current branch head. This
artifact re-runs the full Python toolchain loop, the workflow linter, the new enforcement gate, and
the committed-diff scope gate against the post-merge head, so that no acceptance criterion is checked
off against a measurement of a superseded tree.

This artifact is additive. It supersedes no earlier artifact and amends none.

## Resolved context

- Resolved repository root: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae6ac3aa9ae64fae4`
- Resolved branch name: `bug/ci-coverage-targets-nonexistent-package-506-r3`
- Branch head at measurement: `890e2ac9369e5a67f282bb7bc3ca438589427676`
- `origin/main` at measurement: `8ca66c1db827cbfb59261ca0b85bb5b7a766908e`
- Merge base of `origin/main` and `HEAD`: `8ca66c1db827cbfb59261ca0b85bb5b7a766908e`

The merge base equals `origin/main`, which confirms the branch is fully up to date with `main` and
that the three-dot committed-diff listing below carries only this work item's own change.

## Gate 1 — formatting

Timestamp: 2026-08-25T22-05
Command: `poetry run black --check .`
EXIT_CODE: 0
Output Summary: `All done!` — 448 files would be left unchanged, zero files would be reformatted.

## Gate 2 — linting

Timestamp: 2026-08-25T22-05
Command: `poetry run ruff check .`
EXIT_CODE: 0
Output Summary: `All checks passed!` — zero diagnostics.

## Gate 3 — type checking

Timestamp: 2026-08-25T22-05
Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. The message
`venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae6ac3aa9ae64fae4.`
is recorded verbatim. Per Trap 1 of the plan this message is expected when the executing checkout has
no `.venv` subdirectory, is not a finding, and was not answered by creating a virtual environment.

## Gate 4 — full test suite with coverage

Timestamp: 2026-08-25T22-05
Command: `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing -q`
EXIT_CODE: 0
Output Summary: `4136 passed, 5 skipped in 20.30s`. Zero tests failed. Verbatim `TOTAL` row:

```
TOTAL                                                               15014   1104   5506    560    91%
```

The `91%` cover value is the combined statements-plus-branches ratio, not line coverage. The two
policy metrics are recorded by Gate 6 below from the JSON report, because the terminal reporter
prints neither of them when branch measurement is on.

## Gate 5 — tracked `coverage.xml` restore

Gate 4 passes `--cov-report=xml`, which overwrites the tracked repository-root `coverage.xml` in
place. The restore required by the plan was performed.

Timestamp: 2026-08-25T22-05
Command: `git checkout -- coverage.xml`
EXIT_CODE: 0
Output Summary: No output. The tracked committed Pester JaCoCo report was restored.

Timestamp: 2026-08-25T22-05
Command: `git status --porcelain -- coverage.xml`
EXIT_CODE: 0
Output Summary: No output, confirming `coverage.xml` is unmodified and will not enter any diff.

## Gate 6 — policy coverage metrics from the JSON report

Timestamp: 2026-08-25T22-05
Command: `poetry run python -c "import json;d=json.load(open('artifacts/python/coverage.json'));print(d['totals']['num_statements'],d['totals']['percent_statements_covered'],d['totals']['percent_branches_covered'])"`
EXIT_CODE: 0
Output Summary: `15014 92.64686292793392 85.2161278605158`

- Statement count: `15014`, greater than zero.
- Line coverage: `92.64686292793392`, at or above the 85 floor.
- Branch coverage: `85.2161278605158`, at or above the 75 floor.

These are the same three values recorded by task P4-T5 before the merge, so the merge changed neither
policy metric.

## Gate 7 — the new enforcement gate against the real report

Timestamp: 2026-08-25T22-05
Command: `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`
EXIT_CODE: 0
Output Summary: No output and a zero exit code, which is the gate's pass signal. This demonstrates that
the workflow's `Enforce Python coverage thresholds` step passes against the post-merge branch head.

## Gate 8 — workflow linting

Timestamp: 2026-08-25T22-05
Command: `pwsh -File scripts/dev-tools/run-actionlint.ps1`
EXIT_CODE: 0
Output Summary: `Running actionlint...` followed by no findings. Zero findings against the modified
workflow set.

## Gate 9 — this work item's own tests

Timestamp: 2026-08-25T22-05
Command: `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_check_python_coverage_thresholds.py -q`
EXIT_CODE: 0
Output Summary: `15 passed in 0.09s` — six workflow-contract tests and nine checker unit tests, zero
failed. The counts match the six and nine the plan states for tasks P1-T7 and P3-T9.

## Gate 10 — committed-diff scope gate, re-run at the post-merge head

Timestamp: 2026-08-25T22-05
Command: `git diff --name-only origin/main...HEAD`
EXIT_CODE: 0
Output Summary: 43 paths. The three-dot form is used because the local `main` ref may be stale; the
merge base recorded above equals `origin/main`, so the listing carries only this work item's change.

Recorded name list, in the order git emitted it:

```
.github/workflows/_quality-checks.yml
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-repro.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-restore.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-environment-provenance.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-format-black.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-lint-ruff.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-test-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-typecheck-pyright.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/workflow-actionlint.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/ac-evidence-index.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/batch-budget-clear-before-toolchain-restart.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/human-interaction-d5.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-28.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-45.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T12-55.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-05.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-21.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/committed-diff-scope.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-delta.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-threshold-enforcement.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-format-black.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-lint-ruff.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-test-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-typecheck-pyright.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/toolchain-single-pass-transcript.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-actionlint-post-edit.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/worktree-scope-blocked-policy-files.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/worktree-scope-pyproject.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/checker-unit-tests-pass.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-fail-before.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-pass-after.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
scripts/dev_tools/check_python_coverage_thresholds.py
tests/scripts/dev_tools/test_check_python_coverage_thresholds.py
tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
```

### Verdicts

- **(a) Non-empty and carries the four required paths — PASS.** The list holds 43 paths and contains
  `.github/workflows/_quality-checks.yml`, `scripts/dev_tools/check_python_coverage_thresholds.py`,
  `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`, and
  `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`.
- **(b) `pyproject.toml` absent — PASS.** The project manifest at the repository root does not appear
  in the list. This is the committed half of AC-14.
- **(c) The four blocked policy paths absent — PASS.** None of
  `.github/instructions/python-unit-test.instructions.md`,
  `.github/instructions/python-suppressions.instructions.md`,
  `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md`,
  or `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md`
  appears in the list. This is the committed half of AC-15.
- **(d) Every path falls under the closed nine-entry write set — PASS.** Mapping by entry: entry 1
  takes the workflow (1 path); entry 2 the checker module (1); entry 3 and entry 4 the two test
  modules (1 each); entry 5 the plan (1); entry 6 `spec.md` (1); entry 7 the whole evidence subtree
  (35 paths, comprising 10 under `evidence/baseline/`, 8 under `evidence/other/`, 14 under
  `evidence/qa-gates/`, and 3 under `evidence/regression-testing/`); entry 8 `issue.md` (1); entry 9
  the research document (1). That is 1+1+1+1+1+1+35+1+1 = 43, which equals the recorded list length,
  so no path falls outside the write set. `coverage.xml` is not among them, confirming the Gate 5
  restore held.

## Overall verdict

PASS. Every gate re-run at the post-merge head `890e2ac9369e5a67f282bb7bc3ca438589427676` reproduces
the result its pre-merge counterpart recorded. The merge of `origin/main` introduced no formatting,
lint, type, test, coverage, workflow-lint, or scope regression.

## What this artifact does not establish

This artifact records no workflow run. The `modified-workflow-needs-green-run` rule requires a green
workflow run against the branch head, and that evidence is produced separately by plan task P6-T5 in
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/green-workflow-run.md`.
Nothing here may be read as satisfying AC-17.
