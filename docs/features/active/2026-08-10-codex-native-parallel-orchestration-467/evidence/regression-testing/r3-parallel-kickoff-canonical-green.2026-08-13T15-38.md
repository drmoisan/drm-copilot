# R3 Parallel Kickoff Canonical Coverage Green Evidence

Timestamp: `2026-08-13T15-38`

## Focused command

```powershell
poetry run pytest tests/scripts/dev_tools/test_parallel_kickoff_contract.py --cov=scripts.dev_tools.parallel_kickoff_contract --cov-branch --cov-fail-under=100 --cov-report=term-missing
```

- Exit code: `0`.
- Tests: 36 passed, 0 failed, 0 skipped.
- Target module: 109/109 statements covered and 38/38 branches covered.
- Missing lines: none.
- Partial branches: none.
- Total target coverage: 100.000000%.
- Test owner size: 499 lines, within the 500-line limit.
- The focused additions use only in-memory kickoff strings and do not create temporary files, invoke external processes, or add suppressions.

## Canonical comparison

| Counter | Canonical feature-start baseline | Post-change focused result | Disposition |
|---|---:|---:|:---:|
| Lines | 91/91 = 100.000000% | 109/109 = 100.000000% | PASS |
| Branches | 26/26 = 100.000000% | 38/38 = 100.000000% | PASS |

The canonical feature-start baseline and post-change result both equal 100% for line and branch coverage. The current module contains additional validated behavior, so the executable line and branch denominators are larger without reducing the percentage.

## Integrity

- Canonical baseline: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-coverage.2026-08-10T20-25.json`.
- Canonical baseline SHA-256: `8A406402C30108B4A60927993753518E13CE3B1A13D200839A894B1A42881A7A`.
- Acceptance result: `PASS`.
