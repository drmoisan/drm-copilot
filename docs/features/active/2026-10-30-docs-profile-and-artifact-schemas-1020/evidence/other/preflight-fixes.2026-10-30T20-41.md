# Preflight Fixes - Issue 1020

Timestamp: 2026-10-30T20-41
Plan: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/plan.2026-10-30T16-08.md

## Fixes

1. [P3-T2] | validator-blind literal-formatting defect (porcelain status on an untracked directory) | `git status --porcelain` reports a wholly untracked directory as one collapsed `??` line, so it cannot list the seven staged schemas and `manifest.json` individually while `packages/docs-runtime/` is untracked. Added `--untracked-files=all` to the asserted command. The asserted outcome (the eight staged files are listed) is unchanged.
2. [P5-T4] | validator-blind scan-scope defect | The neutrality scan was parametrized over every file under `packages/docs-runtime/src/`, which includes `__pycache__` bytecode written when earlier test modules import `drm_copilot_docs` during collection; those files are binary and appear only in some runs. Excluded files inside `__pycache__` directories. The asserted property (no configured identifier in the runtime source or the docs schemas) is unchanged.
3. [P6-T9] | validator-blind ordering defect (assertion depends on commit state) | The acceptance required `git status --porcelain -- packages/docs-runtime` to be empty after `--check`, which holds only if every `packages/docs-runtime` file was already committed; no task in the plan commits those files. Replaced it with a before-and-after comparison of `git status --porcelain --untracked-files=all -- packages/docs-runtime` around the `--check` run, both outputs recorded. The asserted property (the `--check` run writes no file) is unchanged.
