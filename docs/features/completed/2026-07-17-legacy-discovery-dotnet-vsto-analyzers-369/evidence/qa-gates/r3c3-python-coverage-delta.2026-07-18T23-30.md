# r3c3 QA Gate — Python Coverage Delta

Timestamp: 2026-07-18T23-30

Command: Comparison of Phase 0 baseline (`evidence/remediation-baseline/r3c3-phase0-pytest-baseline.2026-07-18T23-30.md`) against Phase 2 post-change (`evidence/qa-gates/r3c3-pytest.2026-07-18T23-30.md`).

EXIT_CODE: 0

## Output Summary

| Metric | Baseline (P0-T6) | Post-change (P2-T5) | Threshold | Result |
|---|---|---|---|---|
| Line coverage | 89.29% | 89.29% | >= 85% | PASS |
| Branch coverage | 87.55% | 87.55% | >= 75% | PASS |
| coverage.py TOTAL (combined) | 87% | 87% | — | unchanged |
| Tests passed | 2065 | 2065 | — | unchanged |
| Tests failed | 0 | 0 | — | unchanged |

- Line coverage >= 85% and branch coverage >= 75% both hold post-change.
- No regression: baseline and post-change coverage are identical. This cycle adds no Python production code (it produces PowerShell coverage evidence only), so no coverage delta is expected.
