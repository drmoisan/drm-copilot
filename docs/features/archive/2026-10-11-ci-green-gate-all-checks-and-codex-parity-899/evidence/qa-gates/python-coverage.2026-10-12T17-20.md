# Python Coverage: R-1 Re-closure (P2-T10, remediation cycle 2)

Timestamp: 2026-10-12T18-13

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/issue-899-coverage-cycle2.json

EXIT_CODE: 0

Output Summary:
- (a) Pytest summary line (verbatim): `================= 7004 passed, 6 skipped in 79.35s (0:01:19) ==================`. TOTAL row (verbatim): `TOTAL                                                                 17633   1094   6364    505    92%`. Failed-node count: 0.
- (b) Python line coverage: 93.80% (threshold 85.00%)
- (b) Python branch coverage: 88.10% (threshold 75.00%)
- (c) LF 17633, LH 16539, BRF 6364, BRH 5607, LCOV_LINE 93.80, LCOV_BRANCH 88.10 (from P2-T8).
- (d) Data files: `artifacts/python/lcov.info` (496475 bytes) and `artifacts/python/issue-899-coverage-cycle2.json`. Both are gitignored under `/artifacts` and are not committed.
- (e) Baseline comparison: per P0-T5 and P2-T9 no production Python differs from `origin/main`, so the baseline line and branch figures equal FINAL_TOTAL_LINE (93.80) and FINAL_TOTAL_BRANCH (88.10) and the change is 0.00 points. The cycle 1 reference figures 93.80 (line) and 88.10 (branch), cited from `evidence/qa-gates/python-coverage-values.2026-10-12T16-45.md`, agree.
- (f) New/changed production code coverage: none (no Python production file changed)
- (g) Disposition: PASS (failed-node count 0; line 93.80 >= 85.00; branch 88.10 >= 75.00; P2-T9 passed)
- (h) Supporting artifacts: `evidence/remediation-baseline/python-diff.2026-10-12T17-20.md` (P0-T5), `evidence/qa-gates/python-coverage-run.2026-10-12T17-20.md` (P2-T7), `evidence/qa-gates/python-coverage-values.2026-10-12T17-20.md` (P2-T8), `evidence/qa-gates/python-diff-final.2026-10-12T17-20.md` (P2-T9). This artifact supersedes the cycle 1 FAIL artifact `evidence/qa-gates/python-coverage.2026-10-12T16-45.md`.
