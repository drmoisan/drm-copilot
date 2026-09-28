# Baseline — Python Type Check (`pyright`)

Timestamp: 2026-08-30T06-22
Task: [P0-T6]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `poetry run pyright` (run from the worktree root)

EXIT_CODE: 0

Output Summary: Clean. The summary line the run printed, verbatim:

```
0 errors, 0 warnings, 0 informations
```

Zero type errors, which satisfies the uniform `Type errors: 0` gate that
`.claude/rules/quality-tiers.md` applies across T1 through T4.

The run additionally emitted a version-availability notice on stderr, reproduced verbatim:

```
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

This notice concerns the installed tool version and is not a type diagnostic. It does not affect
the exit code and is not counted in the `0 warnings` figure on the summary line, which counts
type-check warnings only. The pinned version in use for this baseline is **v1.1.409**; recording it
here so that a later comparison run can be read against the same analyzer version rather than
attributing a diagnostic delta to this feature's changes.

Pyright is read-only and rewrites no source file.
