# P18-T2 Root dependency install on the cycle-2 tree

Timestamp: 2026-10-30T12-25
Task: [P18-T2] Run the extension TypeScript gates after a clean root dependency install and retain the coverage report.
Command: npm ci (repository root); git status --porcelain (repository root, directly after the install)
EXIT_CODE: 0 (npm ci), 0 (git status)
Output Summary: The clean install from the root `package-lock.json`, which changed through the rebase onto main, completed at 2026-10-30T12-21 UTC; `git status --porcelain` printed nothing afterwards (the install touched only the git-ignored `node_modules/`). The first attempt at 2026-10-30T12-15 UTC failed with `EPERM: operation not permitted, unlink '...node_modules/@parcel/watcher-win32-x64/watcher.node'` (exit 127): a Jest `--watch` runner started by the editor's Jest extension for this worktree held the native module loaded. That one process was stopped (it holds no state and the extension restarts it on demand), a probe confirmed that no process held this worktree's `node_modules` native modules any longer, and the whole P18-T2 sequence was re-run from the install so that the recorded cycle is one clean pass. npm printed its audit summary (`npm audit` advisory text) and no error.
Result: PASS
