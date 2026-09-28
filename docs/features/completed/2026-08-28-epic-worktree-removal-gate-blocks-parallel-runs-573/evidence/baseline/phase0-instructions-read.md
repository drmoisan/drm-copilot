# Phase 0 — Policy Instructions Read (P0-T1)

Timestamp: 2026-08-28T11-36

Task: [P0-T1]
Issue: #573
Work Mode: `full-bug`
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84`

Policy Order: the seven files below were read in this exact order, as mandated by the plan task [P0-T1] and by `.claude/skills/policy-compliance-order/SKILL.md`.

## Files read (in order)

1. `CLAUDE.md` — standing instructions: tone policy, policy-compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design priority order (simplicity, reusability, extensibility, separation of concerns), the mandatory seven-stage toolchain loop, the 500-line file limit, error-handling and naming rules, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: the five core test properties, the uniform >= 85% line-coverage requirement, the Coverage Exclusion Policy, the prohibition on temporary files in tests, the `tests/` mirror-layout requirement.
4. `.claude/rules/powershell.md` — PowerShell toolchain (format -> analyze -> test; no type-check stage), PowerShell 7+ compatibility, coding standards, change budget (<= 3 production and 3 test files per batch), design-seam and mocking rules, deterministic-test requirements, the Pester branch-coverage exemption.
5. `.claude/rules/quality-tiers.md` — T1-T4 tier system, the uniform-versus-tier-dependent gate matrix, line coverage >= 85% uniform across tiers, PowerShell exempt from the branch-coverage threshold.
6. `.claude/rules/plan-acceptance-gates.md` — acceptance-gate rules G1 through G9, the write-mode register, the checkable-literal placeholder guard, the deliberately uncovered sub-classes (including the task-ordering class).
7. `.claude/rules/parallel-orchestration.md` — parallel-surface artifact invariants (orchestrator 1-21, planner P1-P9, manifest M1-M8), the Cache Doctrine, the enum-ownership table, the blast-radius contention doctrine, and the `## Enforcement` section this plan amends in [P4-T4].

## Constraints carried forward into execution

- Do not modify policy documents under `.github/instructions/`. The single `.claude/rules/` edit performed by this plan (`.claude/rules/parallel-orchestration.md`, [P4-T4]) is authorized by the spec's "Policy resolution" section and is scope-limited to appending one `## Enforcement` bullet.
- PowerShell toolchain order is format -> analyze -> test; type checking is not applicable and is recorded explicitly rather than omitted ([P5-T3]).
- Line coverage >= 85% applies to the changed hook; no branch-coverage gate applies to Pester.
- The 500-line file limit applies to the hook and to the Pester suite.
- Temporary files in tests are prohibited outright; every checkpoint fixture is a literal JSON string through a mocked read seam.
- Evidence paths are non-overridable and resolve to `<FEATURE>/evidence/<kind>/`. No `artifacts/` evidence sub-path is used.

EXIT_CODE: 0

Output Summary: All seven mandated policy files were read in the stated order from the execution worktree. No policy conflict with the approved plan was identified. The one `.claude/rules/` write scheduled by the plan is pre-authorized by the spec with a recorded four-point justification and a scope limit; it is the only policy-file write in scope.
