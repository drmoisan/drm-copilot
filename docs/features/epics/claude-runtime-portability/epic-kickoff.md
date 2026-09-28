# Epic Kickoff: claude-runtime-portability

Planned by epic-planner on 2026-08-29T15-07. All child features are prepared: issues promoted,
active folders created, research complete, spec/user-story written, atomic plans approved, preflight
ALL CLEAR. Planning state: `artifacts/orchestration/epic-planner-state.json` (branch:
`epic/claude-runtime-portability-integration`).

## Invocation Prompt

Run `/epic-run claude-runtime-portability` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/claude-runtime-portability/epic.md. The integration branch
epic/claude-runtime-portability-integration already contains every prepared feature folder and
approved atomic plan; child features resume at atomic execution from their committed plan-path
rather than re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator
runs in isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR.

Before any child's Phase 0 runs, apply the two execution preconditions recorded in the
"Execution preconditions" section of this artifact: install node dependencies in each worktree, and
move each child checkpoint out of preparation mode.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 598 | docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598 | 0 | C3 | docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md |
| 596 | docs/features/active/2026-08-29-batch-budget-state-portability-596 | 0 | C3 | docs/features/active/2026-08-29-batch-budget-state-portability-596/plan.2026-08-29T16-05.md |
| 597 | docs/features/active/2026-08-29-caller-site-invocation-correctness-597 | 1 | C2 | docs/features/active/2026-08-29-caller-site-invocation-correctness-597/plan.2026-08-29T16-05.md |
| 599 | docs/features/active/2026-08-29-remove-remaining-python-invocations-599 | 2 | C3 | docs/features/active/2026-08-29-remove-remaining-python-invocations-599/plan.2026-08-29T16-06.md |

## Plan validation

Every plan passed `mcp__drm-copilot__validate_orchestration_artifacts` with
`artifact_type: "plan"`, verified independently by the epic planner after fan-in, not only by the
child that authored it.

## Execution preconditions

These two conditions are not discoverable from the plans themselves and will cause avoidable
failures if skipped.

**1. Install node dependencies in every child worktree before any TypeScript task runs.**
`node_modules` is gitignored, so `git worktree add` never populates it. The `npx` runner does not
fail on a missing local binary: it silently fetches the bare package name from the registry, which
resolves the TypeScript compiler to an unrelated deprecated package. The failure is silent and the
resulting evidence is meaningless. This invalidated 13 of Feature B's plan tasks before it was
caught during preparation. `atomic-executor` holds no node grant and cannot remediate this itself.
It applies to every TypeScript-touching feature, not only Feature B.

**2. Move each child checkpoint out of preparation mode before its Phase 0 baseline runs.**
Feature D's plan records this as its Ordering Constraint 5: Phase 0 baseline commands match the
implementation-command patterns in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`,
so a checkpoint still carrying `route_id: preparation` blocks `[P0-T1]`.

## Open decisions carried into execution

These were raised during preparation and are recorded rather than resolved. None blocks kickoff, but
each has an owner decision behind it.

1. **The mermaid relative-import site is covered by no feature.**
   `.claude/skills/mermaid-diagram/SKILL.md:28` carries
   `Import-Module ./.claude/lib/mermaid/MermaidValidation.psm1 -Force` — the identical defect class
   Feature C fixes, with a bundle mirror at the same line. Feature C's count of three is correct for
   the criteria it enumerates, which are scoped to `BlastRadius.psm1`. Closing the defect class
   requires either an amendment to Feature C or a follow-up issue.

2. **Two Python invocation sites remain by design.** `parallel_drift_detection_cli`
   (`parallel-orchestrate/SKILL.md:817`) and `parallel_mutation_abandon_cli`
   (`parallel-remove/SKILL.md:112`) are both gate-coupled: `enforce-parallel-abandon-gate.ps1`
   matches on the exact tokens of the second invocation, so replacing it without co-designing the
   gate breaks the confirmation contract. The epic's leading indicator was narrowed accordingly.

3. **A permission-grant change was recommended by a child and not adopted.** A subagent
   recommendation is not authorization to change permission scope. It remains an epic-owner
   decision.

4. **`quality-tiers.yml` does not exist.** Four policy documents cite it as the tier source and one
   describes it as CI-enforcing, but no file and no workflow stage implements it. Pre-existing and
   unrelated to this epic; deserves its own issue.

5. **`.claude/agent-memory` is gitignored** (`.gitignore:67`), so per-agent memory written during
   this epic is local to the worktree that wrote it and is lost when that worktree is removed.

## Known process defects surfaced during planning

Recorded because they will recur on the next epic, not because they block this one.

- **`atomic-planner` cannot run the checks its own contract mandates.** Its tools are
  `Read, Grep, Glob, Edit, Write` — no Bash, no MCP — yet `atomic-plan-contract` requires it to run
  a validator gate and to observe a command's success-case output before asserting over that output.
  Its self-review is reading-only by construction, so every defect in that class necessarily reaches
  preflight, where `atomic-executor` does have Bash. This is the single largest contributor to
  preflight round inflation across all four features.
- **The contract's self-review scope is narrower than what preflight tests.** The declaration
  mandates citation re-derivation and sibling re-check, but the defects preflight actually found were
  dominated by unfalsifiable acceptance conditions and task-ordering breaks, which the declaration
  does not name.
- **Three checkbox counters scan whole files with no section anchor and no decoy fixture.** The
  highest-severity one is the `.claude/hooks/validate-executor-output.ps1` completeness gate, which
  blocks agent termination: an unchecked checkbox anywhere in a plan file — including a severity box
  or a Definition-of-Done item — produces a false unchecked-task finding. Measured on this epic's own
  specs, whole-file versus section-scoped counts differ by 4 to 8 items on every one.
