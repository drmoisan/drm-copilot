# Node Toolchain Availability — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T2]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-14

## Probe — repository root

Command: `node -e "console.log(require('node:fs').existsSync('node_modules'))"` (run from the repository root)

EXIT_CODE: 0

Output Summary: printed `false` — root `node_modules` was absent. This worktree is a fresh checkout at `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee` and does not share the primary checkout's installed dependencies.

## Probe — extension scope

Command: `node -e "console.log(require('node:fs').existsSync('node_modules'))"` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary: printed `false` — extension `node_modules` was absent for the same reason.

## Install — repository root

Command: `npm ci` (run from the repository root)

EXIT_CODE: 0

Output Summary: `added 525 packages, and audited 526 packages in 6s`; `found 0 vulnerabilities`. One deprecation warning for `glob@10.5.0`, which is a transitive dependency pinned by the committed `package-lock.json` and is not modified by this cycle.

## Install — extension scope

Command: `npm ci` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary: `added 457 packages, and audited 458 packages in 6s`; `found 0 vulnerabilities`. Same `glob@10.5.0` deprecation warning from the committed `extensions/drm-copilot/package-lock.json`.

## Post-install verification

Command: `node -e "console.log(require('node:fs').existsSync('node_modules'))"` (run from the repository root, then from `extensions/drm-copilot/`)

EXIT_CODE: 0 (both scopes)

Output Summary: both scopes printed `true`. Both `node_modules` trees are installed at the end of this task.

Command: `git status --porcelain | wc -l` (run from the repository root)

EXIT_CODE: 0

Output Summary: `31` — identical to the pristine pre-remediation count. Both `node_modules` trees are gitignored, so neither `npm ci` invocation added a working-tree entry.

## Determination

Both scopes reported an absent `node_modules` on first probe and both required `npm ci`. Both invocations exited 0. Both scopes report an installed `node_modules` at the end of the task. Neither install changed the tracked or untracked working-tree entry set.
