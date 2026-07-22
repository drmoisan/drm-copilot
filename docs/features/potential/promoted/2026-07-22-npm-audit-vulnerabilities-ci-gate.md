# npm-audit-vulnerabilities-ci-gate (Issue #397)

- Date captured: 2026-07-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-vulnerabilities-ci-gate/ (Issue #397)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #397
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/397
- Last Updated: 2026-07-22
## Summary

The `NPM Audit Gate` required CI check fails on `main` for all three npm manifests (root `.`, `extensions/drm-copilot`, `packages/mcp-server`) because `npm audit --audit-level=moderate` finds moderate/high-severity advisories in transitive dependencies.

## Environment

- OS/version: ubuntu-24.04 (GitHub Actions hosted runner)
- Node version: 20.20.2 (npm 10.8.2)
- Command/flags used: `npm ci && npm audit --audit-level=moderate` (see `.github/workflows/_npm-audit-gate.yml`)
- Data source or fixture: N/A

## Steps to Reproduce

1. Check out `main` at commit `b2351cbc`.
2. Run `npm ci && npm audit --audit-level=moderate` in each of `.`, `extensions/drm-copilot`, and `packages/mcp-server`.
3. Observe non-zero exit and advisory report.

## Expected Behavior

`NPM Audit Gate` passes with zero moderate-or-higher advisories in all three manifests.

## Actual Behavior

CI run 29885750231 (and two prior runs) show `NPM Audit Gate / npm audit (.)`, `NPM Audit Gate / npm audit (extensions/drm-copilot)`, and `NPM Audit Gate / npm audit (packages/mcp-server)` all failing with `failure` conclusion.

Advisories found (moderate/high severity, at or above the `moderate` audit-level gate):
- `@hono/node-server` `<2.0.5` (moderate, GHSA-frvp-7c67-39w9, path traversal in `serve-static` on Windows). Transitive via `@modelcontextprotocol/sdk`. `npm audit fix` alone does not resolve it; `npm audit fix --force` bumps `@modelcontextprotocol/sdk` to `1.24.3`, a semver-major change, in all three manifests.
- `fast-uri` `3.0.0–3.1.3` (high, GHSA-4c8g-83qw-93j6 and GHSA-v2hh-gcrm-f6hx, host confusion). Non-breaking fix available via `npm audit fix`. Present in all three manifests.
- `hono` `4.0.0–4.12.26` (moderate, GHSA-xgm2-5f3f-mvvc, GHSA-hvrm-45r6-mjfj, GHSA-w62v-xxxg-mg59). Non-breaking fix available via `npm audit fix`. Present in root and `extensions/drm-copilot`.
- `brace-expansion` `2.0.0-2.1.1 || 3.0.0-5.0.6` (high, GHSA-3jxr-9vmj-r5cp, ReDoS). Non-breaking fix available via `npm audit fix`. Present in root and `extensions/drm-copilot`.
- `body-parser` `2.0.0-2.2.2` (low, GHSA-v422-hmwv-36x6). Below the `moderate` gate threshold but fixable via `npm audit fix`. Present in root only.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `gh run view 29885750231 --log-failed` shows `# npm audit report` blocks per manifest with the advisories listed above; full `npm audit --json` output captured locally for `.` and `packages/mcp-server`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- `@modelcontextprotocol/sdk` is a direct dependency in all three manifests and pins to a version range whose vendored `@hono/node-server` transitive dependency predates the `2.0.5` fix.
- Two candidate remediation strategies to compare in research: (a) `npm audit fix --force` to bump `@modelcontextprotocol/sdk` to `1.24.3`+ (semver-major, may require source changes in `packages/mcp-server` and any direct SDK usage in the other two manifests), or (b) a targeted `overrides`/`resolutions` entry pinning `@hono/node-server` to `>=2.0.5` without bumping the SDK major version, if compatible.
- Non-breaking advisories (`fast-uri`, `hono`, `brace-expansion`, `body-parser`) are fixable via plain `npm audit fix` independent of the SDK decision.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: existing TypeScript unit/vitest suites for `packages/mcp-server` and `extensions/drm-copilot` must still pass after any dependency bump.
- [x] Integration scenario to retest: MCP server startup/tool invocation smoke path if `@modelcontextprotocol/sdk` is bumped.
- [x] Manual verification notes: re-run `npm audit --audit-level=moderate` in all three manifests locally and confirm the `NPM Audit Gate` required check goes green on the PR head SHA.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
