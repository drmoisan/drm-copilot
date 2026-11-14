# npm Audit Fix - Extension Manifest (P1-T2, finding C2)

Timestamp: 2026-11-13T16-58
Command: npm --prefix <worktree root>/extensions/drm-copilot audit fix; npm --prefix <worktree root>/extensions/drm-copilot ls hono @hono/node-server; npm --prefix <worktree root>/extensions/drm-copilot audit --audit-level=moderate
EXIT_CODE: 0
Output Summary: npm audit fix (no --force) moved hono 4.13.14 -> 4.13.18 and @hono/node-server 2.1.5 -> 2.1.8 in extensions/drm-copilot/package-lock.json; the gate audit exits 0 with 6 low findings (deepmerge chain, --force only, not forced); package.json not rewritten; fallback not needed.

## Per-command results

| Command | EXIT_CODE | Result |
|---|---|---|
| `npm --prefix <worktree root>/extensions/drm-copilot audit fix` | 1 | lockfile updated; exits 1 because 6 low findings remain whose only fix is `npm audit fix --force` (not run) |
| `npm --prefix <worktree root>/extensions/drm-copilot ls hono @hono/node-server` | 0 | `@modelcontextprotocol/sdk@1.32.2` -> `@hono/node-server@2.1.8`, `hono@4.13.18` (deduped) |
| `npm --prefix <worktree root>/extensions/drm-copilot audit --audit-level=moderate` | 0 | `6 low severity vulnerabilities`; no moderate, high, or critical |
| `git -C <worktree root> status --porcelain` | 0 | ` M extensions/drm-copilot/package-lock.json` only |

## Resolved versions

| Package | Before | After |
|---|---|---|
| `hono` | 4.13.14 | 4.13.18 |
| `@hono/node-server` | 2.1.5 | 2.1.8 |

`git diff --stat HEAD`: `extensions/drm-copilot/package-lock.json`, 6 insertions, 6 deletions.

## Remaining deepmerge finding (not forced)

- `deepmerge  >=4.2.0`, severity low, GHSA-gcqx-w48m-w2h4; `fix available via npm audit fix --force`, `Will install jest@25.1.0, which is a breaking change`. Dependents `jest-config`, `@jest/core`, `jest`, `ts-jest`, `jest-cli` (6 low in total). Below the `moderate` gate; not forced.

- `extensions/drm-copilot/package.json` was not rewritten by `npm audit fix`.
- No `--force` run occurred.
