# Baseline — Python Type Checking (Pyright) [P0-T18]

Timestamp: 2026-08-20T18-54

Command: `poetry run pyright`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

## Raw Output (tail)

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2b9a9c0d25db8e3b.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

Output Summary: **PASS.** Error count: **0**. Warning count: **0**. Information count: **0**. Exit code 0 was captured directly from the command process (no pipe).

Two non-diagnostic notices accompany the clean result and are recorded for completeness:

1. `venv .venv subdirectory not found in venv path <worktree>` — this worktree has no local `.venv`; the interpreter is resolved through `poetry run` from the main checkout's environment. Pyright still analysed the worktree sources and reported the same clean result at baseline and is expected to do so at P7-T8.
2. A pyright version-availability notice (v1.1.409 installed, v1.1.411 available). This is a tooling-update advisory, not a type diagnostic, and is out of scope for this change.
