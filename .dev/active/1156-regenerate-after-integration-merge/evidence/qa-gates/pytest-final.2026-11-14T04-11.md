# Pytest Final Gate, QA loop re-run — [P6-T4]

Timestamp: 2026-11-14T04-11
Command: sh SCRATCH/issue-1156-pytest-final.sh (from the item worktree root, VIRTUAL_ENV unset: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-final.json --junitxml=artifacts/python/junit-final.xml -q -p no:cacheprovider; coverage sources from [tool.coverage.run] source in pyproject.toml, as in [P0-T4])
EXIT_CODE: 0
Output Summary: one pytest -n auto run after the [P6-T8] coverage tests and the merge of origin/main (#1174): 16729 passed, 6 skipped, 0 failed (198.68 s). Repo-wide line coverage 97.13% (34574/35595 statements) against the Phase 0 baseline 97.11%; branch coverage 94.42% (12785/13540 branches) against 94.37%; both from the JSON report totals. JUnit: 16735 test cases, 0 failures, 0 errors. Every file named in [P6-T4] and every brief-listed mirror contract test ran with 0 failures (same per-file case counts as `pytest-final.2026-11-14T03-42.md`). No production Python file changed.

The Python static loop of [P6-T3] was also re-run at this head with the same result as `python-final-qc.2026-11-14T03-38.md`: Black "3 files would be left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations" (no Python file changed since that run).
