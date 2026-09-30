# merge-gate-child-branch-without-pr-gate (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #690

## Summary

The epic merge gate's child branch binds the command's pull request number to `pr_gate.pr_number` only when the per-feature checkpoint records that value. Routes that do not set `requires_pr_gate`, for example `small`, record no `pr_gate` object. For those routes the child branch keeps the unbound decision it reads at the session root (#690 research section 9), so a merge command can be authorized by a checkpoint that belongs to a different item.

## Scope

- `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and their bundle mirrors.
- The merge-gate Pester suites.

## Acceptance Criteria (early draft)

- [ ] The child branch binds the command's pull request number for every route, or resolves the child checkpoint by record through `WorktreeRunResolution.psm1`.
- [ ] A merge command whose pull request number does not match the governing checkpoint is denied for every route.
- [ ] Every changed primary file is byte-identical to its bundle mirror.

## Constraints & Risks

- Routes without a PR gate may not record a pull request number anywhere; the binding source must exist before the deny is tightened.
- A stricter child branch can deny merges that currently succeed; the change needs a migration note for in-flight runs.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
