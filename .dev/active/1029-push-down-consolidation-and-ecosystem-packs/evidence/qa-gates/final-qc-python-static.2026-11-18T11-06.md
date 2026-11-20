# Final QC: Python Static Checks (P5-T1)

Timestamp: 2026-11-18T11-06
Command: env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py; env -u VIRTUAL_ENV poetry run ruff check <same file>; env -u VIRTUAL_ENV poetry run pyright <same file>; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: Black `1 file would be left unchanged.`, Ruff `All checks passed!`, Pyright `0 errors, 0 warnings, 0 informations`, Codex generator `--check` exit 0 with no drift. The only Python file this plan changes is the test above; no Python production file changed.

| Step | Command | Exit code | Finding count |
| --- | --- | --- | --- |
| Format | `poetry run black --check <file>` | 0 | 0 (`1 file would be left unchanged.`) |
| Lint | `poetry run ruff check <file>` | 0 | 0 (`All checks passed!`) |
| Type check | `poetry run pyright <file>` | 0 | 0 |
| Codex generator check | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | 0 |
