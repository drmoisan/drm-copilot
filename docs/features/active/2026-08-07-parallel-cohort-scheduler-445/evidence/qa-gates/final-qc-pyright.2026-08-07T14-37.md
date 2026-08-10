# Final QC — Pyright (Type Check)

- Task: [P2-T3]
- Feature: 2026-08-07-parallel-cohort-scheduler-445 (issue #445)

Timestamp: 2026-08-07T14-37
Command: poetry run pyright
EXIT_CODE: 0

Output Summary:
- `0 errors, 0 warnings, 0 informations` in strict mode (mode configured in `pyproject.toml`).
- Type-check gate: PASS. No type errors introduced by the delivered module or its tests.

Two non-blocking environmental notices were emitted, identical to those recorded in the Phase 0
baseline artifact `evidence/baseline/baseline-pyright.2026-08-07T14-21.md`. They are pre-existing
environment characteristics, not findings introduced by this feature, and neither affects the exit
code:

- `venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a67c9747dbb0e6436.`
  The virtualenv is shared at the repository root; the worktree has no local `.venv` subdirectory.
- `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).`
  A tool-version upgrade notice only. No upgrade was performed.

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a67c9747dbb0e6436.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Delta vs Baseline

| Metric | Baseline ([P0-T4]) | Post-change ([P2-T3]) | Delta |
|---|---|---|---|
| Errors | 0 | 0 | 0 |
| Warnings | 0 | 0 | 0 |
| Informations | 0 | 0 | 0 |
