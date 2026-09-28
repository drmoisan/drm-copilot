# Baseline — Python Tests and Coverage (P0-T4)

Timestamp: 2026-08-08T21-31

Task: [P0-T4] Capture Python test + coverage baseline with numeric coverage values.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
HEAD at capture time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test Result Counts (numeric, no placeholders)

| Metric | Baseline value |
| --- | --- |
| Passed | 3007 |
| Failed | 0 |
| Errors | 0 |
| Skipped | 0 |
| XFailed | 0 |
| XPassed | 0 |
| Total collected | 3007 |
| Wall time | 15.30 s |

Terminal summary line: `============================ 3007 passed in 15.30s ============================`

## Coverage — Numeric Baseline Values (no placeholders)

The `term-missing` `TOTAL` row reports coverage.py's COMBINED statement-plus-branch figure in its
`Cover` column, which is not the same number as either the line-coverage or the branch-coverage
figure the repository's `>= 85%` line / `>= 75%` branch thresholds are stated against. The separate
figures below were therefore read from the coverage data itself so that P7-T8 can compute a
like-for-like delta.

TOTAL row as printed:

```
TOTAL                                                              13539   1107   5000    556    90%
```

Confirming extraction command: `poetry run coverage json -o coverage-baseline-probe.json -q` followed
by a read of the `totals` object. (The probe JSON was a transient read-only extraction of the
already-written coverage data; it was deleted immediately after the values below were recorded, and
`git status --porcelain` afterwards showed only this feature's plan edit and evidence folder.)

Confirming EXIT_CODE: 0

```json
{
  "covered_lines": 12432,
  "num_statements": 13539,
  "percent_covered": 89.65963644209505,
  "percent_covered_display": "90",
  "missing_lines": 1107,
  "excluded_lines": 387,
  "percent_statements_covered": 91.82362065145136,
  "percent_statements_covered_display": "92",
  "num_branches": 5000,
  "num_partial_branches": 556,
  "covered_branches": 4190,
  "missing_branches": 810,
  "percent_branches_covered": 83.8,
  "percent_branches_covered_display": "84"
}
```

| Coverage metric | Baseline numeric value | Threshold | Baseline verdict |
| --- | --- | --- | --- |
| Line (statement) coverage | **91.82%** (12432 covered / 13539 statements; 1107 missing) | >= 85% | PASS, margin +6.82 pp |
| Branch coverage | **83.80%** (4190 covered / 5000 branches; 810 missing, 556 partial) | >= 75% | PASS, margin +8.80 pp |
| Combined statement+branch (`Cover` column) | 89.66% (displayed as 90%) | not a policy threshold | recorded for row-to-row comparison only |
| Excluded lines | 387 | n/a | recorded so a change in exclusions is detectable at P7-T8 |

Coverage LCOV side-output written by the existing pytest configuration to
`artifacts/python/lcov.info`. That path is the pre-existing tool output location configured in the
repository, not an evidence path; no evidence artifact for this feature is written under
`artifacts/`.

## Baseline for the One Shared Python File F6 Edits

`scripts/dev_tools/validate_parallel_orchestrator_state.py` is the only pre-existing Python file this
plan modifies (P3-T2, exactly one added import line and one added call line). Its baseline row is
recorded here so P7-T8 can confirm no coverage regression on that file:

```
scripts\dev_tools\validate_parallel_orchestrator_state.py             82      2     34      2    97%   226, 265
```

Baseline: 82 statements, 2 missing, 34 branches, 2 partial, 97% combined; uncovered lines 226 and 265.

The four Python modules named in P7-T4 (`parallel_mutation_protocol.py`,
`_parallel_mutation_models.py`, `parallel_mutation_abandon_cli.py`,
`_parallel_orchestrator_state_mutations.py`) do not exist at baseline, so their baseline coverage is
NOT APPLICABLE (file absent), not zero. P7-T4 records their post-change per-module figures.

## Pre-Existing Failures (none for Python)

The Python suite has zero failures at baseline: 3007 passed, 0 failed, 0 errors. No Python test
failure is inherited by this feature, so any Python test failure appearing in Phase 2, Phase 3, or
Phase 7 is attributable to this feature's changes and is a genuine finding, not a pre-existing
condition.

The two known pre-existing failures on this branch are PowerShell/Pester tests, recorded in
`baseline-ps-test-coverage.md` (P0-T6):
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/claude-hooks/codex-pretooluse-integration.Tests.ps1`.

Output Summary: `poetry run pytest --cov --cov-branch --cov-report=term-missing` exited 0 with
**3007 passed, 0 failed, 0 errors, 0 skipped** in 15.30 s. Baseline **line (statement) coverage
91.82%** (12432/13539, 1107 missing) and **branch coverage 83.80%** (4190/5000, 810 missing, 556
partial); combined statement+branch figure 89.66% (displayed 90%); 387 excluded lines. Both policy
thresholds are met at baseline (line >= 85%, branch >= 75%), so Phase 7 must hold at or above these
figures. Shared-file baseline recorded for `validate_parallel_orchestrator_state.py` (82 stmts, 2
missing, 97% combined, uncovered lines 226 and 265). No Python test fails at baseline.
