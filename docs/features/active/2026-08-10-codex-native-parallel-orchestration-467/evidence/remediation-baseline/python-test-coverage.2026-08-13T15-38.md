# Python Remediation Baseline - Tests and Coverage

Timestamp: 2026-08-13T17-39-04:00
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/python-coverage.2026-08-13T15-38.json`
EXIT_CODE: 0
Output Summary: Pytest collected 3,968 tests and completed with 3,963 passed and 5 skipped in 17.49 seconds. Repository line coverage was 14,348/15,525 = 92.418680%, and branch coverage was 4,892/5,772 = 84.753985%. `scripts/dev_tools/parallel_kickoff_contract.py` line coverage was 107/109 = 98.165138%, and branch coverage was 36/38 = 94.736842%; missing lines were 409 and 413, with missing branches 408->409 and 412->413.

## Repository coverage

- Lines: 14,348/15,525 = 92.418680% (PASS >=85%)
- Branches: 4,892/5,772 = 84.753985% (PASS >=75%)
- Missing lines: 1,177
- Missing branches: 880
- Partial branches: 622

## Target owner coverage

- Owner: `scripts/dev_tools/parallel_kickoff_contract.py`
- Lines: 107/109 = 98.165138%
- Branches: 36/38 = 94.736842%
- Missing lines: 409, 413
- Missing branches: 408->409, 412->413

## Artifact integrity

- JSON: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/python-coverage.2026-08-13T15-38.json`
- SHA-256: `191DAE36C8FC1E575032967BD17337D110D90E38D91C26D9AAEB1FE608F62C4B`
