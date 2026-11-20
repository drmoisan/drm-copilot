# Task Check — P1-T1 (root manifest remediation)

Timestamp: 2026-11-13T15-52
Command: npm audit fix (repository root, no --force); npm ci; npm audit --audit-level=moderate
EXIT_CODE: 0
Changed files: package-lock.json (hono 4.13.14 -> 4.13.18; @hono/node-server 2.1.5 -> 2.1.8; 6 insertions, 6 deletions). package.json unchanged; no `overrides` edit was needed.
Selection: the two gate commands for the root manifest. Rule: task-check selection for a changed configuration path (contract tests that read root `package.json` are not selected because `package.json` did not change; no test reads lockfile content).
Output Summary:
- npm audit fix: exit 0; resolved both moderate advisories without a breaking upgrade.
- npm ci: exit 0.
- npm audit --audit-level=moderate: exit 0; "6 low severity vulnerabilities" (deepmerge GHSA-gcqx-w48m-w2h4 and its jest-chain dependents; fix requires `--force`, breaking, no patched version; below the `moderate` gate level).
- Test cadence: #1167 task check (per-task selection), not a gate.
