# Pytest Final Gate — remediation cycle 2, [P2-T3]

Timestamp: 2026-11-14T07-43
Command: sh SCRATCH/issue-1156-pytest-gate.sh final (from the item worktree root, VIRTUAL_ENV unset: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-final.json --junitxml=artifacts/python/junit-final.xml -q -p no:cacheprovider); totals read by sh SCRATCH/issue-1156-pyres.sh from the JSON report and the JUnit file
EXIT_CODE: 0
Output Summary:
- One `pytest -n auto` run: 16729 passed, 6 skipped, 0 failed (239.59 s, 07:39:36 to 07:43:41 UTC); JUnit 16735 cases, 0 failures, 0 errors.
- Total line coverage 97.13% (34574/35595 statements) against the `Phase 0 baseline` 97.11% (`evidence/baseline/pytest-parallel.2026-11-10T03-53.md`); total branch coverage 94.42% (12785/13540) against 94.37%; both from the JSON report totals. Terminal TOTAL row (combined column) 96%. No drop.
- The `term-missing:skip-covered` reporter variant is the same one the cycle 1 final gate used; it prints the same TOTAL row, and the totals come from the JSON report.
- This cycle changed no Python file; the push-down contract tests that read the edited Markdown and bundle files pass inside this run.
