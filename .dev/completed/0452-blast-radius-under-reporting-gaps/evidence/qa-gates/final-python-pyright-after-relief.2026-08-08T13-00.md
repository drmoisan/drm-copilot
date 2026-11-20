# Post-relief Python type-check gate ([P11-T15])

Timestamp: 2026-08-08T13-00

Command:
```
poetry run pyright
```

EXIT_CODE: 0

## Output Summary

```
0 errors, 0 warnings, 0 informations
```

Errors: 0. Warnings: 0. Informations: 0.

No `# type: ignore` suppression was added by the relief; the suppression grep
recorded in the [P11-T14] artifact covers both touched files and returns no
match. The new module `scripts/dev_tools/_blast_radius_thresholds.py` carries
`from __future__ import annotations` and imports `Mapping` from
`collections.abc` under `TYPE_CHECKING`, so the relocated signature
`config_over_breadth_fraction(config: Mapping[str, object]) -> float` resolves
without a runtime import and without a suppression.

Two non-error lines appear on stderr and are unrelated to the change set: a
`venv .venv subdirectory not found` notice, which is the pre-existing
worktree-path notice also present in the [P11-T3] baseline run, and a pyright
version-availability notice.

Iteration: 1.
