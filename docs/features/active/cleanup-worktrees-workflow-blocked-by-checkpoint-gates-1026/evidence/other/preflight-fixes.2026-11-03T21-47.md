# Preflight Fixes — Issue #1026, Remediation Cycle 2

Timestamp: 2026-11-03T21-47
Plan: docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/remediation-plan.2026-11-03T21-39.md

## Fix 1 — [P0-T3]

- Defect class: validator-blind literal-formatting defect (search scope).
- Observation: a recursive search of the `tests/` directory also matches three untracked, gitignored `__pycache__/*.pyc` bytecode files of the brief contract modules, so the matching set would exceed the eight files named in DR3 and the task would stop with BLOCKED for files that are not test sources.
- Change made: the search is stated over the tracked files under `tests/`, with untracked `__pycache__` bytecode excluded. The asserted set (the eight DR3 files) is unchanged.

## Fix 2 — [P2-T5]

- Defect class: citation omission whose intent is unambiguous.
- Observation: the plan preamble names `remediation-inputs.2026-11-03T21-39.md` as its input, and the file is untracked at `CYCLE_BASE` and is committed with this cycle's first commit, so it appears in the diff since `CYCLE_BASE`. The "exactly" set omitted it.
- Change made: the changed-set enumeration now names the input file `remediation-inputs.2026-11-03T21-39.md`. The production, hook, and Python constraints of the assertion are unchanged.

## Rule check of the fixes

- Neither fix adds, removes, or reorders a task; both edit task text only.
- Neither fix introduces a line number, a commit identifier, a host path, or wording prohibited by `.claude/rules/tonality.md`.
- Plan validation (repository CLI, `plan` subcommand) exits 0 after the fixes.
