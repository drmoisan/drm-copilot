# Bundle-Parity Final (Issue #305)

Timestamp: 2026-07-04T13-50

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
EXIT_CODE: 0
Output Summary: 10 passed. All edited/new `.claude/**` runtime sources match their
`extensions/drm-copilot/resources/claude-customizations/.claude/**` mirrors byte-identically, the new
hook is registered in `resources/claude-customizations/pack-manifests/core.json`, and the codex/agents
contracts hold. No codex mirror is required for the new Agent-matcher deterrent hook (consistent with
the existing Agent-matcher hooks absent from `.codex/hooks/`).
