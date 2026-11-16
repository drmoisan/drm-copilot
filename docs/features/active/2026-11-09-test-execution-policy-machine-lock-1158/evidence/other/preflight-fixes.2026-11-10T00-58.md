# Preflight Fixes

Timestamp: 2026-11-10T00-58
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

## Fix 1

- Location: `## Execution Constraints (owner brief)`, bullet `Worktree Python environment`
- Defect class: validator-blind (worktree Python environment bootstrap)
- Change: the bullet now states that the one-time `env -u VIRTUAL_ENV poetry install` required by the brief's `## Worktree Python Environment` runs before the first Poetry command (P0-T3). Without it, the first prefixed `poetry run` in the agent worktree creates a nearly empty `.venv` and the P0-T3 baselines cannot run. The asserted values of every task are unchanged.
