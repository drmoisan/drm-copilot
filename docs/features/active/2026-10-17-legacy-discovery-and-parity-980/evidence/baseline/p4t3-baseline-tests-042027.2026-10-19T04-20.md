# P4-T3 baseline tests

Timestamp: 2026-10-19T04-20
Command: `poetry run python -m pytest -q -o addopts= tests/scripts/dev_tools/discovery/analyzer/test_source_text.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py --cov=scripts.dev_tools.discovery.analyzer.source_text --cov=scripts.dev_tools.discovery.analyzer.dotnet_inventory --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t3-baseline-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Exact baseline diagnostics, source bindings and raw command hashes are retained in the adjacent JSON.

```text
........................................................................ [ 46%]
........................................................................ [ 92%]
...........                                                              [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                       Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\analyzer\dotnet_inventory.py     126     12     44      4    89%   144, 166, 332, 403, 425-432
scripts\dev_tools\discovery\analyzer\source_text.py          144      0     52      2    99%   82->102, 168->198
------------------------------------------------------------------------------------------------------
TOTAL                                                        270     12     96      6    95%
Coverage JSON written to file SCRATCH\p4t3-baseline-coverage.raw.json
155 passed in 0.56s

```
