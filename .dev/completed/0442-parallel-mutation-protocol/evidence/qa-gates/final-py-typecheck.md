# Final QA — Python Type Check ([P7-T3])

Timestamp: 2026-08-09T03-37

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

The primary run emits no file count, so the same confirming invocation used at baseline was repeated
to prove the run analyzed the new F6 files rather than reporting a false green over zero files.

Confirming command: `poetry run pyright --stats`

```
Found 388 source files
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Analysis stats
Total files parsed and bound: 640
Total files checked: 388
```

Confirming EXIT_CODE: 0

Baseline checked 374 source files (624 parsed and bound). Post-change checks 388 source files (640
parsed and bound), an increase of 14 files, consistent with the F6 production modules and test
modules added by Phases 2-5. The analyzed set grew, so the zero-error result is substantive.

## Pre-Existing Environment Conditions (unchanged from baseline, out of scope)

- `venv .venv subdirectory not found in venv path ...` — recorded at baseline (P0-T3) as a
  pre-existing worktree condition; informational, not a diagnostic. No configuration change made.
- `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411)` — pinned-version notice
  only; pre-existing and out of scope. No dependency change (confirmed by P7-T10 Check F).

Output Summary: Pyright exit code 0 with **0 errors, 0 warnings, 0 informations** across **388**
checked source files (640 parsed and bound), Pyright 1.1.409. Baseline error count was 0 across 374
files; post-change error count is 0 across 388 files, so there is no type-check regression and the
14 newly analyzed files are type-clean. The two informational messages are the same pre-existing
environment conditions recorded at baseline.

Verdict: PASS (exit code 0, zero errors).
