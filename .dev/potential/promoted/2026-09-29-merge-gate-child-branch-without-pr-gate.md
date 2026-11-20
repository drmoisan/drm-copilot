# merge-gate-child-branch-without-pr-gate (Issue #788)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/merge-gate-child-branch-without-pr-gate/ (Issue #788)
- Related: #690

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #788
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/788
- Last Updated: 2026-09-30
## Summary

The epic merge gate's child branch binds a merge command's pull request number to `pr_gate.pr_number` only when the per-feature checkpoint records that field. Routes that do not set `requires_pr_gate` (for example `small`) record no `pr_gate` object, so for those routes the decision stays unbound and a merge command can be authorized by a checkpoint that belongs to a different item.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a
- Command/flags used: a `gh pr merge` command evaluated by `.claude/hooks/enforce-epic-merge-gate.ps1`
- Data source or fixture: a per-feature checkpoint with no `pr_gate` object; #690 research section 9

## Steps to Reproduce

1. Use a child checkpoint for a route that does not record `pr_gate`.
2. Evaluate a merge command whose pull request number belongs to a different item, with that checkpoint governing the session.
3. Observe the decision.

## Expected Behavior

The child branch binds the command's pull request number for every route, or resolves the child checkpoint by record through `WorktreeRunResolution.psm1`; a mismatched number is denied.

## Actual Behavior

`.claude/hooks/enforce-epic-merge-gate-resolution.ps1:177-185` returns without binding when `pr_gate` or `pr_gate.pr_number` is absent or null; the documented behavior at lines 155-157 is that a checkpoint without `pr_gate.pr_number` keeps the unbound decision. Derived from code reading; not reproduced end to end.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

A merge could be authorized against the wrong item's checkpoint for routes without a PR gate.

## Suspected Cause / Notes

- Routes without a PR gate may not record a pull request number anywhere; the binding source must exist before the deny is tightened.
- A stricter child branch can deny merges that currently succeed; the change needs a migration note for in-flight runs.
- Scope: `enforce-epic-merge-gate.ps1`, `enforce-epic-merge-gate-resolution.ps1`, their bundle mirrors, and the merge-gate Pester suites.

## Proposed Fix / Validation Ideas

- [ ] Bind the command's pull request number for every route, or resolve the child checkpoint by record.
- [ ] Add a test showing a mismatched pull request number is denied for every route.
- [ ] Keep every changed primary file byte-identical to its bundle mirror.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
