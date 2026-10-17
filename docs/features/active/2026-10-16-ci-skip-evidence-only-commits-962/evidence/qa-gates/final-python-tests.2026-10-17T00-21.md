# Final QA pass 2: Python test stage (P6-T17)

Timestamp: 2026-10-17T00-21
Command: poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE: 0
Output Summary: 80 passed, no FAILED or ERROR line; equals the P0-T17 three-file baseline count (80). No coverage argument is passed (rule 16: only a test file changed). CI job: quality-checks7 / Code Quality & Tests (ubuntu-latest).

## Output (host path redacted)

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 80 items

tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py ...... [  7%]
                                                                         [  7%]
tests\scripts\dev_tools\test_ruff_config_alignment.py ....               [ 12%]
tests\scripts\dev_tools\test_workflow_npm_token_guard.py ............... [ 31%]
.......................................................                  [100%]

============================= 80 passed in 0.24s ==============================
```
