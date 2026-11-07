# Phase 0 Instructions Read: Remediation Cycle 2 (Issue #1096)

Timestamp: 2026-11-07T17-45
Command: read of the merged policy, skill, and cycle files at the P0-T1 merge commit; git -C <item worktree> branch --show-current
EXIT_CODE: 0
Output Summary: all files below were read from the merged tree; the policy rule files and instruction files are unchanged by the merge; the merged `atomic-plan-contract` and `execution-environment` differ from this plan's wording in four places, each mapped below; branch is `feature/pester-static-leak-scan-1096`.
Policy Order: CLAUDE.md, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then the language rules `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, per `policy-compliance-order`.

## Files read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md` (applicability only; no `quality-tiers.yml` at the root)
5. `.claude/rules/powershell.md`
6. `.claude/rules/python.md`
7. `.claude/rules/python-suppressions.md`
8. `.claude/rules/plan-acceptance-gates.md`
9. `.claude/skills/atomic-plan-contract/SKILL.md` (merged, PR #1110 text)
10. `.claude/skills/execution-environment/SKILL.md` (merged, both sides)
11. `<FEATURE>/remediation-inputs.2026-11-07T17-35.md`
12. `<FEATURE>/remediation-plan.2026-11-07T17-35.md`

The merge changed no file under `.claude/rules/` or `.github/instructions/`, and no `CLAUDE.md` or `.github/copilot-instructions.md`.

## Merged rules that differ from this plan's wording

| Merged rule | Source | Rule this plan follows |
|---|---|---|
| Phase 0 carries no routine policy-read task; a plan that keeps one stays valid. | `atomic-plan-contract` `## Phase 0 Requirements` | P0-T2 runs as written; the read is recorded here. |
| Phase 0 captures one `Phase 0 baseline` run of each parallel test gate, and final gates compare with it. | `atomic-plan-contract` `## Phase 0 Requirements`, `## Coverage Evidence Contract`; brief `## Coverage and File-Size Gates` | Under `Merged customization files`, the Decision 9 record under `<FEATURE>/evidence/baseline/` (`pester-parallel.*.md`, `pytest-parallel.*.md`) is this item's pre-change baseline; AC-34 and AC-35 compare against it in P2-T5; this cycle runs no additional baseline suite. |
| A change that reduces evidence, plan tasks, gates, or review process adds its ledger entry in the same commit. | `atomic-plan-contract` `## Process-Reduction Ledger` | This item's reduction is recorded in entry 0001; only P1-T2 may change its serial-command wording, with the `reduction: 0001` token. |
| Light cycles have no plan and no preflight. | `atomic-plan-contract` light-cycle paragraph | Not applicable: this cycle is `Remediation-Mode: proportionate`, so preflight ran and the plan is executed as written. |

No `atomic-plan-contract` copy is edited by this cycle.
