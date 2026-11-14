# Preflight Fixes (round 2)

Timestamp: 2026-11-09T22-36
Plan: docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-09-hook-session-root-resolution-1163/plan.2026-11-09T16-33.md
EXIT_CODE: 0
Output Summary: The branch-current plan validator passed before and after the fixes below. Task count and task order are unchanged. One substantive defect is returned to the planner and is not fixed here.

## Fixes

1. [P1-T1] | validator-blind class: an existing guard asserts on suites outside the task text | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` ('AC-4 <Path> complies with the baseline isolation form for every closure seam') enumerates every suite under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`. The completion-consistency hooks define the read seam `Get-CheckpointFileContent`, and every sibling suite mocks it to `$null` in its outermost `BeforeAll`. The task now states that both new suites do the same. No asserted decision changes.
2. [P1-T4] | unclassified fail-before rows | the two docs-role rows where the identity is unresolved (the branch names no worktree, or is registered twice) fail against the unmodified hook, because the hook calls the throwing probe. They are now marked "(each fails before)", so [P2-T1] lists them. Before this fix they were in neither of its lists.
3. [P1-T4] | validator-blind class: guard requirement on a new suite | in [P5-T4] the docs-role hook dot-sources `subagentstop-target-worktree.ps1`, which imports `WorktreeItemResolution.psm1` and its named seams `Get-WorktreeItemCheckpointText` and `Get-WorktreeItemLiveRoot`. The new docs-role TargetWorktree suite now registers `Register-EpicStateBaselineMock` for both seams and carries a 'baseline mock interception probe' row, as required by guard rows 'AC-4' and 'AC-6'. That helper imports the module itself, so the fail-before run in [P2-T1] is unaffected.
4. [P5-T4] | wrong disposition for an existing test that the change affects (validator-blind class) | `tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1` was marked unchanged. The hook's new closure makes the guard's 'AC-4' and 'AC-6' rows fail for that suite unless it adds the same baseline mock and probe row. The disposition now says the suite is updated for that reason only, with every asserted decision kept. `docs-role-contract.Tests.ps1` stays unchanged because it loads only `docs-role-contract.ps1`.
