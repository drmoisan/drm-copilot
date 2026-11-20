# npm Install Baseline - Remediation Cycle 2 (P0-T1)

Timestamp: 2026-11-13T16-53
Command: sh SCRATCH/issue-1157-c2-p0t1.sh (node --version; npm --version; npm --prefix <worktree root>/<manifest> ci for ., extensions/drm-copilot, packages/mcp-server; npm --prefix <worktree root>/packages/mcp-server run build; git status --porcelain; git diff --stat <merge base> origin/main -- the three lockfiles)
EXIT_CODE: 0
Output Summary: npm ci exit 0 for all three manifests; mcp-server build exit 0; no tracked change after install; origin/main lockfile difference empty.

## Per-command results

| Command | EXIT_CODE | Result |
|---|---|---|
| `node --version` | 0 | v26.13.0 |
| `npm --version` | 0 | 11.20.0 |
| `npm --prefix <worktree root>/. ci` | 0 | installed; npm reports audit findings (see P0-T2) |
| `npm --prefix <worktree root>/extensions/drm-copilot ci` | 0 | installed; npm reports audit findings (see P0-T2) |
| `npm --prefix <worktree root>/packages/mcp-server ci` | 0 | installed; npm suggests `npm audit fix` |
| `npm --prefix <worktree root>/packages/mcp-server run build` | 0 | `node esbuild-mcp-server.cjs` completed |
| `git -C <worktree root> status --porcelain` | 0 | empty output (no lockfile, no package.json changed) |
| `git -C <worktree root> fetch origin main` | 0 | fetched |
| `git -C <worktree root> merge-base origin/main HEAD` | 0 | merge base derived at run time |
| `git -C <worktree root> diff --stat <merge base> origin/main -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json` | 0 | empty output: main carries no lockfile change since the merge base |

Note: npm printed `install-scripts` warnings (packages with install scripts not covered by `allowScripts`: `@parcel/watcher`, `unrs-resolver`, `esbuild`); these are warnings only and did not change any exit code.
