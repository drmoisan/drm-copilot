Timestamp: 2026-11-05T06-51
Command: poetry run black --check tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; poetry run ruff check tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; poetry run pyright tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; poetry run pytest tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q --no-cov

EXIT_CODE: 0
Gate: poetry run black --check tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
GateExit: 0
All done! \u2728 \U0001f370 \u2728
2 files would be left unchanged.

Gate: poetry run ruff check tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
GateExit: 0
All checks passed!

Gate: poetry run pyright tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
GateExit: 0
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


Gate: poetry run pytest tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q --no-cov
GateExit: 0
.......................................................                  [100%]
55 passed in 0.17s
