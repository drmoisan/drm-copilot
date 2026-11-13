# npm Audit Fix - MCP Server Manifest (P1-T3, finding C3)

Timestamp: 2026-11-13T16-59
Command: npm --prefix <worktree root>/packages/mcp-server audit fix; npm --prefix <worktree root>/packages/mcp-server ls hono @hono/node-server; npm --prefix <worktree root>/packages/mcp-server audit --audit-level=moderate
EXIT_CODE: 0
Output Summary: npm audit fix (no --force) exit 0, "changed 2 packages ... found 0 vulnerabilities"; hono 4.13.14 -> 4.13.18 and @hono/node-server 2.1.5 -> 2.1.8 in packages/mcp-server/package-lock.json; gate audit exit 0 with 0 vulnerabilities; package.json not rewritten; fallback not needed.

## Per-command results

| Command | EXIT_CODE | Result |
|---|---|---|
| `npm --prefix <worktree root>/packages/mcp-server audit fix` | 0 | `changed 2 packages, and audited 96 packages`; `found 0 vulnerabilities` |
| `npm --prefix <worktree root>/packages/mcp-server ls hono @hono/node-server` | 0 | `@modelcontextprotocol/sdk@1.32.2` -> `@hono/node-server@2.1.8`, `hono@4.13.18` (deduped) |
| `npm --prefix <worktree root>/packages/mcp-server audit --audit-level=moderate` | 0 | `found 0 vulnerabilities` |
| `git -C <worktree root> status --porcelain` | 0 | ` M packages/mcp-server/package-lock.json` only |

## Resolved versions

| Package | Before | After |
|---|---|---|
| `hono` | 4.13.14 | 4.13.18 |
| `@hono/node-server` | 2.1.5 | 2.1.8 |

`git diff --stat HEAD`: `packages/mcp-server/package-lock.json`, 6 insertions, 6 deletions.

- `packages/mcp-server/package.json` was not rewritten by `npm audit fix`.
- No `--force` run occurred.
