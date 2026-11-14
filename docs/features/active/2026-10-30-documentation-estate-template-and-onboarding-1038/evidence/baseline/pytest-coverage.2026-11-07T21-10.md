# Phase 0 pytest baseline (parallel gate, with coverage)

Timestamp: 2026-11-07T21-10
Command: sh SCRATCH/issue-1038-pytest.sh baseline (poetry run pytest -n auto --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1038-pytest-baseline-coverage.json --junitxml=SCRATCH/issue-1038-pytest-baseline-junit.xml -q -p no:cacheprovider; coverage sources from [tool.coverage.run] in pyproject.toml), then sh SCRATCH/issue-1038-pytest-summary.sh baseline reading the JUnit and JSON reports
EXIT_CODE: 0
Output Summary: 16480 passed, 0 failed, 6 skipped in 244.20 s (run started 2026-11-07T21-05). Failing tests: none. Repo-wide coverage headline (JSON totals): line 52.47% (18509/35278 statements), branch 49.15% (6580/13388 branches), combined 51.55%. The six skips are pre-existing (one in test_blast_radius_regression_452.py, five in test_parallel_manifest_bash_parity.py).

Owner-directive record (owner directive 2026-11-07, decision 1): this artifact is the Phase 0 pytest baseline that the directive adds; it is one `poetry run pytest -n auto` run with coverage. This child changes no Python file, so the comparison at [P4-T4] is on failing tests and the repo-wide headline only.
