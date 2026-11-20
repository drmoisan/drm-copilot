# Final QC — Python type checking — [P8-T3]

Timestamp: 2026-08-26T10-30
Task: [P8-T3]
Command: `poetry run pyright`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: **0 errors**, 0 warnings, 0 informations. The summary line is reproduced verbatim below. Pyright is a read-only analyser, so no file was rewritten and the phase does not restart.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

This is the second pass of Phase 8; the restart and its cause are recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-format-final.2026-08-24T00-00.md`.

## Verbatim summary output

```text
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

The version-availability warning is an advisory from the pyright launcher and is not a diagnostic against any source file. The run also emits a `venv .venv subdirectory not found` notice, which reports that the interpreter is supplied by Poetry rather than by an in-worktree virtual-environment directory; the analysis ran against the Poetry environment and reported a full result.

## Verdict

**PASS.** Exit code 0 and an error count of 0. Phase 8 proceeds to [P8-T4].
