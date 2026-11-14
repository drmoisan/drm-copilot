# QA Gate: File Size (Issue #1003)

Timestamp: 2026-10-31T13-14
Command: awk 'END{print NR}' extensions/drm-copilot/<file> (per file; logical lines, a trailing terminator adds no line)
EXIT_CODE: 0
Output Summary: src/extension.ts 448 (<= 500, baseline 496); test/extension.workflow-commands.test.ts 369 (<= 800, baseline 800); every other inventory source and test file is at or below 800 (largest: jest.config.cjs 559).

| File (under extensions/drm-copilot/) | Baseline | Post-change | Limit | Result |
|---|---|---|---|---|
| src/extension.ts | 496 | 448 | 500 | PASS |
| test/extension.workflow-commands.test.ts | 800 | 369 | 800 | PASS |
| src/worktree-session-launch.ts | new | 244 | 800 | PASS |
| src/claude-worktree-session.ts | 248 | 260 | 800 | PASS |
| src/codex-worktree-session.ts | 120 | 121 | 800 | PASS |
| test/worktree-session-launch.test.ts | new | 350 | 800 | PASS |
| test/claude-worktree-session-command.test.ts | new | 358 | 800 | PASS |
| test/claude-worktree-session.test.ts | 427 | 445 | 800 | PASS |
| test/codex-worktree-session.test.ts | 137 | 138 | 800 | PASS |
| test/codex-worktree-session-command.test.ts | 389 | 379 | 800 | PASS |
| jest.config.cjs | not recorded | 559 | 800 | PASS |

README.md and CHANGELOG.md are Markdown and exempt from the file-size limit.
