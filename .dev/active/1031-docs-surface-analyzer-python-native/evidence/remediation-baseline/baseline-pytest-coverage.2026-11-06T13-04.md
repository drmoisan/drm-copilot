# [P0-T4] Remediation baseline: full Python suite with coverage

Timestamp: 2026-11-06T13-04
Command: poetry run python -m pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-baseline-coverage.json --cov
EXIT_CODE: 1
Output Summary: 16268 passed, 1 failed, 6 skipped in 742.27 s. JSON totals: line 96.82% (34026/35142), branch 93.84% (12522/13344), combined percent_covered 96.00 (terminal TOTAL 96%). The addopts LCOV reporter wrote artifacts/python/lcov.info.

## Pre-existing failure (host location, not caused by this branch)

- `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies`: `assert len(copies) == 6` sees 0 copies. The test discards every path whose parts include `worktrees`; this checkout is the item worktree under `.claude/worktrees/`, so every copy is discarded. No file was changed before this run (Phase 0 writes evidence only). The test passes in a checkout outside a `worktrees` directory, which is the CI shape.
