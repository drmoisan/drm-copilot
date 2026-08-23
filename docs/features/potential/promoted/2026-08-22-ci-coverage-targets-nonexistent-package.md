# ci-coverage-targets-nonexistent-package (Issue #506)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-coverage-targets-nonexistent-package/ (Issue #506)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

- Issue: #506
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/506
- Last Updated: 2026-08-23
## Summary

The CI test step measures coverage against `src/lexile_corpus_tuner`, a package that does not exist in this repository. The name belongs to a different project and appears to be template residue. The run therefore collects no coverage data at all, and the workflow uploads an empty report to Codecov. The repository's CI coverage signal cannot fail on a regression because it measures nothing.

## Environment

- OS/version: GitHub Actions runner, and reproduced locally on Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing`
- Data source or fixture: `.github/workflows/_quality-checks.yml` line 76, reached from `.github/workflows/ci.yml` line 12

## Steps to Reproduce

1. Confirm the target is absent: `ls -d src/lexile_corpus_tuner` reports no such file or directory.
2. Run the workflow's command verbatim from the repository root.
3. Read the `tests coverage` section of the output.

## Expected Behavior

The coverage target names a real, importable package in this repository, expressed as a dotted module path, so the reported percentage reflects the code actually under test and a regression can fail the gate.

## Actual Behavior

The suite runs and passes, and the coverage table is printed with no rows and no `TOTAL` line. No data is collected. The subsequent `Upload coverage to Codecov` step then publishes that empty `coverage.xml`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet, measured locally on 2026-08-22:

  ```text
  =============================== tests coverage ================================
  ______________ coverage: platform win32, python 3.13.12-final-0 _______________

  4078 passed, 5 skipped in 13.20s
  ```

  The coverage block is empty between its header and the test summary.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. Every pull request has been merging against a coverage check that cannot fail. The repository's own policy in `.claude/rules/general-unit-test.md` requires line coverage at or above 85 percent and branch coverage at or above 75 percent, and `.claude/rules/plan-acceptance-gates.md` classifies a `--cov=<path>` value of exactly this shape as a Blocking defect when it appears in a plan. The same defect in the pipeline itself has been unenforced.

## Suspected Cause / Notes

Two independent problems in one value. The package name is foreign to this repository, and the value uses the filesystem-path form rather than an importable dotted module, which is the form `coverage.py` requires. Either alone would break collection.

Note that the test selection is not restricted, so the suite result reported by CI is real. Only the coverage figure is vacuous.

## Proposed Fix / Validation Ideas

- [ ] Replace the target with the dotted module path or paths this repository actually ships, for example `scripts.dev_tools`, and confirm a non-empty `TOTAL` row appears.
- [ ] Decide whether the branch flag is required, since the repository policy states a branch threshold; note that with `--cov-branch` the `TOTAL` row's `Cover` cell is a combined ratio and the branch figure must be read from `totals.percent_branches_covered` in a JSON report.
- [ ] Unit coverage areas: none directly; this is a workflow change.
- [ ] Integration scenario to retest: a deliberate coverage regression must fail the check.
- [ ] Manual verification notes: the change touches `.github/workflows/**`, so the `modified-workflow-needs-green-run` policy rule requires a green workflow run against the branch head before merge.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
