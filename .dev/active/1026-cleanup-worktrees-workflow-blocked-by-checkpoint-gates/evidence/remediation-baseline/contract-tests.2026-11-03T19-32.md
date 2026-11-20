# Remediation Baseline — Contract Tests and Generator Check

Timestamp: 2026-11-03T19-32
Command: sh SCRATCH/issue-1026-contracts.sh baseline (poetry run pytest -q --no-cov over tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_push_down_issue_824_follow_ups.py, test_execution_environment_brief_contracts.py, test_discovery_documentation_contracts.py, test_single_pass_preflight_contracts.py, test_completion_gate_documentation_contracts.py; then poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0

- pytest: 220 passed, 0 failed (exit 0).
- generator `--check`: exit 0, no drift reported.

Output Summary: 220 passed, 0 failed; pytest exit 0; generator exit 0.
