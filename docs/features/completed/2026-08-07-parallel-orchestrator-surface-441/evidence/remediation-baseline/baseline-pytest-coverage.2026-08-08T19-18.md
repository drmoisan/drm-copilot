# Remediation Baseline — Python Tests and Coverage (Pytest)

Timestamp: 2026-08-08T19-18

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

HEAD: `41633ad5e867070853e3e4501c3457b6641d1efc`

EXIT_CODE: 0

Output Summary:
- Passed: 3004
- Failed: 0
- Skipped: 0
- Errors: 0
- Wall time: 11.47s
- Baseline line (statement) coverage: 91.82% (`percent_statements_covered` 91.82362065145136; 12432 of 13539 statements covered, 1107 missing, 387 excluded)
- Baseline branch coverage: 83.80% (`percent_branches_covered` 83.8; 4190 of 5000 branches covered, 810 missing, 556 partial)
- Combined line-plus-branch headline printed by the terminal report: `TOTAL 13539 1107 5000 556 90%` (`percent_covered` 89.65963644209505)
- Both figures clear their floors: line 91.82% >= 85%, branch 83.80% >= 75%.

The recorded pass count of **3004** is the remediation-cycle baseline for the Phase 6 reconciliation.
Phase 1 adds three tests, so the Phase 6 expected count is 3004 + 3 = 3007.

## Verbatim Terminal Report Tail

```
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              13539   1107   5000    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 3004 passed in 11.47s ============================
```
