# Claude Bundle Contracts After Phase 3 (P3-T9)

Timestamp: 2026-09-29T19-45
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 13 passed in 0.23s
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". Every other node PASSED.
Preceding mirror step (P3-T8): `cp .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`; A13 `PAIR-SUMMARY pairs=1 unequal=0`.
