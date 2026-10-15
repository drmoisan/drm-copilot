# Python Coverage (PA-1 remediation, Issue #896)

Timestamp: 2026-10-12T07-49
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-896.json
EXIT_CODE: 0
Output Summary:
- (a) Pytest summary line: `================= 6956 passed, 6 skipped in 74.24s (0:01:14) ==================`; TOTAL row: `TOTAL                                                                 17633   1094   6364    505    92%`
- (b) Python line coverage: 93.80% (threshold 85.00%)
- (b) Python branch coverage: 88.10% (threshold 75.00%)
- (c) LF 17633, LH 16539, BRF 6364, BRH 5607; LCOV_LINE 93.80, LCOV_BRANCH 88.10
- (d) Coverage artifacts: `artifacts/python/lcov.info`, `artifacts/python/coverage-896.json`
- (e) Baseline comparison: per P0-T3 (only `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` differs among `.py` paths) and P0-T4 (that file imports only `__future__`, `pathlib`, `pytest` at head and base), the production denominator and numerator are identical on `origin/epic/subagentstop-envelope-integration`, so baseline line coverage is 93.80% and baseline branch coverage is 88.10%; the change is 0.00 points for both.
- (f) New/changed production code coverage: none (no Python production file changed)
- (g) Disposition: PASS (line 93.80 >= 85.00, branch 88.10 >= 75.00, no test failed)
- (h) Pointers:
  - P0-T3: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/remediation-baseline/python-diff.2026-10-12T07-47.md`
  - P0-T4: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/remediation-baseline/changed-test-imports.2026-10-12T07-47.md`
  - P1-T1: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/python-coverage-run.2026-10-12T07-47.md`
  - P1-T2: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/python-coverage-values.2026-10-12T07-49.md`
