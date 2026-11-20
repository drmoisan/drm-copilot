# poetry.lock Regeneration Resolution (P3-T4) (Issue #393)

Timestamp: 2026-07-21T18-45

Decision: `poetry.lock` is NOT regenerated for this change.

Rationale: The five removed entries are `[tool.poetry.scripts]` console-script entry points
(`shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, and the `dev.shell-qc`
alias). Console-script entry points affect only the built wheel's `entry_points` metadata; they
are not dependencies. `poetry.lock` records the resolved dependency graph, which is unchanged by
removing entry points. Therefore the lock file requires no regeneration.

Verification:
- `grep -n "shell.qc" pyproject.toml` -> no hits (all five entries removed: former lines 50-53
  under `[tool.poetry.scripts]` and the `dev.shell-qc` alias).
- `git status --short poetry.lock` -> clean (no modification).
- Only `[tool.poetry.scripts]` was edited; no `[tool.poetry.dependencies]` or
  `[tool.poetry.group.*.dependencies]` entries were touched.

This resolves the spec Open Question ("confirm during P3 whether `poetry lock` is required"):
it is not required. The build-time effect (a wheel that no longer ships the `shell-qc*` scripts)
is the intended AC4/AC5 outcome and is exercised by the modified `_build-check.yml` (P4-T2).

Output Summary: poetry.lock unmodified; no dependency change; lock regeneration not required.
