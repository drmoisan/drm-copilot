# Remediation Inputs Read (Remediation Cycle 2)

Timestamp: 2026-10-16T04-08
Task: [P0-T2]

Files read:

1. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-inputs.2026-10-16T03-19.md`
2. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T03-15.md`
3. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T03-15.md`
4. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T03-15.md`

In-scope remediation IDs:

- `N-1` (Low): continuation test, blank-line test, and whitespace normalization use different whitespace classes in the two G10 runtimes; align both on one explicit class `PLAN_WHITESPACE_CLASS`, add frozen fixtures, update the rule file, its bundle copy, and the `spec.md` NFR-2 note.
- `N-2` (Info): the `splitPlanLines` body comment in `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:268-272` names the old Python splitter; reword it to name `split_plan_lines`.
- `U-1` (reclassified as related): `_has_cross_line_presence` in `scripts/dev_tools/plan_gate_discrimination.py:277` uses `str.splitlines`; route it through `split_plan_lines`, add a parity fixture, and confirm no G1-G9 corpus change.

Declined IDs, with reasons:

- `U-2`: jest "Coverage data ... was not found" messages come from pre-existing per-file threshold entries in `extensions/drm-copilot/jest.config.cjs`; that file is not edited because concurrent item #543 also edits it, and the run exits 0.
- `U-3`: the promotion-path prefix in `issue.md` is promotion-tooling output shared by many active `issue.md` files; unrelated to this item.
- `CR-6`: declined in cycle 1 (stale duplicate research file; the run rule forbids deletion).
- `CR-7`: declined in cycle 1 (`it.each` is prohibited by the original plan task `P1-T5`).
