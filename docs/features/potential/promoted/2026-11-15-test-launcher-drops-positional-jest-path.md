# test-launcher-drops-positional-jest-path (Issue #1192)

- Date captured: 2026-11-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/test-launcher-drops-positional-jest-path/ (Issue #1192)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1192
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1192
- Last Updated: 2026-11-15
## Summary

The test-execution-policy launcher (`run-test-suite.sh`, added by #1158) drops a positional Jest test-file argument, so a targeted Jest task check silently runs the whole Jest suite instead of the named file. The #1173 run reported it (PR #1185). It wastes time under the one-suite-at-a-time machine lock and makes a targeted check's evidence misleading.

## Environment

- OS/version: Windows 11 (local), Claude Code runtime
- Python version: not applicable
- Command/flags used: the launcher with the Jest lane and a positional test path, for example a single `extensions/drm-copilot/tests/...test.ts` file
- Data source or fixture: reported in PR #1185 (issue #1173) "Not fixed" notes

## Steps to Reproduce

1. Run a Jest task check through the launcher, passing one test file as a positional argument.
2. Observe that the whole Jest suite runs (thousands of tests) instead of the named file.

## Expected Behavior

Positional test paths (and other runner-supported selectors) are forwarded to Jest, so a targeted check runs only the named files; the launcher still applies its lock and lane rules.

## Actual Behavior

The positional path is not forwarded; the full suite runs with no warning.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1185 body.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The launcher's command builder (`.claude/hooks/test-execution-policy.ps1` and the bash launcher) likely builds the Jest command from lane configuration and ignores trailing positional arguments, or only forwards flags. Check the pytest and Pester legs for the same defect. Also fix the stale comment in `extensions/drm-copilot/jest.config.cjs` line 6 ("the five docs MCP modules"; there are now seven) in the same change.

## Proposed Fix / Validation Ideas

- [ ] Forward positional test paths for Jest (and confirm pytest and Pester behaviour), keeping the lock and lane exclusions
- [ ] Tests: a single-file Jest invocation builds a command naming only that file; no positional argument keeps the full-suite command; an integration or golden path is still refused
- [ ] Update the stale jest.config.cjs comment

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
