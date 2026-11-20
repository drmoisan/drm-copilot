# Preflight Fixes — Agents Branch B Plan (2026-11-14 refresh)

Timestamp: 2026-11-14T19-36
Plan: plan-agents-branch-b.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately; the fixes below are trivial and were applied in place in task text only; no task was added, removed, reordered or checked)

## Fix 1 — [P1-T3] name rule for an agent file without `name:`

- Defect class: literal-formatting (validator-blind); "stem" is ambiguous for a double-suffix file name.
- Finding: four `.github/agents` files carry no `name:` field (`api-architect`, `hlbpa`, `mentor`, `voidbeast-gpt41enhanced`). Read as a path stem, `x.agent.md` gives `x.agent`, which would leave a binding to `x` unresolved.
- Change: "or stem when `name:` is absent" became "or, when `name:` is absent, the file name without its `.agent.md` suffix", matching the Branch A plan. The asserted outcome (zero unresolved bindings) is unchanged.

## Fix 2 — [P2-T2] range of "this plan's commits"

- Defect class: evidence derivation (validator-blind). The main plan and the H3 plan also commit to `LEDGER-RECORDS` on the same branch, so the diff of `MB` and `HEAD` alone cannot show which commits are this plan's.
- Change: the range is stated as the parent of the commit that added the greatest `branch-b-main-plan-check.*.md` to `HEAD`, matching the Branch A plan. The asserted outcome (no ledger change by this plan) is unchanged.

## Fix 3 — [P2-T4] self-review scope

- Defect class: wording aligned with the plan contract (`Final-phase self-review` walks the templates against the branch diff from the merge base) and with the H3 and Branch A plans.
- Change: "against this plan's commits" became "against the branch diff from `MB`, which includes this plan's commits". The asserted outcome (one row per checklist item, no FAIL row, `Plan: plan-agents-branch-b.md`) is unchanged.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan (Poetry, worktree environment), before and after the fixes; MCP `validate_orchestration_artifacts` (`plan`) after the fixes.
- EXIT_CODE: 0
- Output Summary: `plan validation passed` before and after the fixes (102 lines, 13 tasks); MCP result `ok: true`. The pre-fix plan text is kept as `SCRATCH/issue-1032-plan-agents-branch-b.pre-preflight.md`.
