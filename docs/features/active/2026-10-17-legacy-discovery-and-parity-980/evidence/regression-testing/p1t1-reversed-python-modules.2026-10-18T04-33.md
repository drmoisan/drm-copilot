# p1t1-reversed-python-modules

Timestamp: 2026-10-18T04-33
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/discovery/test_rendering.py tests/scripts/dev_tools/discovery/test_io.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_profile.py tests/discovery_runtime/test_package_contract.py -o addopts=-ra --no-cov
EXIT_CODE: 0
Output Summary: ........................................................................ [ 79%]; ......................................................                   [100%]; ; ============================= 268 passed in 0.35s =============================

Working directory: .
Started: 2026-10-18T04:33:05.709939+00:00
Duration seconds: 1.453
Phase: P1-T1 package extraction; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 268 items

tests\scripts\dev_tools\test_quality_tiers_contract_classification.py .. [  0%]
..............                                                           [  5%]
tests\scripts\dev_tools\test_quality_tiers_contract.py ................. [ 12%]
...........................                                              [ 22%]
tests\scripts\dev_tools\discovery\test_rendering.py .....                [ 24%]
tests\scripts\dev_tools\discovery\test_io.py ....                        [ 25%]
tests\scripts\dev_tools\discovery\test_init_models.py ...                [ 26%]
tests\scripts\dev_tools\discovery\test_domain_profile.py ............... [ 32%]
................................                                         [ 44%]
tests\discovery_runtime\test_package_contract.py ....................... [ 52%]
........................................................................ [ 79%]
......................................................                   [100%]

============================= 268 passed in 0.35s =============================
```
