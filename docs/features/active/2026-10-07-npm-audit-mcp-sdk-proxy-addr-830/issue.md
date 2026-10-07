# npm-audit-mcp-sdk-proxy-addr (Issue #830)

- Date captured: 2026-10-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-mcp-sdk-proxy-addr/ (Issue #830)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #830
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/830
- Last Updated: 2026-10-07
- Work Mode: minor-audit

## Summary

The NPM Audit Gate fails on every PR for all three npm packages (`.`, `extensions/drm-copilot`, `packages/mcp-server`). Two newly published advisories hit dependencies pinned in the lockfiles on `main`: `@modelcontextprotocol/sdk` (high) and the transitive `proxy-addr` (critical).

## Environment

- OS/version: GitHub Actions ubuntu-24.04 (reusable workflow `.github/workflows/_npm-audit-gate.yml`, `audit-level: moderate`)
- Python version: n/a
- Command/flags used: `npm audit --audit-level=moderate` per package
- Data source or fixture: committed `package-lock.json` files at `main` f6ef5b2f

## Steps to Reproduce

1. Open any PR into `main` (for example PR #829, head c0f245b3).
2. Observe that the jobs `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)` and `(packages/mcp-server)` fail.
3. Locally: `npm audit --package-lock-only` in each package reports the two advisories below.

## Expected Behavior

`npm audit --audit-level=moderate` passes for all three packages, so PRs can merge on green CI.

## Actual Behavior

- GHSA-6qxp-vccf-f47h (high): `@modelcontextprotocol/sdk` >= 1.12.0, < 1.31.0 (OAuth client can send credentials to an authorization server chosen by the MCP server). Patched in 1.31.0. All three lockfiles resolve 1.30.1.
- GHSA-jqcg-44mw-7w3h (critical): `proxy-addr` >= 1.1.0, < 2.0.8 (trust spoofing through IPv4-mapped IPv6 subnets). Patched in 2.0.8. All three lockfiles resolve 2.0.7 (transitive, through express).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: PR #829 CI on head c0f245b3: 17 checks pass, and the three NPM Audit Gate jobs fail on the two advisories above.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every PR into `main` fails required CI. This blocks parallel run `bug-burndown-2026-09-29` (PR #829 for #543 and all remaining items).

## Suspected Cause / Notes

- The Dependabot PRs #826, #827 and #828 bump the SDK to 1.31.0 but leave `proxy-addr` at 2.0.7. #827 and #828 also bump `@types/vscode`, which breaks `vsce package` (#827's Publish to Marketplace check fails). Those PRs are therefore not sufficient.
- Precedent: #802 / PR #803 (overrides for `fast-uri` and `brace-expansion` in the same three manifests).

## Proposed Fix / Validation Ideas

- [ ] In all three `package.json` files, raise `@modelcontextprotocol/sdk` to `^1.31.0` and add the override `"proxy-addr": "^2.0.8"`. Regenerate each `package-lock.json`. Do not bump `@types/vscode`, `@types/node`, or `typescript-eslint`.
- [ ] `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls @modelcontextprotocol/sdk proxy-addr` shows only patched versions.
- [ ] The root and extension TypeScript toolchains and the mcp-server build pass, and PR CI is green, including Publish to Marketplace.

## Acceptance Criteria

- [x] AC-1: In all three manifests (`package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json`), the `@modelcontextprotocol/sdk` dependency is `"^1.31.0"` and `overrides` contains `"proxy-addr": "^2.0.8"` next to the existing `fast-uri` and `brace-expansion` overrides; `@types/vscode`, `@types/node`, and `typescript-eslint` are unchanged; and each `package-lock.json` is regenerated with npm install to match.
- [x] AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls @modelcontextprotocol/sdk proxy-addr` shows only patched versions (@modelcontextprotocol/sdk >= 1.31.0, proxy-addr >= 2.0.8).
- [ ] AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, except the pre-existing root `format:check` failure on `tests/fixtures/**` JSON (excluded as in #802). The mcp-server build passes, and PR CI is green, including Publish to Marketplace.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch