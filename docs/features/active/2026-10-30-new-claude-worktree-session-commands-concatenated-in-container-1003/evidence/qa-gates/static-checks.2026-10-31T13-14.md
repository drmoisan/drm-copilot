# QA Gate: Static Checks (Issue #1003)

Timestamp: 2026-10-31T13-14
Command: sh SCRATCH/issue-1003-static.sh (runs the grep counts below from extensions/drm-copilot/)
EXIT_CODE: 0
Output Summary: every count matches the expected value; `grep -rl "bin/Activate.ps1" src` lists only src/claude-worktree-session.ts.

| Check (from extensions/drm-copilot/) | Expected | Observed | Result |
|---|---|---|---|
| `grep -c "useFakeTimers" test/claude-worktree-session-command.test.ts` | 0 | 0 | PASS |
| `grep -c "useFakeTimers" test/codex-worktree-session-command.test.ts` | 0 | 0 | PASS |
| `grep -c "process.platform" test/claude-worktree-session-command.test.ts` | 0 | 0 | PASS |
| `grep -c "process.platform" test/worktree-session-launch.test.ts` | 0 | 0 | PASS |
| `grep -c "process.platform" test/codex-worktree-session-command.test.ts` | 2 (pre-existing: `expectedPathResolvedCodexExecutable` and "launches installed extension package codex through PowerShell call operator") | 2 | PASS |
| `grep -c -e "tmpdir" -e "mkdtemp" -e "writeFileSync" test/claude-worktree-session-command.test.ts` | 0 | 0 | PASS |
| `grep -c -e "tmpdir" -e "mkdtemp" -e "writeFileSync" test/worktree-session-launch.test.ts` | 0 | 0 | PASS |
| `grep -c -e "from \"vscode\"" -e "from \"node:fs\"" -e "from \"node:child_process\"" src/worktree-session-launch.ts` | 0 | 0 | PASS |
| same for `src/claude-worktree-session.ts` | 0 | 0 | PASS |
| same for `src/codex-worktree-session.ts` | 0 | 0 | PASS |
| `grep -rl "bin/Activate.ps1" src` | only `src/claude-worktree-session.ts` | `src/claude-worktree-session.ts` | PASS |
| `grep -c "newClaudeWorktreeSession" test/extension.workflow-commands.test.ts` | 0 | 0 | PASS |
