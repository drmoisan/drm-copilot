# Python Test Baseline, with Coverage (Remediation Cycle 2)

Timestamp: 2026-07-03T00-26

Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`

EXIT_CODE: 0

Output Summary: **1192 passed, 19 skipped, 0 failed** (19 skips are pre-existing
`.codex`/`.agents` gitignore-unavailable-in-CI skips, unrelated to this remediation cycle).

Coverage `TOTAL` row (combined statement + branch, per `coverage.py`'s standard reporting,
consistent with cycle 1's convention): `Stmts=9032, Miss=1242, Branch=3250, BrPart=447,
Cover=83%`.

These figures (1192 passed / 19 skipped / 0 failed, 83% combined coverage) are the pre-fix
baseline for this cycle's [P1-T5] pass-count comparison and [P2-T4] coverage-regression
comparison.
