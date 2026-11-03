# Premise Verification: npm Audit Gate on current main (Issue #1041)

Timestamp: 2026-11-03T11-55
Command: npm audit --audit-level=moderate (run in `.`, `extensions/drm-copilot`, `packages/mcp-server`, matching `.github/workflows/_npm-audit-gate.yml`)
EXIT_CODE: 0
Output Summary: All three manifests exit 0 at `--audit-level=moderate`. Root and `extensions/drm-copilot` each report 6 low findings (the `deepmerge` GHSA-gcqx-w48m-w2h4 chain through jest), 0 moderate, 0 high, 0 critical. `packages/mcp-server` reports 0 vulnerabilities. Neither `glob` (GHSA-3g3m-2fjr-6pw4) nor `minimatch` (GHSA-g3hv-75wg-m249) appears in any report. The issue premise is falsified: the fix already landed on `main` through PR #1055.

## Tree Under Test

- Branch `bug/npm-audit-glob-minimatch-overrides-1041`, which equals `origin/main` (merge of PR #1060) plus one commit that adds only documentation under `docs/features/` (3 files, no `package.json` or lockfile change).
- Local toolchain: node v24.14.0, npm 11.9.0. The workflow uses node 20; `npm audit` resolves advisories from the lockfile against the registry, so the advisory set does not depend on the local node version.

## Per-Manifest Results

| Manifest | EXIT_CODE | low | moderate | high | critical | Packages reported |
|---|---|---|---|---|---|---|
| `.` | 0 | 6 | 0 | 0 | 0 | @jest/core, deepmerge, jest, jest-cli, jest-config, ts-jest |
| `extensions/drm-copilot` | 0 | 6 | 0 | 0 | 0 | @jest/core, deepmerge, jest, jest-cli, jest-config, ts-jest |
| `packages/mcp-server` | 0 | 0 | 0 | 0 | 0 | none |

## Resolved Versions in Lockfiles

| Lockfile | glob | minimatch | brace-expansion |
|---|---|---|---|
| `package-lock.json` | 14.0.3 | 11.0.3 | 5.0.12 |
| `extensions/drm-copilot/package-lock.json` | 14.0.3 | 11.0.3 | 5.0.12 |
| `packages/mcp-server/package-lock.json` | not present | not present | not present |

`glob` 14.0.3 is outside the vulnerable range `>=9.0.0 <=14.0.1`, and `minimatch` 11.0.3 is outside `<11.0.1`. Both root and extension `package.json` files carry the overrides `"minimatch": "^11.0.3"` and `"glob": "^14.0.3"`.

## Origin of the Fix

- Commit `5c961392b` (2026-10-31T20:41:48-04:00), "fix(deps): override minimatch to ^11.0.3 and glob to ^14.0.3 to clear npm audit", changes the overrides in both `package.json` and `extensions/drm-copilot/package.json`.
- It merged through PR #1055 at 2026-11-01T01:14:27Z. PR #1055 did not close issue #1041, which is still `OPEN`.

## CI Corroboration

- Scheduled `npm-audit-gate.yml` run 41405054290 on `main` (2026-11-02T07:14:55Z): all three jobs `success`. The previous scheduled run, 40286847795 (2026-10-26), concluded `failure`.
- `ci.yml` push run 41455648340 for the PR #1060 merge on `main` (2026-11-02T13:44:57Z): `NPM Audit Gate / npm audit (.)`, `NPM Audit Gate / npm audit (extensions/drm-copilot)` and `NPM Audit Gate / npm audit (packages/mcp-server)` all `success`.

## Residual Finding (Not in Scope)

The low-severity `deepmerge` advisory (GHSA-gcqx-w48m-w2h4) remains in the root and extension lockfiles. The issue records that it does not fail a `moderate` gate, and the runs above confirm it. The only automated fix is a breaking downgrade to jest 25, so no change is proposed here.

## Disposition

No code change is made for issue #1041. The checkpoint records `blocked_reason: premise_falsified`. Closing issue #1041 as resolved by PR #1055 is left to the coordinator.
