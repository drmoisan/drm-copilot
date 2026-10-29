# npm-audit-gate-release-1-1-23 (Issue #996)

- Date captured: 2026-10-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-gate-release-1-1-23/ (Issue #996)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #996
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/996
- Last Updated: 2026-10-29
## Summary

The NPM Audit Gate fails on release PR #994 (release 1.1.23) for all three manifests because newly published advisories affect transitive dependencies.

## Environment

- OS/version: GitHub Actions ubuntu runner
- Python version: not applicable
- Command/flags used: `npm audit --audit-level=moderate` in `.`, `packages/mcp-server`, `extensions/drm-copilot`
- Data source or fixture: CI run 40852479325 and audit run 40852479422 on branch release/full-20261029094758

## Steps to Reproduce

1. Check out branch release/full-20261029094758.
2. Run `npm audit --audit-level=moderate` in each of the three manifest directories.
3. Observe exit code 1 in each.

## Expected Behavior

The audit gate exits 0 for all three manifests.

## Actual Behavior

The gate exits 1. Findings at moderate or higher: zod (<4.6.6, high), body-parser (high), qs (<=6.16.0), hono, @hono/node-server, fast-uri, ip-address (<=10.7.3).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `13 vulnerabilities (6 low, 5 moderate, 2 high)` in extensions/drm-copilot.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The advisories were published after release 1.1.22; the 1.1.23 version bump did not change dependencies. Remaining findings (jest, ts-jest, mocha, @vscode/test-cli, serialize-javascript) are severity low and below the gate threshold.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: existing extension and root suites must still pass.
- [x] Integration scenario to retest: CI on PR #994.
- [x] Manual verification notes: run `npm audit fix` (no `--force`) in the three manifests; confirm `npm audit --audit-level=moderate` exits 0.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
