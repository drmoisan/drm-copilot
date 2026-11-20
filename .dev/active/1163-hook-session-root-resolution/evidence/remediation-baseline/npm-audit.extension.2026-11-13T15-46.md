# Remediation Baseline — npm audit (extensions/drm-copilot)

Timestamp: 2026-11-13T15-46
Command: npm ci; npm audit --audit-level=moderate (working directory: extensions/drm-copilot)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- npm ci: exit 0 (lockfile and manifest in sync).
- npm audit --audit-level=moderate: exit 1; "8 vulnerabilities (6 low, 2 moderate)".
- hono <=4.13.15, moderate (five GHSA advisories, same set as the root manifest); "fix available via `npm audit fix`" (non-breaking).
- @hono/node-server 2.0.0 - 2.1.5, moderate (GHSA-qv5m-9pm6-hqp3, GHSA-jpvv-r467-5p4w); "fix available via `npm audit fix`" (non-breaking).
- deepmerge >=4.2.0, low (GHSA-gcqx-w48m-w2h4), with 5 low dependents in the jest chain; fix only via `npm audit fix --force` (jest@25.1.0, breaking); no patched version exists. Low is below the gate's `moderate` level.
