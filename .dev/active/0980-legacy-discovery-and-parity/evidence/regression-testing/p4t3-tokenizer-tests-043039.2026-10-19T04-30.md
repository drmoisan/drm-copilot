# P4-T3 tokenizer tests

Timestamp: 2026-10-19T04-30
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_csharp_tokens.py --cov=drm_copilot_discovery.analyzer.csharp_tokens --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t3-tokenizer-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
..........................................................               [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                             Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_tokens.py      98      1     48      1    99%   149
----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                               98      1     48      1    99%
Coverage JSON written to file SCRATCH\p4t3-tokenizer-coverage.raw.json
58 passed in 0.17s

```
