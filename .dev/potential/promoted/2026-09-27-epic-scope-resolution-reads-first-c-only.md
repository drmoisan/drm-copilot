# epic-scope-resolution-reads-first-c-only (Issue #738)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-scope-resolution-reads-first-c-only/ (Issue #738)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #738
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/738
- Last Updated: 2026-09-27
## Summary

On both the Claude and Codex surfaces, the epic-scope target resolution introduced by #663 and ported by #707 reads only the first `git -C <path>` of the first command segment. During an epic merge, a command can therefore act on a worktree other than the one whose readiness was checked.

## Environment

- OS/version: any
- Python version: n/a (PowerShell)
- Command/flags used: epic-scope staging commands during a merge (MERGE_HEAD present)
- Data source or fixture: #707 code review CR-1 (`code-review.2026-09-27T07-56.md`)

## Steps to Reproduce

1. Issue `git -C <checked-worktree> status && git -C <other-worktree> add <prod file>`, or repeat `-C`, or use a path into another worktree, or (on Codex) a different `workdir`.
2. Resolution checks only the first `-C` target; the later segment runs against another worktree.

## Expected Behavior

Every command segment's effective target is resolved, and each must satisfy the readiness conditions, or the command fails closed.

## Actual Behavior

Only the first `-C` of the first segment is resolved. The reviewer judged this not a new bypass, because the checked worktree still meets every readiness condition, but it is a scope-precision gap.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #707 CR-1; CR-2 and CR-4 (no gate-level test with a relative or unresolvable `-C` path).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The resolution takes the first match for simplicity. Fix both surfaces together, keeping the byte-identical helpers in sync.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: resolve every segment's target (including repeated `-C` and Codex `workdir`); fail closed on unresolvable or relative paths; add gate-level tests for those cases; add Arrange/Act/Assert labels and `-Because` clauses to the new gate-5 suite (CR-4).
- [ ] Integration scenario to retest: an epic main-sync through gates 4 and 5 on both surfaces.
- [ ] Manual verification notes: optional manual Codex epic main-sync (#707 follow-up 2).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
