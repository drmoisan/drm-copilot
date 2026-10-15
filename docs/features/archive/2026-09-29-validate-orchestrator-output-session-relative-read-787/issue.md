# validate-orchestrator-output-session-relative-read (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #690

- Work Mode: full-bug

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

## Bundled Issues

This feature is child C6 of epic #852 (enforcement-hook-precision). Primary issue: #787. The same pull request delivers and closes the following existing issue; no new issue is created.

- #840 — The epic wave-barrier Layer 2 ordering check (inside `validate_epic_orchestrator_state_text`) is not run at `epic-orchestrator` `SubagentStop`, although three documents state that it is.
  - Operator decision (fixed; not to be re-opened): port the wave-barrier Layer 2 ordering check from `validate_epic_orchestrator_state_text` to PowerShell and invoke it from `.claude/hooks/validate-orchestrator-output.ps1` for `epic-orchestrator-state`. No Python in hooks: no Python leg and no subprocess to Python.
  - The PowerShell port must emit `EPIC_WAVE_BARRIER_VIOLATION` for the same cases as the Python authority, proven by a shared parity fixture set exercised by both the Pester suite and a Python test.
  - Correct the three documents #840 lists, and their bundled mirrors, so they describe the enforcement that exists after the change: `.claude/skills/epic-orchestrate/SKILL.md` (Layer 2 bullet), `.claude/agents/epic-orchestrator.md` (the SubagentStop sentence), and the header comment of `.claude/hooks/enforce-epic-wave-barrier.ps1` (lines 26-29 at the time of filing).
