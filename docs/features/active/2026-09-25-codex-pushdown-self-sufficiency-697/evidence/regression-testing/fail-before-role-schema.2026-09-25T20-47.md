# Fail-Before: Role Schema (Issue #697, AC-1.1/AC-1.5 red)

Timestamp: 2026-09-25T20-47
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_role_schema.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `3 failed, 574 passed`. Failed node IDs (exactly the three expected csharp-legacy variant cases; every other case passed):
- `tests/scripts/dev_tools/test_codex_agent_role_schema.py::test_role_file_top_level_keys_are_allowlisted[.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml]` -- has disallowed keys: ['variant']
- `tests/scripts/dev_tools/test_codex_agent_role_schema.py::test_routed_role_file_declares_model_pins[.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml]` -- lacks model pins: ['model', 'model_reasoning_effort']
- `tests/scripts/dev_tools/test_codex_agent_role_schema.py::test_variant_role_file_matches_canonical_keys_and_pins[.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml]` -- key set differs
