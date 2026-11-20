# npm-audit-gate-advisory-exception (Issue #1204)

- Date captured: 2026-11-18
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-gate-advisory-exception/ (Issue #1204)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1204
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1204
- Last Updated: 2026-11-18
- Work Mode: full-bug

## Summary

The NPM Audit Gate (`.github/workflows/_npm-audit-gate.yml`, `npm audit --audit-level=moderate` in `.`, `extensions/drm-copilot` and `packages/mcp-server`) now fails on every branch, including `main`. The cause is advisory GHSA-fc5q-39xc-vjpf: a high-severity ReDoS in `picomatch` (`<= 4.0.7`, published 2026-10-19, updated 2026-11-17). It has no patched version, and 4.0.7 is the latest release. `picomatch` reaches the repository only through development dependencies (`jest`, `@parcel/watcher`): `npm ls picomatch --omit=dev --all` is empty in all three manifests, so no shipped artifact contains it. Every PR is blocked, including the high-priority #1201 and its release, and epic #1018.

## Environment

- OS/version: GitHub Actions ubuntu-latest, Node 26.13.0
- Python version: not applicable
- Command/flags used: `npm audit --audit-level=moderate`
- Data source or fixture: the three npm manifests and lockfiles; 42 high findings, all from GHSA-fc5q-39xc-vjpf

## Steps to Reproduce

1. Run CI on any branch.
2. Observe that `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` fail with GHSA-fc5q-39xc-vjpf.

## Expected Behavior

The gate still fails on any advisory at or above the configured level, except for advisories listed in a committed, reviewed exception file. Each exception names one advisory id, gives a reason, an owner-approved date and an expiry date, and applies only while every affected path is a development dependency. An exception that has expired, or whose advisory reaches a production dependency, fails the gate. All exceptions are reported in the job log.

## Actual Behavior

The gate fails on a development-only advisory that has no fix, so every PR is blocked.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `picomatch <=4.0.7 Severity: high ... ReDoS through single-branch repeated extglobs - https://github.com/advisories/GHSA-fc5q-39xc-vjpf`, with no fix available.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Upstream has not published a patched `picomatch`. The gate has no exception mechanism. Coordinator decision under the owner's autonomy directive: add the narrowest exception possible. It covers one advisory id, is dev-only (verified in the gate with `npm ls <package> --omit=dev --all` or the audit JSON `isDirect`/`effects` data, whichever is simpler and reliable), and expires 30 days after merge (2026-12-18). The exception is recorded in the process-reduction ledger with the prior gate text and a revert note, so it can be removed once upstream ships a fix. The logic goes in bash or node inside the workflow, or in a small PowerShell or bash script under `scripts/ci/`, with no new Python.

## Proposed Fix / Validation Ideas

- [ ] `config/npm-audit-exceptions.json` with one entry for GHSA-fc5q-39xc-vjpf (id, package, reason, approved_at, expires)
- [ ] Gate step: run `npm audit --json`, fail on any advisory at or above the level that is not excepted, fail on an expired exception, and fail when an excepted advisory reaches a production dependency
- [ ] Tests for the filter script: excepted dev-only advisory passes; unexcepted advisory fails; expired exception fails; excepted advisory in a production path fails; malformed exception file fails
- [ ] Process-reduction ledger entry with the prior text and a revert note; actionlint passes; the gate goes green on the PR

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
