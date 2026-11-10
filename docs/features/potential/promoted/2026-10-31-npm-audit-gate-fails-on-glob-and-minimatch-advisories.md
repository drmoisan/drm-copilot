# npm-audit-gate-fails-on-glob-and-minimatch-advisories (Issue #1041)

- Date captured: 2026-10-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-gate-fails-on-glob-and-minimatch-advisories/ (Issue #1041)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1041
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1041
- Last Updated: 2026-10-31
## Summary

The `npm Audit Gate` (`npm audit --audit-level=moderate`) fails on `main` and on every open pull request after two advisories were published on 2026-10-30 to 2026-10-31. No code change caused it, and no pull request can merge until it passes.

## Environment

- OS/version: GitHub Actions `ubuntu-latest`
- Python version: not applicable
- Command/flags used: `npm audit --audit-level=moderate` in `.github/workflows/_npm-audit-gate.yml`, run for `.`, `extensions/drm-copilot` and `packages/mcp-server`
- Data source or fixture: the root `package-lock.json` on `main`

## Steps to Reproduce

1. On current `main`, run `npm audit --audit-level=moderate` against the root lockfile (or open any pull request).
2. Observe the failure of the audit checks for `.` and `extensions/drm-copilot`.

## Expected Behavior

The audit gate passes, or a documented, justified exception is recorded.

## Actual Behavior

The gate fails with `Process completed with exit code 1`. The push run for the #1039 merge, `41152665968` at 2026-10-31T00:54Z, concluded `failure`; the previous push run on `main` (2026-10-30T19:44Z) passed. PR #1040 has the same two audit checks failing and is `BLOCKED`.

The root lockfile reports 31 vulnerabilities (1 low, 30 moderate, 0 high, 0 critical) from three advisories:

- `glob` `>=9.0.0 <=14.0.1`: moderate, "AbortSignal cancellation bypass allows post-timeout filesystem traversal" (GHSA-3g3m-2fjr-6pw4).
- `minimatch <11.0.1`: moderate, "potential denial of service via globparts amplification" (GHSA-g3hv-75wg-m249). It accounts for most of the 30 moderate findings, through `@typescript-eslint/typescript-estree`.
- `deepmerge` `>=4.2.0 <=4.3.1`: low, prototype poisoning (GHSA-gcqx-w48m-w2h4). It does not fail a `moderate` gate.

I have not run the audit on `packages/mcp-server` or `extensions/drm-copilot`, so they may add findings.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `npm audit --audit-level=moderate` reports `31 vulnerabilities (1 low, 30 moderate)`; `npm audit fix` leaves issues that "need review and may require choosing a different dependency".

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

It blocks every merge to `main`, including the in-flight parallel run (`bugs-1001-1002-1003-1006`), whose #1011 pull request is stalled on this check.

## Suspected Cause / Notes

New advisories against dev-tool dependencies (`glob`, `minimatch`) that the repo pins transitively. The earlier orchestration notes record a similar paired `brace-expansion`/`minimatch` override for a previous advisory.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: after the fix, `npm audit --audit-level=moderate` exits 0 in all three manifests (`.`, `extensions/drm-copilot`, `packages/mcp-server`), and the extension and MCP test suites still pass.
- [ ] Integration scenario to retest: CI on a pull request with the fix.
- [ ] Manual verification notes

Preferred fix, smallest first:

1. Add `overrides` (npm) for `glob` and `minimatch` (and `brace-expansion` if the patched `minimatch` needs it) to the patched versions, in each manifest that reports the finding. Regenerate lockfiles with `npm install --package-lock-only`, never by hand.
2. Confirm that the patched versions do not break lint, build or tests. If an override needs a breaking major, record it and ask rather than choosing silently.
3. Do not lower `audit-level`, and do not add an ignore, unless the advisory is shown not to apply, with the reason recorded.

Language note: dependency configuration only; no new scripts.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
