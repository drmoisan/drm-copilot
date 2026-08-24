# Python Coverage Delta Verification (Issue #401, AC-11)

Timestamp: 2026-07-22T20-17

Baseline (P0-T10, evidence/baseline/baseline-py-test-coverage.2026-07-22T15-53.md):
- TOTAL: 88% combined (statements 12252, missed 1114, branches 4446, partial 564).
- scripts/dev_tools/potential_to_issue.py: 200 statements, 18 missed, 66 branches, 21 partial, 85% (combined).

Post-change (P5-T8, evidence/qa-gates/final-py-test-coverage.2026-07-22T20-17.md):
- TOTAL: 88% combined (statements 12252, missed 1114, branches 4446, partial 564).
- scripts/dev_tools/potential_to_issue.py: 200 statements, 18 missed, 66 branches, 21 partial, 85% (combined).

Threshold check (changed module scripts/dev_tools/potential_to_issue.py):
- Line coverage = (200 - 18) / 200 = 91% >= 85%. PASS.
- Branch coverage of the overall measured set = (4446 - 564) / 4446 = 87.3% >= 75%. PASS.

No-regression on changed lines:
- The changed module reports the identical statement/branch/miss/partial counts as the baseline (200/18/66/21, 85%). The Defect B branch reorder moved existing decision branches without adding or removing statements, so coverage is unchanged.
- The reordered (bug, minor-audit) path is exercised by the new pytest case in tests/scripts/dev_tools/test_potential_to_issue.py and the updated minor-audit routing assertions; test count rose from 1981 (baseline) to 1982 (post-change).

Verdict: PASS. Thresholds met for the changed module with no coverage regression.
