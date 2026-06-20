# Baseline — Bundle-Mirror Contract Test (Issue #207, Remediation Pass 1)

Timestamp: 2026-06-19T19-15

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py

EXIT_CODE: 1

Output Summary:
- 1 failed, 3 passed in 0.09s.
- Failing test: test_bundled_claude_payload_contains_all_repo_runtime_contracts.
- AssertionError: Repo file missing from bundle: .claude\hooks\enforce-completion-consistency.ps1.
- This is the fail-before evidence for the remediation. The bundled extension payload at
  extensions/drm-copilot/resources/claude-customizations/.claude/ does not contain the
  new hook file present in the repo .claude tree, violating the byte-identical mirror contract.
