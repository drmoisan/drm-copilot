# Final QC — Python Tests and Coverage (Pytest)

Timestamp: 2026-08-08T20-06

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

Loop iteration recorded: **iteration 2 — the final clean pass.**

EXIT_CODE: 0

Output Summary:
- Passed: **3007**
- Failed: **0**
- Skipped: **0**
- Errors: 0
- Wall time: 10.63s
- Post-change line (statement) coverage: **91.82%** (`percent_statements_covered` 91.82362065145136;
  **12432 of 13539** statements covered, 1107 missing, 387 excluded)
- Post-change branch coverage: **83.80%** (`percent_branches_covered` 83.8; **4190 of 5000** branch
  destinations covered, 810 missing, 556 partial)
- Combined coverage.py headline printed by the terminal report: `TOTAL 13539 1107 5000 556 90%`
  (`percent_covered` 89.65963644209505)
- Both thresholds hold: line 91.82% >= 85%, branch 83.80% >= 75%.

## Test-Count Reconciliation

| Quantity | Value |
| --- | --- |
| `[P0-T6]` remediation-cycle baseline | 3004 |
| Tests added by Phase 1 | 3 |
| Expected | 3007 |
| Measured | **3007** |

The count reconciles exactly as baseline plus added, and satisfies the plan's floor of "at least 3004
plus the three tests added in Phase 1". The three added tests are
`test_every_prescribed_parent_write_target_has_a_persona_write_grant`,
`test_every_prescribed_command_invocation_has_a_persona_bash_grant`, and
`test_manifest_validation_gate_prescribes_a_granted_command_invocation`, all in
`tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py`. No existing test was
weakened, deleted, skipped, or `xfail`-marked; the skip count is zero.

## Machine-Readable Totals

Extracted by `poetry run coverage json` from this run's data file without re-running the suite:

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

## Verbatim Terminal Report Tail

```
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              13539   1107   5000    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 3007 passed in 10.63s ============================
```
