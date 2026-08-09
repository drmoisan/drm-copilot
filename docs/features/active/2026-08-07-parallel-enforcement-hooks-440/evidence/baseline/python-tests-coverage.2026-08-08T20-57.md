# Baseline — Python Tests and Coverage (Pytest) — Issue #440

Timestamp: 2026-08-08T20-57

Task: [P0-T8]

Branch: `feature/parallel-enforcement-hooks-440` (base `epic/parallel-orchestration-integration` at `c939b5b8`)

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`)

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test Result

```
3007 passed in 15.54s
Coverage LCOV written to file artifacts/python/lcov.info
```

Zero failures, zero errors, zero skips reported. Platform: `win32`, Python `3.13.12-final-0`.

## Numeric Coverage Headline

The aggregate row of the `term-missing` report:

```
Name                                                               Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              13539   1107   5000    556    90%
```

The `Cover` column that pytest-cov prints under `--cov-branch` is the **combined** statement-plus-branch figure, not the line figure. Repository policy (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`) sets separate line and branch thresholds, so the two values were separated from the same loaded coverage data (`coverage.Coverage().load()`, summing `n_statements` / `n_missing` / `n_branches` / `n_missing_branches` across every measured file):

```
STMTS total=13539 covered=12432 missed=1107
LINE_PCT=91.82
BRANCHES total=5000 covered=4190 missed=810
BRANCH_PCT=83.80
```

| Metric | covered | total | percentage | policy threshold | status |
| --- | --- | --- | --- | --- | --- |
| **Line coverage** | 12432 | 13539 | **91.82%** | >= 85% | PASS |
| **Branch coverage** | 4190 | 5000 | **83.80%** | >= 75% | PASS |
| Combined (pytest-cov `Cover`) | 16622 | 18539 | 89.66% (prints as 90%) | n/a | n/a |

The combined figure reconciles: `(12432 + 4190) / (13539 + 5000) = 16622 / 18539 = 89.66%`, which the report rounds to `90%`.

## Per-File Baseline for the Files This Feature Touches

Recorded so that the Phase 3 and Phase 5 comparisons can be made per file:

| File | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (edited by P3-T3) | 82 | 2 | 34 | 2 | 97% |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (created by P3-T1) | — | — | — | — | does not exist at baseline |

The three F3 helper modules that the new helper sits beside are at 100% coverage at baseline (`_parallel_state_common.py`, `_parallel_state_records.py`, `_parallel_state_structures.py`), which sets the expectation for the new helper module.

Output Summary: PASS. EXIT_CODE 0; 3007 tests passed in 15.54s with zero failures, errors, or skips. Baseline line coverage 91.82% (12432 of 13539 statements) and baseline branch coverage 83.80% (4190 of 5000 branches); both exceed the uniform policy thresholds of >= 85% line and >= 75% branch. The 90% figure in the pytest-cov `TOTAL` row is the combined statement-plus-branch metric (89.66% before rounding), not the line figure, so the separated values above are the ones the P5-T8 delta comparison must use. `scripts/dev_tools/validate_parallel_orchestrator_state.py`, the only existing Python file this feature edits, is at 97% (82 statements, 2 missed) at baseline; the helper module `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` does not yet exist.
