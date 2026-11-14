# QA Push-Down Contract Tests - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-59
Task: [P3-T7]
Command: `sh SCRATCH/issue-1021-pytest.sh`, which runs (1) `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q` and (2) the same command with `-n auto`
EXIT_CODE: 0
Output Summary: serial run: `34 passed in 1.56s`, exit 0, 0 failed. `-n auto` run: `34 passed in 3.33s`, exit 0, 0 failed. Same passed count in both runs.
