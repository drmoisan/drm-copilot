# Acceptance-Criteria Traceability (Issue #194)

Timestamp: 2026-06-17T16-57

AC source (full-feature mode): user-story.md `## Acceptance Criteria` (six items),
with spec.md `## Definition of Done` and seeded test conditions as supporting checklists.

| AC | Criterion | Implementing tasks | Concrete evidence |
|---|---|---|---|
| AC1 | New command removes all secondary worktrees, never the primary | [P1-T3], [P3-T2], [P4-T2], [P4-T8] | `selectSecondaryWorktrees` filters `isPrimary === false` (src/remove-worktrees.ts); orchestration excludes primary by position (src/remove-worktrees-runner.ts `removeAllSecondaryWorktrees`); tests "excludes the primary worktree", "never passes the primary worktree path to a remove call" (test/remove-worktrees.test.ts) PASS |
| AC2 | Worktree that cannot be fully removed is skipped and left intact; batch continues | [P1-T4], [P2-T3], [P4-T6], [P4-T7] | `classifyWorktreeForRemoval` skips locked/prunable; NON-force remove records non-zero exit as skipped and continues (src/remove-worktrees-runner.ts); tests "continues the batch when one removal fails", "skips locked and prunable worktrees without issuing a remove call" PASS |
| AC3 | Command reports removed and skipped worktrees with reasons | [P1-T5], [P2-T3], [P4-T4], [P4-T5] | `buildRemovalSummaryMessage` produces removed/skipped report; orchestration aggregates `WorktreeSummary` and appends per-worktree output lines; tests for the message and the positive flow PASS; extension.ts surfaces info/warning notifications |
| AC4 | TypeScript with pure logic separated from git I/O | [P1-T1], [P2-T1], [P2-T2], [P4-T9] | Pure module src/remove-worktrees.ts imports none of vscode/node:child_process/node:fs/node:path; GitRunner seam and `createGitRunner` isolate I/O in src/remove-worktrees-runner.ts; `createGitRunner` resolve-on-nonzero / reject-on-spawn-error tests PASS |
| AC5 | Unit tests cover positive/negative/edge cases; coverage meets thresholds | [P4-T1]–[P4-T11], [P5-T6], [P5-T7] | 388 tests pass (33 suites); package line 95.65% / branch 87.04%; new modules: remove-worktrees.ts 98.42%/90.32%, remove-worktrees-runner.ts 100%/85% (evidence/qa-gates/final-test-coverage.md, coverage-comparison.md) |
| AC6 | Registered in package.json contributions and extension.ts; documented in README | [P3-T1], [P3-T2], [P4-T11], [P5-T1] | package.json `contributes.commands` entry `drmCopilotExtension.removeSecondaryWorktrees` (title "drm-copilot: Remove Secondary Worktrees"); registration + subscriptions push in src/extension.ts; registration/confirmation/error tests PASS; README "Remove Secondary Worktrees" section + command-ID list entry |

## Constraint Verification

- No new runtime dependencies: only `@modelcontextprotocol/sdk` remains in dependencies; new modules use `node:child_process` (built-in) only.
- Pure module isolation: src/remove-worktrees.ts contains no vscode / node:child_process / node:fs / node:path imports (verified by typecheck and review).
- NON-force only: `git worktree remove <path>` with no `--force`; test asserts argv never contains `--force`.
- `git worktree prune` never invoked: orchestration issues only `worktree list --porcelain` and `worktree remove <path>`; prunable worktrees are reported as skipped.
- Primary never removed: excluded by position; asserted by tests.
- File sizes: all new/modified files under 500 lines (remove-worktrees.ts ~188, remove-worktrees-runner.ts ~165, extension.ts ~340).

## Outcome

All six acceptance criteria (AC1–AC6) are satisfied with concrete code and test evidence.
