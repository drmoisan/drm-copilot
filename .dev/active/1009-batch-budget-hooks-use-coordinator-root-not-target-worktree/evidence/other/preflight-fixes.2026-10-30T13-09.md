# Preflight Fixes (issue #1009, preflight round 2)

Timestamp: 2026-10-30T13-09
Plan: docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/plan.2026-10-30T08-09.md

Each fix below edits task text only. No task was added, removed, or reordered, and no file was added to or removed from the `## File Inventory`.

1. [P4-T3] | AC-row completeness (validator-blind; the task already claims AC-22) | The row list covered every clause of AC-22 except "a route-helper import failure denies an in-scope path before any invoker call". The only existing proof, BB2 of `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1`, uses the relative path `src/app.py`, which never reaches the invoker, so it cannot fail when resolution is misordered. Added one row to the existing row list in the same file: with the hook's route-import failure variable set to `enforce-batch-budget-route.ps1` (restored in `finally`), an absolute in-scope path under `/repo/.claude/worktrees/item/src/` is denied with `PYTHON_LARGE_PATH_REQUIRED` naming `enforce-batch-budget-route.ps1` and makes zero invoker, checkpoint, and state calls. [P4-T4] inherits the row through "the rows of [P4-T3]" with `POWERSHELL_LARGE_PATH_REQUIRED`. The spec criterion, file set, and design are unchanged.

Post-fix validation: `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/plan.2026-10-30T08-09.md` reported that plan validation passed.
