# Final QC static - Python

Timestamp: 2026-11-18T00-49
Command: sh SCRATCH/issue-1201-py-static-repo.sh final (repository-wide, inside the worktree)
EXIT_CODE: 0
Output Summary:
- Step 1 Black check: `env -u VIRTUAL_ENV poetry run black --check .` EXIT_CODE 0; "1070 files would be left unchanged."; finding count 0; no file changed.
- Step 2 Ruff: `env -u VIRTUAL_ENV poetry run ruff check .` EXIT_CODE 0; "All checks passed!"; finding count 0.
- Step 3 Pyright: `env -u VIRTUAL_ENV poetry run pyright` EXIT_CODE 0; "0 errors, 0 warnings, 0 informations"; finding count 0.
- Contract check: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` EXIT_CODE 0, no output (no drift).
- The only Python change on the branch is one tuple entry in scripts/dev_tools/push_down_claude_customizations.py; no Python module or Python test file was added.
