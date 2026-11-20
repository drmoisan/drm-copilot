# validate-orchestrator-output-session-relative-read (Issue #787)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/validate-orchestrator-output-session-relative-read/ (Issue #787)
- Related: #690

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #787
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/787
- Last Updated: 2026-09-30
## Summary

`.claude/hooks/validate-orchestrator-output.ps1` runs at SubagentStop and reads its `-CheckpointPath` (default `artifacts/orchestration/orchestrator-state.json`) relative to the session root. #690 moved the PreToolUse gates to locate run checkpoints through `WorktreeRunResolution.psm1`; this hook was out of scope. In the two-worktree topology, where the run checkpoint is in a different worktree from the session root, the hook can read a missing or stale checkpoint.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a
- Command/flags used: SubagentStop for the epic-orchestrator in a session whose root is not the worktree holding the epic checkpoint
- Data source or fixture: #690 research section 3, row 18; `.claude/hooks/validate-orchestrator-output.ps1:32` and `:190`

## Steps to Reproduce

1. Start an epic run so the epic checkpoint lives in worktree A while the session root is worktree B.
2. Let the epic-orchestrator terminate.
3. Observe which checkpoint the SubagentStop hook reads.

## Expected Behavior

The hook resolves the run's checkpoint through `WorktreeRunResolution.psm1`. An unresolved or ambiguous target produces a named failure rather than a read of the session-root copy.

## Actual Behavior

`Get-OrchestratorStateCheckpoint -CheckpointPath` is called with the session-relative default (`validate-orchestrator-output.ps1:190`), and the file does not reference `WorktreeRunResolution` (verified by `grep` on main). A missing or stale session-root checkpoint can block the orchestrator at termination. This was derived from code reading and the #690 research; it was not reproduced end to end.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

- The hook is a SubagentStop completion gate; a change that blocks too broadly can stop every orchestrator run.
- The hook is on the #690 protected list; the change needs its own plan and review.
- Scope: the hook, its bundle mirror, and its Pester suites.

## Proposed Fix / Validation Ideas

- [ ] Resolve the checkpoint through `WorktreeRunResolution.psm1` instead of composing it from the session root.
- [ ] Return a named failure for an unresolved or ambiguous target.
- [ ] Add a test that models the two-worktree topology through the resolver seams without creating files.
- [ ] Keep the primary file byte-identical to its bundle mirror.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
