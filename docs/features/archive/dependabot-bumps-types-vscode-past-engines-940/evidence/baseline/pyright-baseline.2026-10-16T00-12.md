# Pyright baseline (P0-T5)

Timestamp: 2026-10-16T00-12
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations. A first run before dependency installation in the fresh worktree venv reported 4745 errors (unresolved imports such as typer); that was an empty-venv environment gap, not source drift. After `poetry install` (gitignored .venv only) the re-run was clean. The stderr line about a newer pyright version is informational.
