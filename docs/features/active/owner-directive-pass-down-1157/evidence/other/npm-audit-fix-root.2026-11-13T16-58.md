# npm Audit Fix - Root Manifest (P1-T1, finding C1)

Timestamp: 2026-11-13T16-57
Command: npm --prefix <worktree root>/. audit fix; npm --prefix <worktree root>/. ls hono @hono/node-server; npm --prefix <worktree root>/. audit --audit-level=moderate
EXIT_CODE: 0
Output Summary: npm audit fix (no --force) moved hono 4.13.14 -> 4.13.18 and @hono/node-server 2.1.5 -> 2.1.8 in package-lock.json; the gate audit exits 0 with 6 low findings (deepmerge chain, --force only); package.json not rewritten; in-range fallback not needed.

## Per-command results

| Command | EXIT_CODE | Result |
|---|---|---|
| `npm --prefix <worktree root>/. audit fix` | 1 | lockfile updated; exits 1 because 6 low findings remain whose only fix is `npm audit fix --force` (not run) |
| `npm --prefix <worktree root>/. ls hono @hono/node-server` | 0 | `@modelcontextprotocol/sdk@1.32.2` -> `@hono/node-server@2.1.8`, `hono@4.13.18` (deduped) |
| `npm --prefix <worktree root>/. audit --audit-level=moderate` | 0 | `6 low severity vulnerabilities`; no moderate, high, or critical |
| `git -C <worktree root> status --porcelain` | 0 | ` M package-lock.json` only |

## Resolved versions

| Package | Before | After |
|---|---|---|
| `hono` | 4.13.14 | 4.13.18 |
| `@hono/node-server` | 2.1.5 | 2.1.8 |

`git diff --stat HEAD -- package-lock.json`: 6 insertions, 6 deletions (the `version`, `resolved`, and `integrity` fields of the two entries).

- Root `package.json` was not rewritten by `npm audit fix`.
- Fallback (`npm update hono @hono/node-server`) was not needed: no moderate `hono` or `@hono/node-server` advisory remained.
- No `--force` run occurred.
