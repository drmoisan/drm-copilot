# Remediation Baseline — npm audit (root manifest)

Timestamp: 2026-11-13T15-46
Command: npm ci; npm audit --audit-level=moderate (working directory: repository root)
EXIT_CODE: 1
ExpectedExitCode: 1
Pre-cycle branch head (git rev-parse HEAD, before any Phase 1 edit): 15d3af2d1a7072feea075b77b850f16fb27f677c
Output Summary:
- npm ci: exit 0 (lockfile and manifest in sync).
- npm audit --audit-level=moderate: exit 1; "8 vulnerabilities (6 low, 2 moderate)".
- hono <=4.13.15, moderate (GHSA-4m76-xfj5-7975, GHSA-h7mg-cq63-vhpq, GHSA-3gg2-335m-rxc6, GHSA-46wx-v44x-9hh2, GHSA-4h7h-rv7c-7m2v); "fix available via `npm audit fix`" (non-breaking).
- @hono/node-server 2.0.0 - 2.1.5, moderate (GHSA-qv5m-9pm6-hqp3, GHSA-jpvv-r467-5p4w); "fix available via `npm audit fix`" (non-breaking).
- deepmerge >=4.2.0, low (GHSA-gcqx-w48m-w2h4), with 5 low dependents (jest-config, @jest/core, jest, ts-jest, jest-cli); fix only via `npm audit fix --force` (installs jest@25.1.0, breaking). The vulnerable range has no upper bound, so no patched version exists for an override. Low is below the gate's `moderate` level.
- Note: C1 attributed deepmerge to the extension only; it is also present (low) in the root manifest.
