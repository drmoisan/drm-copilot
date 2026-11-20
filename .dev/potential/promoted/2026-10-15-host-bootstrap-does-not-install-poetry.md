# host-bootstrap-does-not-install-poetry (Issue #930)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/host-bootstrap-does-not-install-poetry/ (Issue #930)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #930
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/930
- Last Updated: 2026-10-15
## Summary

Host bootstrap does not install poetry on a machine that lacks it. Recorded as out-of-scope item OD-3 by #887 (PR #919).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Run the host bootstrap on a machine without poetry.
2. `scripts/host-tools.manifest.json` has no poetry winget entry, and `Install-PoetryWithPip` is reachable only from the winget failure path.

## Expected Behavior

Bootstrap installs poetry when it is missing.

## Actual Behavior

Poetry is not installed; later bootstrap steps that run poetry fail.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #887 issue.md line 70: "no poetry winget entry is listed because no package ID was verified, and Install-PoetryWithPip is reachable only from the winget failure path, so bootstrap does not install poetry on a host that lacks it."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

See docs/features/active/*host-tools-manifest-and-bootstrap-behavior-887/issue.md (OD-3).

## Proposed Fix / Validation Ideas

- [ ] Verify a poetry winget package ID and add it to the manifest, or call `Install-PoetryWithPip` directly when poetry is absent.
- [ ] Add a test for the missing-poetry path.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch