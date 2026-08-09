# Baseline — Python Type Check (Pyright) (P0-T4)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P0-T4]
- **Working directory:** repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)
- **Branch:** `feature/parallel-orchestrator-surface-441`
- **HEAD at capture:** `ee0626e8` (merge of PR #454)

Timestamp: 2026-08-08T16-47

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: Type-check baseline is clean. Pyright reports **0 errors, 0 warnings, 0 informations** under `typeCheckingMode = "strict"` (`[tool.pyright]` in `pyproject.toml`, `pythonVersion = "3.12"`, include set `scripts`, `src`, `tests`). Exit code 0.

Two non-error notices were emitted and are recorded verbatim as pre-existing environment conditions, not findings:

1. `venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69.` — `pyproject.toml` sets `venvPath = "."` and `venv = ".venv"`, which resolves relative to the worktree root. The Poetry virtualenv for this project resides in the main checkout at `C:\Users\DanMoisan\repos\drm-copilot\.venv` (confirmed via `poetry env info --path`), so no `.venv` exists inside the worktree. This is a property of executing from a git worktree and is out of scope for issue #441.
2. `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).` — informational upgrade notice from the pyright launcher; not a type diagnostic.

Neither notice affects the error/warning counts or the exit code.

Raw output:

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
