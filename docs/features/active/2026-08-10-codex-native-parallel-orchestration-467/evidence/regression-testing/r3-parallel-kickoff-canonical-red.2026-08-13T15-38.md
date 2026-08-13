# R3 Parallel Kickoff Canonical Coverage Expected-Red Evidence

Timestamp: 2026-08-13T17-47-04:00
Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_kickoff_contract.py --cov=scripts.dev_tools.parallel_kickoff_contract --cov-branch --cov-fail-under=100 --cov-report=term-missing`
EXIT_CODE: 1
Output Summary: All 35 focused tests passed, but the command failed the required 100% coverage threshold. Current target coverage is 107/109 lines = 98.165138% and 36/38 branches = 94.736842%, compared with the canonical feature-start baseline of 91/91 lines and 26/26 branches = 100%. Missing lines are 409 and 413; missing branches are 408->409 and 412->413.

## Comparison

| Counter | Canonical feature-start baseline | Current focused state | Deficit |
|---|---:|---:|---|
| Lines | 91/91 = 100.000000% | 107/109 = 98.165138% | Lines 409 and 413 |
| Branches | 26/26 = 100.000000% | 36/38 = 94.736842% | 408->409 and 412->413 |

- Focused tests: 35 passed, 0 failed.
- Coverage.py combined total: 97.28%, below `--cov-fail-under=100`.
- Canonical baseline: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-coverage.2026-08-10T20-25.json`
- Canonical baseline SHA-256: `8A406402C30108B4A60927993753518E13CE3B1A13D200839A894B1A42881A7A`
- Current numeric branch details: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/python-coverage.2026-08-13T15-38.json`

Acceptance result: PASS for `[expect-fail]`; the isolated command failed only the named 100% coverage requirement and preserved the exact canonical regression.
