# Preflight Fixes (single permitted preflight after the 3.11 helper-floor planner round)

Timestamp: 2026-11-04T14-52
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md
Scope: whole plan, single pass, against the branch tree at the plan revision commit for the 3.11 helper floor, and the amended `spec.md` and `user-story.md` (helper floor 3.11, S10/S22 and U10/U22 amended).

## Fixes made in place (task text only; no task added, removed or reordered)

1. `## Execution Context` (first bullet) | stale citation | branch `feature/docs-surface-analyzer-python-native-1031` replaced with `feature/docs-surface-analyzer-python-native-1031-r2`, the branch checked out in the item worktree (`git branch --show-current`).
2. [P6-T19] | internal consistency with the traceability table | the pending-CI exception now names S10, U10, S22 and U22. After the owner amendment, S10 and U10 state that the Python tests pass on the 3.11 floor "verified by the CI matrix (3.11, 3.12 and 3.13)", and the plan's S10/U10 traceability row records them as pending-CI; under the `acceptance-criteria-tracking` skill (`### CI-Dependent Criteria`) such a criterion is not checked off before CI on the PR head. No assertion or test changes.

## Checks with no defect

- Residual `3.10` references: only the spec's decision-history sentence and the P3-T2 below-floor test value `(3, 10, 14)`, both intended.
- `pyproject.toml`: `python = ">=3.11,<4.0"`, `[tool.pyright]` `pythonVersion = "3.12"` (Pre-Mortem `CI-only behavior` bullet accurate).
- `.github/workflows/_quality-checks.yml` matrix is `3.11`, `3.12`, `3.13`; the S10/U10 and S22/U22 rows and the Execution Context Pytest gate name existing check contexts.
- `spec.md` `### Selection and scope` holds the floor statement cited by the Execution Context Python-rules bullet.
- AC counts: `spec.md` 22, `user-story.md` 22, matching the plan header.
- `MERGE_BASE` derivation resolves (`origin/epic/documentation-estate-tooling-integration` exists).
- Branch tree since the prior confirming preflight changed only the three feature documents, so the P0-T4 to P6-T20 citations verified in `preflight-fixes.2026-11-04T14-40.md` remain current.
- Plan validator (branch-current Python CLI, `plan` subcommand) and the MCP validator: pass, before and after the fixes.
