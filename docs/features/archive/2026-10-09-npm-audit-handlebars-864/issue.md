# npm-audit-handlebars (Issue #864)

- Date captured: 2026-10-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-handlebars/ (Issue #864)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #864
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/864
- Last Updated: 2026-10-09
- Work Mode: minor-audit

## Summary

The NPM Audit Gate fails for the root package and `extensions/drm-copilot` on every PR and on `main`. Newly published critical advisories cover `handlebars` 4.0.0 - 4.7.9, which both lockfiles resolve transitively. `packages/mcp-server` is not affected.

## Environment

- OS/version: GitHub Actions ubuntu-24.04 (reusable workflow `.github/workflows/_npm-audit-gate.yml`, `audit-level: moderate`)
- Python version: n/a
- Command/flags used: `npm audit --audit-level=moderate` per package
- Data source or fixture: committed `package-lock.json` files at `main` e7d3779b

## Steps to Reproduce

1. Open any PR into `main`, for example PRs #859, #860, #861 and #862 from parallel run bug-burndown-2026-10-08.
2. Observe that `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` fail.
3. Locally, at e7d3779b, `npm audit --package-lock-only --audit-level=moderate` in the root and in `extensions/drm-copilot` reports 1 critical vulnerability each.

## Expected Behavior

`npm audit --audit-level=moderate` passes for all three packages.

## Actual Behavior

```text
handlebars  4.0.0 - 4.7.9
Severity: critical
GHSA-xw65-4hp5-5hc7  JavaScript Injection via Unsafe Inline Embedding of Precompiled Templates
GHSA-8r5x-fm3f-whwj  JavaScript Injection via AST Type Confusion in compile (bypass of CVE-2026-33937)
GHSA-p8wg-vrv2-v86f  JavaScript Injection via Own Property Check Bypass
fix available via `npm audit fix`
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior (local `npm audit --package-lock-only` at e7d3779b).

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every PR into `main` fails required CI. This blocks parallel run bug-burndown-2026-10-08 (PRs #859-#862) and the final integration PR of epic #852.

## Suspected Cause / Notes

- `handlebars` is transitive. `npm ls handlebars` at e7d3779b shows the dependency path.
- Precedents: #802 / PR #803 and #830 / PR #831 used `overrides` in the same manifests.

## Proposed Fix / Validation Ideas

- [ ] Add `"handlebars": "^4.7.10"` to `overrides` in `package.json` and `extensions/drm-copilot/package.json`, and regenerate both lockfiles. Do not bump unrelated dependencies.
- [ ] `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls handlebars` shows only >= 4.7.10.
- [ ] The root and extension TypeScript toolchains pass, and PR CI is green, including Publish to Marketplace.

## Acceptance Criteria

- [x] AC-1: In both manifests (`package.json` and `extensions/drm-copilot/package.json`), `overrides` contains `"handlebars": "^4.7.10"` next to the existing overrides; no other dependency is bumped; `packages/mcp-server` is untouched; and both `package-lock.json` files (root and `extensions/drm-copilot`) are regenerated with npm install to match.
- [x] AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages (root, `extensions/drm-copilot`, `packages/mcp-server`), and `npm ls handlebars` shows only versions >= 4.7.10.
- [x] AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, except the pre-existing root `format:check` failure on `tests/fixtures/**` JSON (excluded as in #802, tracked in #848). PR CI is green on all checks, including Publish to Marketplace, verified against the full check list rather than only the required checks.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch