# npm Audit Residual Findings (P1-T4)

Timestamp: 2026-11-13T16-59
Command: npm --prefix <worktree root>/<manifest> audit (no level flag) for ., extensions/drm-copilot, packages/mcp-server
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: root 6 low, extension 6 low (the deepmerge chain, fix only through `npm audit fix --force`, a breaking jest major change); MCP server 0 vulnerabilities; zero moderate, high, or critical residual findings in each manifest; no --force run occurred.

## Per-manifest results

| Manifest | Command | EXIT_CODE | Critical | High | Moderate | Low |
|---|---|---|---|---|---|---|
| `.` | `npm --prefix <worktree root>/. audit` | 1 | 0 | 0 | 0 | 6 |
| `extensions/drm-copilot` | `npm --prefix <worktree root>/extensions/drm-copilot audit` | 1 | 0 | 0 | 0 | 6 |
| `packages/mcp-server` | `npm --prefix <worktree root>/packages/mcp-server audit` | 0 | 0 | 0 | 0 | 0 |

The first two exit 1 because `npm audit` with no level flag fails on any finding, including low.

## Residual findings (root and extension, identical)

| Package | Severity | Advisory | Fix offered | Reason not fixed |
|---|---|---|---|---|
| `deepmerge` (>=4.2.0) | low | GHSA-gcqx-w48m-w2h4 | `npm audit fix --force`; `Will install jest@25.1.0, which is a breaking change` | fix only through `--force` and a jest major-version change |
| `jest-config` (>=25.2.0-alpha.86) | low | via `deepmerge` (GHSA-gcqx-w48m-w2h4) | same | same |
| `@jest/core` (>=25.2.0-alpha.86) | low | via `jest-config` | same | same |
| `jest` (>=25.2.0-alpha.86) | low | via `@jest/core` and `jest-cli` | same | same |
| `ts-jest` (>=25.10.0-alpha.1) | low | via `jest` | same | same |
| `jest-cli` (>=25.2.0-alpha.86) | low | via `@jest/core` and `jest-config` | same | same |

These are below the `moderate` level of `NPM Audit Gate`. Per OD-8 they are related to this cycle and are recorded here; no separate issue is filed.

## Statements

- Zero moderate, high, or critical residual findings in `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json`.
- No `npm audit fix --force` run occurred in any manifest.
