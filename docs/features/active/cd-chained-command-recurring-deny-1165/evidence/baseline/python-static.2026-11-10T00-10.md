# Python Static Baseline (issue #1165)

Timestamp: 2026-11-10T00-10
Command: env -u VIRTUAL_ENV poetry install --no-interaction; env -u VIRTUAL_ENV poetry run black --check <files>; env -u VIRTUAL_ENV poetry run ruff check <files>; env -u VIRTUAL_ENV poetry run pyright <files>; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (run from the item worktree root through a sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary:
- Files: tests/scripts/dev_tools/test_claude_rules_frontmatter.py, tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
- poetry install: exit 0 (worktree .venv created; current project installed).
- black --check: exit 0; "2 files would be left unchanged."; findings 0.
- ruff check: exit 0; "All checks passed!"; findings 0.
- pyright: exit 0; "0 errors, 0 warnings, 0 informations"; findings 0.
- generate_codex_agent_variants --check: exit 0; findings 0.
