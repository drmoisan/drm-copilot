# Python and Jest Regression (P7-T5)

Timestamp: 2026-11-07T17-10
Command: sh SCRATCH/issue-1037-pyfull.sh final (`env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:SCRATCH/issue-1037-pycov-final.json --cov-report=term`, the quality-checks7 shape); sh SCRATCH/issue-1037-jest.sh final (`node run-jest.cjs` in `extensions/drm-copilot/`)
EXIT_CODE: 0
Output Summary: pytest: 16366 passed, 6 skipped, 0 failed, 0 errors in 220.46 s; line coverage 96.84% (34071/35181), branch coverage 93.88% (12528/13344). Jest: 334 suites and 5333 tests passed, 0 failed. No new failure relative to the [P0-T6] baseline.

Owner directive 2026-11-07: parallel test gates only

## Comparison with the [P0-T6] baseline (`evidence/baseline/contract-tests.2026-11-07T16-15.md`)

| Measure | Baseline | Final | Change |
|---|---|---|---|
| pytest passed | 16350 | 16366 | +16 (parametrized contract rows over the new agents, skills and manifests) |
| pytest failed | 0 | 0 | none |
| pytest skipped | 6 | 6 | none |
| Python line coverage | 96.84% | 96.84% | none (no Python production file changed) |
| Python branch coverage | 93.88% | 93.88% | none |
| Jest suites / tests passed | 334 / 5333 | 334 / 5333 | none |
| Jest failed | 0 | 0 | none |

Failures present only in the baseline or only in a single-process run: none; no single-process run was made.
