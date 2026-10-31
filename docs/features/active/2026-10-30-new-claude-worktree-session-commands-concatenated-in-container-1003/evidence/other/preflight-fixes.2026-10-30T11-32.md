# Preflight Fixes

Timestamp: 2026-10-30T11-32
Plan: docs/features/active/2026-10-30-new-claude-worktree-session-commands-concatenated-in-container-1003/plan.2026-10-30T06-59.md

## Fixes

1. `## File Inventory` | inventory omission (validator-blind; assertion meaning kept) | Added `FEATURE/issue.md`, `FEATURE/spec.md` (acceptance-criteria check-offs only), and `FEATURE/research/research.2026-10-30T11-30.md`. These files are untracked in the worktree before execution, and `spec.md` receives AC check-offs during execution, so the [P7-T9] "subset of `## File Inventory`" condition could not pass while they were absent from the inventory. The out-of-scope checks in [P7-T9] are unchanged.
2. [P5-T1] | incomplete symbol list | Added `createTerminalMock` to the now-unused imports removed from `extensions/drm-copilot/test/extension.workflow-commands.test.ts`. Every use of `createTerminalMock` in that file is inside the twelve removed `newClaudeWorktreeSession` tests, so leaving the import would make the task's own "no unused-import finding" condition fail.
3. [P7-T7] | literal formatting of a search pattern (assertion meaning kept: AC-14 concerns imports) | Changed the purity search patterns from `node:fs` and `node:child_process` to `from "node:fs"` and `from "node:child_process"`. The module doc comment of `extensions/drm-copilot/src/claude-worktree-session.ts` contains the text `node:child_process, or node:fs`, which [P3-T1] does not require removing, so the bare patterns would count a comment line and print `1` instead of `0`.
4. [P6-T1] | literal formatting | Rewrote the nested-backtick heading reference as ``### Injecting a pre-`claude` script`` so the inline code span renders as one heading name.
5. `## Existing Tests Asserting Changed Behavior (dispositions)` | disposition clarification | Stated that "newClaudeWorktreeSession defers the claude sendText behind a grace period ..." has no same-named successor and is superseded by the [P1-T2] test "newClaudeWorktreeSession creates one hidden terminal and never calls sendText" and the [P5-T2] test "newClaudeWorktreeSession logs the session without a deferred-send note".
