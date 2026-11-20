# Coverage Comparison — Baseline vs Post-Change (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
poetry run pytest --cov --cov-branch --cov-report=term-missing     # baseline P0-T6 and post-change P4-T4
npm run test:coverage                                              # baseline P0-T9 and post-change P4-T8 (extensions/drm-copilot)
```

EXIT_CODE: 0 (all four contributing runs exited 0)

Output Summary:

## Python

| Metric | Baseline (P0-T6) | Post-change (P4-T4) | Delta | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | 92.30% (13288/14396) | 92.30% (13288/14396) | 0.00 | >= 85% | PASS |
| Branch coverage | 84.66% (4475/5286) | 84.66% (4475/5286) | 0.00 | >= 75% | PASS |
| Combined term-missing TOTAL | 90% | 90% | 0 | n/a | no regression |
| Tests passed | 3774 | 3781 | +7 | n/a | seven new tests |

## TypeScript

| Metric | Baseline (P0-T9) | Post-change (P4-T8) | Delta | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| Statements | 96.57% (40958/42412) | 96.57% (40958/42412) | 0.00 | >= 85% | PASS |
| Branches | 89.90% (5822/6476) | 89.90% (5822/6476) | 0.00 | >= 75% | PASS |
| Functions | 90.15% (1191/1321) | 90.15% (1191/1321) | 0.00 | n/a | no regression |
| Lines | 96.57% (40958/42412) | 96.57% (40958/42412) | 0.00 | >= 85% | PASS |
| Tests passed | 2495 | 2495 | 0 | n/a | no TypeScript change |

## Changed-code coverage statement

No Python production file and no TypeScript production file changed in this feature. The production-side change set is four Markdown resource payloads plus `README.md`; Markdown is outside every coverage denominator. The remaining change set is four Python test files, and `tests/**` is excluded from coverage measurement by repository policy (`.claude/rules/general-unit-test.md`). The changed-lines coverage obligation therefore reduces to no regression on the unchanged production totals, which the identical baseline and post-change figures above establish.

All required numeric values are present; no value is a placeholder. Outcome: PASS.
