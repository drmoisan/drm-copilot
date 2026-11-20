# Python contract tests and Codex generator check

Timestamp: 2026-10-29T13-11
Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check ; poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -p no:cacheprovider --no-cov -q
EXIT_CODE: 0
Output Summary: generator --check exit 0; 91 passed, 0 failed. PINNED_FROZEN_SURFACE_HASHES pins only .claude/agents/epic-orchestrator.md and .claude/skills/epic-orchestrate/SKILL.md; neither edited file (parallel-orchestrate SKILL.md, parallel-orchestrator.md) is pinned, confirmed by reading the constant, and the frozen-surface digest test passed. The same commands were also run before the last two edits (same result).
