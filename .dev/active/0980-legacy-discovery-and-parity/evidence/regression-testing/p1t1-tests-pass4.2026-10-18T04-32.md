# p1t1-tests-pass4

Timestamp: 2026-10-18T04-32
Command: poetry run pytest tests/discovery_runtime tests/scripts/dev_tools/discovery tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py -o addopts=-ra --cov=drm_copilot_discovery --cov=scripts.dev_tools.discovery --cov=scripts.dev_tools.quality_tiers_contract --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t1-coverage.json
EXIT_CODE: 0
Output Summary: ---------------------------------------------------------------------------------------------------------------------------; TOTAL                                                                            1461     19    410     11    98%; Coverage JSON written to file SCRATCH/issue-980-p1t1-coverage.json; ============================= 532 passed in 1.69s =============================

Working directory: .
Started: 2026-10-18T04:32:07.079673+00:00
Duration seconds: 2.991
Phase: P1-T1 package extraction; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 532 items

tests\discovery_runtime\test_package_contract.py ....................... [  4%]
........................................................................ [ 17%]
......................................................                   [ 28%]
tests\scripts\dev_tools\discovery\analyzer\test_cli.py ........          [ 29%]
tests\scripts\dev_tools\discovery\analyzer\test_domain_neutrality.py ... [ 30%]
.....                                                                    [ 31%]
tests\scripts\dev_tools\discovery\analyzer\test_dotnet_inventory.py .... [ 31%]
...............................                                          [ 37%]
tests\scripts\dev_tools\discovery\analyzer\test_emitter.py ........      [ 39%]
tests\scripts\dev_tools\discovery\analyzer\test_inventory.py ........... [ 41%]
........                                                                 [ 42%]
tests\scripts\dev_tools\discovery\analyzer\test_inventory_e2e.py ...     [ 43%]
tests\scripts\dev_tools\discovery\analyzer\test_models.py .......        [ 44%]
tests\scripts\dev_tools\discovery\analyzer\test_pipeline.py ...          [ 45%]
tests\scripts\dev_tools\discovery\analyzer\test_source_text.py ......... [ 46%]
....................................                                     [ 53%]
tests\scripts\dev_tools\discovery\analyzer\test_stack_cli.py ........... [ 55%]
.                                                                        [ 55%]
tests\scripts\dev_tools\discovery\analyzer\test_stack_neutrality.py .... [ 56%]
.........                                                                [ 58%]
tests\scripts\dev_tools\discovery\analyzer\test_vsto_office.py ......... [ 59%]
......................                                                   [ 64%]
tests\scripts\dev_tools\discovery\test_completion_report.py .......      [ 65%]
tests\scripts\dev_tools\discovery\test_coverage_report.py .......        [ 66%]
tests\scripts\dev_tools\discovery\test_domain_neutrality.py ..           [ 67%]
tests\scripts\dev_tools\discovery\test_domain_profile.py ............... [ 69%]
................................                                         [ 75%]
tests\scripts\dev_tools\discovery\test_init_cli.py ..........            [ 77%]
tests\scripts\dev_tools\discovery\test_init_flow.py ............         [ 80%]
tests\scripts\dev_tools\discovery\test_init_models.py ...                [ 80%]
tests\scripts\dev_tools\discovery\test_io.py ....                        [ 81%]
tests\scripts\dev_tools\discovery\test_package_exports.py ..             [ 81%]
tests\scripts\dev_tools\discovery\test_parity_report.py .......          [ 83%]
tests\scripts\dev_tools\discovery\test_profile_cli.py ........           [ 84%]
tests\scripts\dev_tools\discovery\test_rendering.py .....                [ 85%]
tests\scripts\dev_tools\test_quality_tiers_contract.py ................. [ 88%]
...........................                                              [ 93%]
tests\scripts\dev_tools\test_quality_tiers_contract_classification.py .. [ 94%]
..............                                                           [ 96%]
tests\scripts\dev_tools\test_check_quality_tiers.py .................    [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\__init__.py                    4      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\domain_profile.py            190      1     78      1    99%   87
packages\discovery-runtime\src\drm_copilot_discovery\domain_profile_models.py      55      0     14      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\init_models.py                30      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\io.py                         16      0      2      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\rendering.py                  15      0      2      0   100%
scripts\dev_tools\discovery\__init__.py                                             2      0      0      0   100%
scripts\dev_tools\discovery\analyzer\__init__.py                                   11      0      4      0   100%
scripts\dev_tools\discovery\analyzer\__main__.py                                    2      0      0      0   100%
scripts\dev_tools\discovery\analyzer\cli.py                                        47      0      2      0   100%
scripts\dev_tools\discovery\analyzer\dotnet_inventory.py                          126      4     44      4    95%   144, 166, 332, 403
scripts\dev_tools\discovery\analyzer\emitter.py                                    18      0      2      0   100%
scripts\dev_tools\discovery\analyzer\inventory.py                                  68      0     16      0   100%
scripts\dev_tools\discovery\analyzer\models.py                                     52      0      6      0   100%
scripts\dev_tools\discovery\analyzer\pipeline.py                                   42      0      6      0   100%
scripts\dev_tools\discovery\analyzer\source_text.py                               144      0     52      2    99%   82->102, 168->198
scripts\dev_tools\discovery\analyzer\stack_cli.py                                  52      3      2      0    94%   75, 80-81
scripts\dev_tools\discovery\analyzer\vsto_office.py                               134      3     60      4    96%   156->158, 305, 339, 414
scripts\dev_tools\discovery\analyzer\vsto_patterns.py                              16      0      0      0   100%
scripts\dev_tools\discovery\completion_report.py                                   51      4      6      0    93%   124-128, 154-158
scripts\dev_tools\discovery\coverage_report.py                                     40      2      4      0    95%   128-132
scripts\dev_tools\discovery\domain_profile.py                                       2      0      0      0   100%
scripts\dev_tools\discovery\domain_profile_models.py                                2      0      0      0   100%
scripts\dev_tools\discovery\init_cli.py                                            20      0      0      0   100%
scripts\dev_tools\discovery\init_flow.py                                           36      0     22      0   100%
scripts\dev_tools\discovery\init_models.py                                          5      0      0      0   100%
scripts\dev_tools\discovery\io.py                                                   2      0      0      0   100%
scripts\dev_tools\discovery\parity_report.py                                       40      2      4      0    95%   129-133
scripts\dev_tools\discovery\profile_cli.py                                         46      0      6      0   100%
scripts\dev_tools\discovery\rendering.py                                            2      0      0      0   100%
scripts\dev_tools\quality_tiers_contract.py                                       191      0     78      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            1461     19    410     11    98%
Coverage JSON written to file SCRATCH/issue-980-p1t1-coverage.json
============================= 532 passed in 1.69s =============================
```
