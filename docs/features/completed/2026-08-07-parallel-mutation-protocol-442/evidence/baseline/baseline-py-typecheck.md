# Baseline — Python Type Check (P0-T3)

Timestamp: 2026-08-08T21-28

Task: [P0-T3] Capture Python type-check baseline.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
HEAD at capture time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`

Command: `poetry run pyright`

EXIT_CODE: 0

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3b16f891ab2f782c.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Substantiveness Check (analyzed-file count)

The primary run emits no file count, and a run that analyzed zero files would report
`0 errors` as a false green. A confirming invocation was therefore made to record the
analyzed-file count for this baseline.

Confirming command: `poetry run pyright --stats`

```
Loading pyproject.toml file at c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3b16f891ab2f782c\pyproject.toml
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3b16f891ab2f782c.
Found 374 source files
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Completed in 5.063sec

Analysis stats
Total files parsed and bound: 624
Total files checked: 374
```

Confirming EXIT_CODE: 0

## Pre-Existing Environment Conditions (baseline, out of scope)

- `venv .venv subdirectory not found in venv path ...` — the Poetry virtualenv for this worktree is
  not located at a `.venv` subdirectory of the worktree root, so Pyright's `venvPath`/`venv`
  configuration does not resolve to it. This message is emitted at baseline, before any F6 edit, and
  is a pre-existing environment condition of this worktree. It is informational, not a diagnostic:
  the run still parsed and bound 624 files and checked 374 source files with zero errors. Out of
  scope for this feature; no configuration change is made by this plan.
- `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411)` — pinned-version notice
  only. Pre-existing and out of scope; this plan adds and changes no dependency (verified again by
  P7-T10 Check F).

Output Summary: Pyright exit code 0 with 0 errors, 0 warnings, 0 informations across 374 checked
source files (624 files parsed and bound), Pyright 1.1.409. Baseline type-error count is 0, so the
Phase 2/3 and Phase 7 type-check gates must also report 0 errors. Two pre-existing informational
messages recorded above (worktree venv path not resolving to `.venv`; newer Pyright available); both
are baseline conditions and out of scope.
