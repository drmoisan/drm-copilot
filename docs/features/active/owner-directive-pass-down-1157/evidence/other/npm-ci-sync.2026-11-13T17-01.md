# npm ci Sync Verification (P1-T5)

Timestamp: 2026-11-13T17-00
Command: sh SCRATCH/issue-1157-c2-p0t1.sh (npm --prefix <worktree root>/<manifest> ci for ., extensions/drm-copilot, packages/mcp-server; npm --prefix <worktree root>/packages/mcp-server run build; git status --porcelain)
EXIT_CODE: 0
Output Summary: npm ci exit 0 for all three updated lockfiles; MCP server build exit 0; git status lists no path outside the feature folder.

## Per-command results

| Command | EXIT_CODE | Result |
|---|---|---|
| `npm --prefix <worktree root>/. ci` | 0 | installed from the updated lockfile (residual low findings only) |
| `npm --prefix <worktree root>/extensions/drm-copilot ci` | 0 | installed from the updated lockfile (residual low findings only) |
| `npm --prefix <worktree root>/packages/mcp-server ci` | 0 | `added 95 packages, and audited 96 packages`; `found 0 vulnerabilities` |
| `npm --prefix <worktree root>/packages/mcp-server run build` | 0 | `node esbuild-mcp-server.cjs` completed |
| `git -C <worktree root> status --porcelain` | 0 | only feature-folder paths: the plan file (P1-T4 check-off) and two new evidence files under `evidence/other/` |

The three lockfiles were committed by P1-T1 to P1-T3, so they do not appear in the porcelain listing; `npm ci` rewrote none of them.

## Observation for the orchestrator

The launcher also re-derived the `origin/main` lockfile difference (not a P1-T5 acceptance condition). Since P0-T1, `origin/main` advanced to the merge of PR #1170 and now carries lockfile changes against the merge base. `git -C <worktree root> diff --stat HEAD origin/main -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json` printed nothing: the three lockfiles on this branch are byte-identical to those on `origin/main`, so a later merge of `main` introduces no lockfile conflict.
