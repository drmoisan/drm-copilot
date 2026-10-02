# validate-orchestrator-output-session-relative-read (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #690

## Summary

`.claude/hooks/validate-orchestrator-output.ps1` runs at SubagentStop and reads `-CheckpointPath` relative to the session root (#690 research section 3, row 18). #690 changed the PreToolUse gates to locate run checkpoints through `WorktreeRunResolution.psm1`, but this hook was out of scope. In the two-worktree topology, where the epic checkpoint lives in a different worktree from the session root, the hook can read a missing or stale checkpoint and block the epic-orchestrator when it terminates.

## Scope

- `.claude/hooks/validate-orchestrator-output.ps1` and its bundle mirror.
- The Pester suites for that hook.

## Acceptance Criteria (early draft)

- [ ] The hook resolves the run's checkpoint through `WorktreeRunResolution.psm1` instead of composing it from the session root.
- [ ] An unresolved or ambiguous target produces a named failure rather than a read of the session-root copy.
- [ ] A test models the two-worktree topology through the resolver seams without creating files.

## Constraints & Risks

- The hook is a SubagentStop completion gate; a change that blocks too broadly can stop every orchestrator run.
- The hook is on the #690 protected list; the change needs its own plan and review.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
