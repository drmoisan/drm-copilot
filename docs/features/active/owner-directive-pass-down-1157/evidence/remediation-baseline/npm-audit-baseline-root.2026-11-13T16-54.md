# npm Audit Fail-Before - Root Manifest (P0-T2)

Timestamp: 2026-11-13T16-54
Command: npm --prefix <worktree root>/. audit --audit-level=moderate
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 8 vulnerabilities (6 low, 2 moderate); moderate: hono <=4.13.15 and @hono/node-server 2.0.0 - 2.1.5, both "fix available via `npm audit fix`"; low: deepmerge >=4.2.0 chain, fixable only with `npm audit fix --force` (installs jest@25.1.0, a breaking change).

## Per-severity counts

| Severity | Count |
|---|---|
| critical | 0 |
| high | 0 |
| moderate | 2 |
| low | 6 |

## Moderate advisories as printed

- `@hono/node-server  2.0.0 - 2.1.5` (Severity: moderate): GHSA-qv5m-9pm6-hqp3 (unhandled `ECONNRESET` during asynchronous WebSocket upgrade), GHSA-jpvv-r467-5p4w (backslash in request path parsed as path separator). `fix available via npm audit fix`.
- `hono  <=4.13.15` (Severity: moderate): GHSA-4m76-xfj5-7975, GHSA-h7mg-cq63-vhpq, GHSA-3gg2-335m-rxc6, GHSA-46wx-v44x-9hh2, GHSA-4h7h-rv7c-7m2v. `fix available via npm audit fix`.

## Findings fixable only with --force

- `deepmerge  >=4.2.0` (low): GHSA-gcqx-w48m-w2h4, `fix available via npm audit fix --force`, `Will install jest@25.1.0, which is a breaking change`. Dependents reported: `jest-config`, `@jest/core`, `jest`, `ts-jest`, `jest-cli` (6 low in total).
