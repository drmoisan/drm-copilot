Timestamp: 2026-11-04T03-08
Command: poetry run black --check tests/scripts/dev_tools/test_host_environment_contracts.py; poetry run ruff check tests/scripts/dev_tools/test_host_environment_contracts.py; poetry run pyright tests/scripts/dev_tools/test_host_environment_contracts.py; poetry run pytest tests/scripts/dev_tools/test_host_environment_contracts.py tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_clean_devcontainer.py --cov=scripts.dev_tools.clean_devcontainer --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1069-contract-red.json
EXIT_CODE: 1
Output Summary: Formatting/lint/types pass after correcting fixture style. Expected live CI parity mismatch before planned P3-T1:7failed,28passed; unchanged workflow/cleanup contracts pass. Python measured34/36lines94.44%,9/10branches90%. P2-T5 remains unchecked until live pins align; no false completion.

ExpectedExitCode: 1
