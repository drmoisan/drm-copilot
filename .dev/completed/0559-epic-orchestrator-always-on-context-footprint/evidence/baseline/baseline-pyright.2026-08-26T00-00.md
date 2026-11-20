# Baseline — Pyright Type Check (Issue #559)

Timestamp: 2026-08-25T23-38
Task: [P0-T5]

## Command:

```
poetry run pyright
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Observed Output (complete)

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Numeric Results

| Metric | Baseline value |
|---|---|
| Errors | 0 |
| Warnings | 0 |
| Informations | 0 |
| Exit code | 0 |

## Environment Notes (not defects introduced by this change)

Two non-diagnostic lines appear in the output and are recorded here so a later reader does not
mistake either for a regression:

1. `venv .venv subdirectory not found in venv path ...` — the worktree has no local `.venv`
   directory; the interpreter is supplied by Poetry's own environment. Pyright emits this notice
   and then completes normally. It is a pre-existing environment condition of this worktree, is
   present at baseline, and is not produced by this change.
2. The pyright-version upgrade notice (v1.1.409 available -> v1.1.411) is advisory only. The
   pinned version is not changed by this plan; no dependency change is in this change's declared
   blast radius.

Neither line is a type diagnostic and neither affects the exit code.

Output Summary: PASS. `poetry run pyright` exited 0 at baseline with 0 errors, 0 warnings, and
0 informations. Two advisory environment lines (missing local `.venv` subdirectory, available
pyright upgrade) are pre-existing and non-blocking. Any type diagnostic appearing in a later
phase is attributable to this change.
