# Tier classification after the scripts/ci entry (P2-T6, AC-29)

Timestamp: 2026-10-16T23-45
Command: git add -- scripts/ci/CiChangeScope.psm1 config/ci-docs-only-paths.json quality-tiers.yml
EXIT_CODE: 0
Second command: sh SCRATCH/tools/run-cr.sh cr-quality-tiers
Second EXIT_CODE: 0
Third command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py
Third EXIT_CODE: 0
Output Summary: With scripts/ci/CiChangeScope.psm1 tracked (staged), quality-tiers: OK (25 entries, 25 discovered projects; baseline 24/24); QT-SCRIPTS-CI-ENTRY: True; EXIT_CODE_COMPUTED: 0. pytest: 68 passed, none failed.

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
