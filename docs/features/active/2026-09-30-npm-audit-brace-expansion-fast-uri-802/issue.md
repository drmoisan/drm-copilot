# npm-audit-brace-expansion-fast-uri (Issue #802)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-brace-expansion-fast-uri/ (Issue #802)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #802
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/802
- Last Updated: 2026-09-30
- Work Mode: minor-audit

## Summary

The NPM Audit Gate now fails for every PR on all three npm packages (`.`, `extensions/drm-copilot`, `packages/mcp-server`). The cause is newly published advisories for `brace-expansion` (high) and `fast-uri` (moderate) in transitive dependencies. The existing `fast-uri` override (`^3.1.4`) admits vulnerable versions, and there is no `brace-expansion` override.

## Environment

- OS/version: GitHub Actions ubuntu-24.04 (reusable workflow `.github/workflows/_npm-audit-gate.yml`, `audit-level: moderate`)
- Python version: n/a
- Command/flags used: `npm audit --audit-level=moderate` per package (the gate), and locally `npm audit --package-lock-only`
- Data source or fixture: committed `package-lock.json` files at `main` 6e6ccd62

## Steps to Reproduce

1. Open any PR, or dispatch `ci.yml` on any branch based on current `main` (for example, CI run 36712875774 on PR #800's head 56b23e40).
2. Observe that the jobs `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)` and `(packages/mcp-server)` fail.
3. Locally: `npm audit --package-lock-only` at the repo root reports 2 vulnerabilities (1 moderate, 1 high).

## Expected Behavior

`npm audit --audit-level=moderate` passes for all three packages, so PRs can merge on green CI.

## Actual Behavior

```text
2 vulnerabilities (1 moderate, 1 high)
Severity: high
brace-expansion: Quadratic-time expansion of the `{a},b}` rewrite causes CPU denial of service - GHSA-q2hr-2g5m-vwhr
brace-expansion: DoS via uncontrolled recursion on nested brace groups causing stack exhaustion - GHSA-qhr7-859c-m2p7
brace-expansion: DoS via uncontrolled recursion in parseCommaParts causing stack exhaustion - GHSA-6j4f-fj2g-mc7p
fix available via `npm audit fix`   (range: 4.0.0 - 5.0.11; patched in 5.0.12)
Severity: moderate
fast-uri vulnerable to inconsistent host case normalization via percent-encoded octets - GHSA-hrr3-gc8f-f4qj
fix available via `npm audit fix`   (range: 3.0.0 - 3.1.7; patched in 3.1.8)
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior (from CI run 36712875774, job `NPM Audit Gate / npm audit (.)`).

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every PR into `main` and into epic integration branches fails required CI. This currently blocks parallel run `bug-burndown-2026-09-29` (PR #799) and epic #771 (PRs #800, #801).

## Suspected Cause / Notes

- Existing overrides: `package.json:13`, `extensions/drm-copilot/package.json:215` and `packages/mcp-server/package.json:41` pin `"fast-uri": "^3.1.4"`, which still resolves to a vulnerable 3.1.x in the lockfiles.
- No `brace-expansion` override exists. An earlier orchestration paired a `brace-expansion` override with `minimatch` because of major-version coupling; the fix must verify that the `minimatch` consumers still resolve compatible `brace-expansion` majors.

## Proposed Fix / Validation Ideas

- [ ] Raise `fast-uri` to `^3.1.8` and add `"brace-expansion": "^5.0.12"` (plus a paired `minimatch` override only if needed) in all three `package.json` `overrides`, then regenerate each `package-lock.json` with `npm install`.
- [ ] `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls brace-expansion fast-uri` shows only patched versions.
- [ ] The extension, mcp-server and root TypeScript test suites and builds still pass, and CI is green.

## Acceptance Criteria

- [x] AC-1: In all three manifests (`package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json`), `overrides` contains `"fast-uri": "^3.1.8"` and `"brace-expansion": "^5.0.12"`, and each `package-lock.json` is regenerated to match. Evidence: evidence/qa-gates/lock-*.md, scope-check.*.md.
- [x] AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls brace-expansion fast-uri` shows only patched versions (brace-expansion >= 5.0.12, fast-uri >= 3.1.8). Evidence: evidence/qa-gates/audit-*.md, final-audit-*.md.
- [ ] AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, the mcp-server build passes, and PR CI is green.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
