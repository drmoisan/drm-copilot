# Python Coverage Artifact (PA-1)

Timestamp: 2026-10-09T03-58
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json
EXIT_CODE: 0
Output Summary:
- (a) Dispatcher row: `scripts\dev_tools\validate_orchestration_artifacts.py                   149      3     56      4    97%   409, 411, 413, 436->440`
- (b) TOTAL row: `TOTAL                                                                 17557   1110   6338    566    92%`
- (c) Artifact path `artifacts/python/lcov.info`, 496729 bytes.
- (d) Dispatcher line percentage 97.99 (FINAL_FILE_LINE) and branch percentage 92.86 (FINAL_FILE_BRANCH).
- (e) `MISSING_16_TO_19 []`
- (f) Source artifacts in this folder: `pytest-coverage-run.2026-10-09T03-57.md` (P1-T1), `lcov-artifact-presence.2026-10-09T03-58.md` (P1-T2), `python-coverage-values-r1.2026-10-09T03-58.md` (P1-T3).
