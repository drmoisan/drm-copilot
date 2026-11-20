# Epic Kickoff: orchestrator-state-contract-correctness

Planned by epic-planner on 2026-09-29T22:45:00Z. All child features are prepared: issues
exist (pre-existing child issues; epic issue #771 promoted), active folders created, research
complete, spec written, atomic plans approved, preflight ALL CLEAR. Planning state:
artifacts/orchestration/epic-planner-state.json (branch:
epic/orchestrator-state-contract-correctness-integration).

epic_issue_num: 771

## Invocation Prompt

Run `/epic-run orchestrator-state-contract-correctness` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at docs/features/epics/orchestrator-state-contract-correctness/epic.md.
The integration branch epic/orchestrator-state-contract-correctness-integration already contains
every prepared feature folder and approved atomic plan.
Every child resumes at atomic execution from its committed plan-path rather than re-planning.
Execute per the
epic-orchestrate skill: wave-scheduled child orchestrator runs in isolated worktrees,
merge-on-green fan-in to the integration branch, and the final integration-to-main PR.
The epic issue is #771; copy it into epic_issue_num at the first epic checkpoint write.
Read the Prerequisites and Execution Amendments sections of this artifact before launching
wave 0; EA-1 through EA-5 are binding on named children.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 405 | docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405 | 0 | C2 | docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/plan.2026-09-29T14-19.md |
| 464 | docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464 | 0 | C2 | docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md |
| 509 | docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509 | 1 | C3 | docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md |
| 523 | docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523 | 1 | C3 | docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/plan.2026-09-29T15-52.md |
| 484 | docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484 | 2 | C4 | docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/plan.2026-09-29T17-35.md |

## Integrity

planning_commit: c8a72ec2ed275ac8009812e28b28dd107e71076e

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/plan.2026-09-29T14-19.md | b2a50dd31b06443f743a97d6ac2cd6ed8b3e4f1f |
| docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/plan.2026-09-29T14-20.md | eabf21e57a946060c28f92e0403cc16a12be6439 |
| docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md | af76fd4e0b802d57e4a4c0311b83d005fb705504 |
| docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/plan.2026-09-29T15-52.md | 24fe304db858a48369cd202d8761b7d59767fcb1 |
| docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/plan.2026-09-29T17-35.md | 60dfb5b6b856909629ebcde6f3b42e75aa84d148 |

## Execution Order

Waves were computed by longest-path layering with `scripts/dev_tools/epic_wave_computation.py`
(`405: 0, 464: 0, 509: 1, 523: 1, 484: 2`). The graph is acyclic and every `depends_on` entry
resolves.

| wave | features | width |
| --- | --- | --- |
| 0 | 405, 464 | 2 |
| 1 | 509 (after 405), 523 (after 464) | 2 |
| 2 | 484 (after 523) | 1 |

## Prerequisites

**P-0 — Re-verify each plan hash before launching its child.** Recompute with
`git hash-object <plan-path>` and compare against the Integrity table above.

**P-1 — Policy-file edits need an explicit user decision.** The plans for #464, #509, #523, and
#484 edit `.claude/rules/orchestrator-state.md` (and its bundled mirror), which the repository's
hard constraints normally forbid. Every edit is additive or corrects wording that the new checks
make inaccurate, and each spec places it in scope. Obtain the user's confirmation before wave 0
launches, or have the affected plans revised to drop those tasks.

**P-2 — Child issues pre-exist.** No child ran `potential_to_issue`; each recorded the substitution
under `human_interaction.requirements[]` citing #509. Children that execute after #509 has merged
into the integration branch (only #484) should record the new `issue_adoption` checkpoint object
that #509 introduces instead.

## Execution Amendments

**EA-1 (#509) — PowerShell handoffs.** The atomic-executor has no PowerShell tool and the worktree
guard refuses `pwsh`. The #509 child orchestrator must itself run the PowerShell baseline and
final coverage runs at plan handoff points H0 and H1 (fallback: dispatch the `_poshqc.yml` CI
workflow), and after execution must create the two follow-up potential entries the plan names
with `new_potential_entry`.

**EA-2 (#509) — Upstream gate.** Plan task P0-T4 stops with a BLOCKED signal unless #405 has
merged into the integration branch. The wave barrier guarantees this; do not launch #509 early.

**EA-3 (#509, #523) — Expected fan-in overlap.** Both wave-1 children edit
`.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/rules/orchestrator-state.md`,
`.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md` (each with its bundled
copy), and `extensions/drm-copilot/jest.config.cjs`. No function is edited by both. The second of
the two to merge should expect text conflicts and resolve them through the standard R1-R5
merge-conflict loop.

**EA-4 (#484) — Upstream representation.** #484 records its non-remediable halt classes through
the `blocked_reason` members #523 adds (`premise_falsified`, `external_dependency`,
`policy_hold`, `awaiting_ci`, `human_decision_required`) and assumes the #464 module layout
(`_orchestrator_state_remediation_loop.py`). Both must be merged before #484 launches.

**EA-5 (all) — Out-of-scope files.** Issue #769 files (`.claude/hooks/enforce-powershell-batch-budget.ps1`
and related tests) are orchestrated in another session and must not be touched. Enforcement hooks
must not gain Python legs.
