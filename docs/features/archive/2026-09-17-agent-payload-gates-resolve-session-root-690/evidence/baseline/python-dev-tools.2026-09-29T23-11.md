# Python dev_tools Regression Baseline (P0-T38)

Timestamp: 2026-09-29T23-11
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: 1 failed, 5251 passed, 6 skipped in 24.44s (collected total 5258)
- FAILED lines (baseline failure set):
  - FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
- The only FAILED line is the KL-510 node, which satisfies case (b) (see python-parity.2026-09-29T23-11.md).
