# Python Final Static QC, pass 1 (issue #1165)

Timestamp: 2026-11-10T00-39
Command: env -u VIRTUAL_ENV poetry run black --check <files>; env -u VIRTUAL_ENV poetry run ruff check <files>; env -u VIRTUAL_ENV poetry run pyright <files>; env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (from the item worktree root through sh SCRATCH/issue-1165-pystatic.sh)
EXIT_CODE: 1
Output Summary:
- Files: tests/scripts/dev_tools/test_claude_rules_frontmatter.py, tests/scripts/dev_tools/test_execution_environment_brief_contracts.py, tests/scripts/dev_tools/test_bash_command_shape_surfaces.py
- black --check: exit 0; "3 files would be left unchanged."; findings 0.
- ruff check: exit 1; findings 2 (E501 in test_bash_command_shape_surfaces.py, a docstring Args line and a test docstring).
- pyright: exit 0; "0 errors, 0 warnings, 0 informations"; findings 0.
- generate_codex_agent_variants --check: exit 0; findings 0.
- Outcome: lint failure; both lines were shortened and the loop restarted from the format step (pass 2 is a separate artifact).
