# Preflight Fixes — Agents Branch A Plan (2026-11-14 refresh)

Timestamp: 2026-11-14T19-29
Plan: plan-agents-branch-a.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately; the fixes below are trivial and were applied in place in task text only)

## Fix 1 — [P1-T3] stem rule for an agent file without `name:`

- Defect class: literal-formatting (validator-blind); the meaning of "stem" was ambiguous for a double-suffix file name.
- Finding: four `.github/agents` files have no `name:` field (`api-architect`, `hlbpa`, `mentor`, `voidbeast-gpt41enhanced`). The stem of `x.agent.md` read as a path stem is `x.agent`, which would leave a binding to `x` unresolved.
- Change: the task now states "the file name without its `.agent.md` suffix". The asserted outcome (zero unresolved bindings) is unchanged.

## Fix 2 — [P1-T4] collision-name derivation

- Defect class: evidence derivation (validator-blind; the executor must not select the evidence it is judged against).
- Finding: the task asked for "the names colliding with `.claude/agents`" without the comparison rule.
- Change: the task now states the rule: a `.github/agents` file collides when its `name:` (quotes removed), or else its file name without `.agent.md`, equals the `name:` of a `.claude/agents/*.md` file. The four docs roles stay named. The asserted outcome (the collision list in the outcome record) is unchanged.

## Fix 3 — [P2-T2] range of "this plan's commits"

- Defect class: evidence derivation (validator-blind). The main plan and the H3 plan also commit to `LEDGER-RECORDS`, so the diff of `MB` and `HEAD` alone cannot show which commits are this plan's.
- Change: the range is stated as the parent of the commit that added the greatest `branch-a-main-plan-check.*.md` to `HEAD`. The asserted outcome (no ledger change by this plan) is unchanged.

## Fix 4 — [P2-T4] self-review scope

- Defect class: wording aligned with the plan contract (`### Final-phase self-review` requires the walk against the branch diff from the merge base) and with the H3 plan's self-review task.
- Change: "against this plan's commits" became "against the branch diff from `MB`, which includes this plan's commits". The asserted outcome (one row per checklist item, no FAIL row, `Plan: plan-agents-branch-a.md`) is unchanged.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan (Poetry, worktree environment), before and after the fixes; MCP `validate_orchestration_artifacts` (`plan`) after the fixes.
- EXIT_CODE: 0
- Output Summary: `plan validation passed` before and after the fixes; MCP result recorded in the preflight return.
