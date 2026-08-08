# Remediation Baseline — Pyright Type Check

Timestamp: 2026-08-08T15-25

Task: [P0-T4]
Working directory: repository root

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: PASS. Pyright reports `0 errors, 0 warnings, 0 informations`. Two non-diagnostic notices are emitted: a venv-subdirectory notice (the worktree has no local `.venv`; the Poetry-managed interpreter is used instead) and a version-availability notice. Neither is a type diagnostic and neither affects the exit code.

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
