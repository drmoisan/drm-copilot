# Pytest Final Gate — remediation cycle 1, [P2-T3]

Timestamp: 2026-11-14T05-49
Command: sh SCRATCH/issue-1156-tiers.sh (from the item worktree root, VIRTUAL_ENV unset: poetry run python -m scripts.dev_tools.check_quality_tiers), then sh SCRATCH/issue-1156-pytest-final.sh (VIRTUAL_ENV unset: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-final.json --junitxml=artifacts/python/junit-final.xml -q -p no:cacheprovider)
EXIT_CODE: 0
Output Summary:
- Tier check: `quality-tiers: OK (34 entries, 34 discovered projects)`, exit 0 (fail-before exit 1 with QT008 in `evidence/remediation-baseline/quality-tiers-check.2026-11-14T04-52.md`).
- pytest: one `pytest -n auto` run, 16729 passed, 6 skipped, 0 failed (276.20 s); JUnit 16735 cases, 0 failures, 0 errors.
- Total line coverage 97.13% (34574/35595 statements) against the `Phase 0 baseline` 97.11% (`evidence/baseline/pytest-parallel.2026-11-10T03-53.md`); branch coverage 94.42% (12785/13540) against 94.37%; both from the JSON report totals. Terminal TOTAL row (combined column) 96%. No drop.
- No production Python file changed in this cycle.
