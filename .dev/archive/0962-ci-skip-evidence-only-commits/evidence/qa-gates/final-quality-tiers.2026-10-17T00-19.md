# Final QA pass 2: contract stage, tier classification recheck (P6-T9, AC-29)

Timestamp: 2026-10-17T00-19
Command: sh SCRATCH/tools/run-cr.sh cr-quality-tiers
EXIT_CODE: 0
Second command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py
Second EXIT_CODE: 0
Output Summary: On the re-integrated head: quality-tiers: OK (25 entries, 25 discovered projects); QT-SCRIPTS-CI-ENTRY: True; EXIT_CODE_COMPUTED: 0. pytest: 68 passed, none failed.

## cr-quality-tiers output

```
RUN-CR: cr-quality-tiers
QT-OUTPUT: quality-tiers: OK (25 entries, 25 discovered projects)
QT-EXIT: 0
QT-SCRIPTS-CI-ENTRY: True
EXIT_CODE_COMPUTED: 0
```

## pytest output (host path redacted)

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 68 items

tests\scripts\dev_tools\test_quality_tiers_contract_classification.py .. [  2%]
..............                                                           [ 23%]
tests\scripts\dev_tools\test_check_quality_tiers.py .................    [ 48%]
tests\scripts\dev_tools\test_quality_tiers_contract.py ................. [ 73%]
..................                                                       [100%]

============================= 68 passed in 0.22s ==============================
```
