# Python type-check baseline — Pyright (Issue #500)

Timestamp: 2026-08-21T22:49:49Z
Issue: #500
Task: [P0-T7]

Command:
```
poetry run pyright
```
(working directory: worktree root)

EXIT_CODE: 0

Output Summary: `0 errors, 0 warnings, 0 informations`. Error count **0**, warning count **0**.
Pyright additionally emitted an advisory notice that a newer Pyright version (v1.1.411) is available
than the pinned v1.1.409; that notice is informational and does not affect the exit code. The
pre-change Python type-check baseline is clean.
