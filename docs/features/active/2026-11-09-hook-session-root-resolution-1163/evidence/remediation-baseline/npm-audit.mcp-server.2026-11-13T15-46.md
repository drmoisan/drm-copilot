# Remediation Baseline — npm audit (packages/mcp-server)

Timestamp: 2026-11-13T15-46
Command: npm ci; npm audit --audit-level=moderate (working directory: packages/mcp-server)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- npm ci: exit 0 (lockfile and manifest in sync).
- npm audit --audit-level=moderate: exit 1; "2 moderate severity vulnerabilities".
- hono <=4.13.15, moderate (five GHSA advisories, same set as the root manifest); "fix available via `npm audit fix`" (non-breaking).
- @hono/node-server 2.0.0 - 2.1.5, moderate (GHSA-qv5m-9pm6-hqp3, GHSA-jpvv-r467-5p4w); "fix available via `npm audit fix`" (non-breaking).
- No deepmerge advisory in this manifest.
