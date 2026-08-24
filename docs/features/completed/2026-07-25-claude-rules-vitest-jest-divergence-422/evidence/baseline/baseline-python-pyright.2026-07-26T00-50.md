# Baseline — Python Type Checking (Pyright) (Issue #422)

Timestamp: 2026-07-26T00-50

Command:
```
poetry run pyright
```

EXIT_CODE: 0

Output Summary:

- Errors: 0
- Warnings: 0
- Informations: 0
- Verbatim result line: `0 errors, 0 warnings, 0 informations`
- Two non-diagnostic notices were emitted and are not type-check findings:
  - `venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a7169cd5d8fee273d.` — the worktree has no local `.venv`; Poetry supplies the interpreter. Pre-existing environment notice, unrelated to this change.
  - A Pyright self-update availability notice (v1.1.409 -> v1.1.411).
- Baseline type-check state: clean.
