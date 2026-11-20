# npm Audit Fail-Before - MCP Server Manifest (P0-T2)

Timestamp: 2026-11-13T16-54
Command: npm --prefix <worktree root>/packages/mcp-server audit --audit-level=moderate
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 2 moderate severity vulnerabilities; hono <=4.13.15 and @hono/node-server 2.0.0 - 2.1.5, both "fix available via `npm audit fix`"; no finding marked as fixable only with --force.

## Per-severity counts

| Severity | Count |
|---|---|
| critical | 0 |
| high | 0 |
| moderate | 2 |
| low | 0 |

## Moderate advisories as printed

- `@hono/node-server  2.0.0 - 2.1.5` (Severity: moderate): GHSA-qv5m-9pm6-hqp3, GHSA-jpvv-r467-5p4w. `fix available via npm audit fix`.
- `hono  <=4.13.15` (Severity: moderate): GHSA-4m76-xfj5-7975, GHSA-h7mg-cq63-vhpq, GHSA-3gg2-335m-rxc6, GHSA-46wx-v44x-9hh2, GHSA-4h7h-rv7c-7m2v. `fix available via npm audit fix`.

## Findings fixable only with --force

none
