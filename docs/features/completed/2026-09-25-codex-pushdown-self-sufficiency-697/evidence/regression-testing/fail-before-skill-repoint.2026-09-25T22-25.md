# Fail-Before: codex-model-routing Skill (Issue #697, AC-4.16 red)

Timestamp: 2026-09-25T22-25
Command: poetry run pytest tests/scripts/dev_tools/test_codex_model_routing_skill.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `6 failed` (all six cases). Failed node IDs:
- `test_skill_contains_no_python_resolver_invocation[repository]`, `[bundle]` -- the skill contains `poetry run python -m scripts.dev_tools.resolve_codex_` (`SKILL.md:19`, `:56`, `:102`).
- `test_skill_instructs_powershell_wrappers[repository]`, `[bundle]` -- the wrapper paths are absent.
- `test_skill_directs_validation_to_mcp_tool[repository]`, `[bundle]` -- the flags are spelled `--require-codex-topology` and `--require-codex-model-routing` with hyphens (`SKILL.md:104-105`), so the underscore literals are absent.
