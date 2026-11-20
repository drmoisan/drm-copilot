# completion-stop-hook-traps-session-after-rejected-parallel-mutation (Issue #1012)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/completion-stop-hook-traps-session-after-rejected-parallel-mutation/ (Issue #1012)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1012
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1012
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

The completion stop hook traps a session after a parallel mutation is rejected before any run checkpoint exists. The skill correctly stops without writing state, but the hook then demands a valid parallel checkpoint, so the agent cannot finish. One of four sibling bugs (this one is independent of the target-worktree resolver).

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `/parallel-run <slug>`, `/parallel-add`, `/parallel-close`, `/parallel-remove`
- Data source or fixture: hook `validate-orchestrator-output.ps1` as SubagentStop/Stop for `parallel-orchestrator` and the forked `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` skills

## Steps to Reproduce

1. Invoke `/parallel-run <slug>` from a checkout where the committed kickoff artifact is absent (the planner branch is not checked out), or invoke `/parallel-add` before the run's execution checkpoint exists.
2. The skill stops without delegating or writing state, as its procedure requires.
3. Try to end the session.

## Expected Behavior

When no run checkpoint exists AND the agent's output carries a structured rejection signal, the stop is allowed without checkpoint validation.

- Signal: a final line `PARALLEL_MUTATION_REJECTED: <reason-code>`, with a closed reason enum defined once in `.claude/rules/parallel-orchestration.md`: `kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, `unknown_item`.
- Free text is not matched.
- A rejection signal while a checkpoint exists, or any path that wrote state, validates fully as today.
- The four skills emit the signal on each documented STOP path and consume the enum without redefining it.

## Actual Behavior

The stop hook requires a valid parallel checkpoint for a known run, finds none, and blocks every stop. The agent cannot finish without fabricating a checkpoint, and the session must be killed from outside.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none recorded

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`validate-orchestrator-output.ps1` has no path for a legitimate no-state stop on a parallel skill.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: each reason with no checkpoint → allow; the signal with a checkpoint present → normal validation; no signal and no checkpoint → block, as today.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity: update `.claude/rules/parallel-orchestration.md` (the rejection enum), mirrored and bundled copies, and Codex counterparts where the hook is carried. Contract tests, pack-manifest completeness, and no Python in hooks.

Out of scope: no relaxation of validation when a checkpoint exists or state was written; no change to worktree-isolation behavior or checkpoint schemas.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
