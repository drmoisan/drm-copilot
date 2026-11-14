# File Size Baseline (Issue #1003)

Timestamp: 2026-10-31T12-54
Command: awk 'END{print NR}' extensions/drm-copilot/<file> (per file; NR counts logical lines, a trailing terminator adds no line)
EXIT_CODE: 0
Output Summary: src/extension.ts 496; test/extension.workflow-commands.test.ts 800; all values match the plan expectations.

| File (under extensions/drm-copilot/) | Logical lines |
|---|---|
| src/claude-worktree-session.ts | 248 |
| src/codex-worktree-session.ts | 120 |
| src/extension.ts | 496 |
| test/extension.workflow-commands.test.ts | 800 |
| test/claude-worktree-session.test.ts | 427 |
| test/codex-worktree-session.test.ts | 137 |
| test/codex-worktree-session-command.test.ts | 389 |

New inventory files (`src/worktree-session-launch.ts`, `test/worktree-session-launch.test.ts`, `test/claude-worktree-session-command.test.ts`) do not exist yet.
