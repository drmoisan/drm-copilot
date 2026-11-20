# Defect reproduction (issue #1127)

Timestamp: 2026-11-08T13-11
Command: VIRTUAL_ENV=SCRATCH/issue-1127-fake-main-venv poetry -C <item worktree> env info -p
EXIT_CODE: 0
Output Summary:
- Poetry 2.5.1 printed `SCRATCH/issue-1127-fake-main-venv`, the session venv, although the item worktree's tracked `poetry.toml` sets `[virtualenvs] in-project = true`.
- A `poetry install` under the same environment would therefore write into the session venv, which in the reported sessions is the main checkout's `.venv`.
- The same command with `VIRTUAL_ENV` unset printed nothing (the worktree had no `.venv` yet), confirming that the inherited variable alone selects the foreign environment.

## Legitimate path demonstrated

Command: env -u VIRTUAL_ENV poetry -C <item worktree> install --no-interaction
EXIT_CODE: 0
Output Summary:
- `poetry env info -p` then resolved `<item worktree>/.venv`.
- The worktree `.venv` editable-install `.pth` entries name the item worktree root and its `packages/discovery-runtime/src`.
- The main checkout `.venv` `.pth` entries still name the main checkout root and its `packages/discovery-runtime/src` (unchanged).

Note: the fake session venv was created under `SCRATCH` so that the main checkout's `.venv` was never exposed to the defect during reproduction.
