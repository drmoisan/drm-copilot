# P0-T3 push-down contract baseline

Timestamp: 2026-11-23T07-52
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py under tests/scripts/dev_tools); then env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: pytest 27 passed, 0 failed (pytest -n auto through the launcher, 24 workers). Generator --check exit code 0 with no output. No coverage figure is recorded because no Python production file changes. A worktree .venv was created with env -u VIRTUAL_ENV poetry install after confirming the in-project path resolves inside the worktree.
