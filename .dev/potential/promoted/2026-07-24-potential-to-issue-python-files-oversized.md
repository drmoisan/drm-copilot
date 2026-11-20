# potential-to-issue-python-files-oversized (Issue #406)

- Date captured: 2026-07-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-to-issue-python-files-oversized/ (Issue #406)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #406
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/406
- Last Updated: 2026-07-24
## Summary

`scripts/dev_tools/potential_to_issue.py` and its test file `tests/scripts/dev_tools/test_potential_to_issue.py` already exceed the repository's 500-line file-size policy (`.claude/rules/general-code-change.md`) before issue #401/PR #403 touched them; that fix deliberately deferred decomposing them (R3, non-blocking) to stay in scope and preserve TS/Python byte-parity of the fix it was landing.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (policy violation, not environment-specific)
- Python version: repository Poetry environment (`scripts/dev_tools`)
- Command/flags used: line count check against the two files
- Data source or fixture: `scripts/dev_tools/potential_to_issue.py`, `tests/scripts/dev_tools/test_potential_to_issue.py`

## Steps to Reproduce

1. Check out `main` at or after PR #403's merge commit.
2. Count lines in `scripts/dev_tools/potential_to_issue.py` and `tests/scripts/dev_tools/test_potential_to_issue.py`.
3. Observe both exceed the 500-line cap defined in `.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may exceed 500 lines").

## Expected Behavior

Both files are decomposed into smaller, cohesive modules under the 500-line cap, per the repository's file-size policy, while preserving behavior and the TypeScript/Python byte-parity the sibling implementation (`extensions/drm-copilot/src/.../promotion.ts` and its tests) depends on for the config-parity test pattern used elsewhere in this repo.

## Actual Behavior

Both files remain over the limit; this was called out but deliberately deferred as non-blocking (R3) during PR #403's remediation cycle to avoid scope creep on that fix, with rationale recorded at `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/other/r3-deferral.2026-07-22T21-30.md`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/other/r3-deferral.2026-07-22T21-30.md` for the original deferral rationale and line counts at time of PR #403.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Impact: policy/maintainability debt only; no behavior defect. Both files pass their toolchains (format/lint/type-check/test) as-is.

## Suspected Cause / Notes

- Pre-existing violation, not introduced by PR #403 — that PR only added to files already over the limit while fixing an unrelated behavior defect (bug-promotion issue-body template routing), and correctly declined to expand scope into a refactor.
- Any decomposition must preserve the TS/Python byte-parity contract the config-parity test enforces, and must not change the `buildIssueBody`/`potential_to_issue` behavior fixed in #401/#403.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: no new tests expected if this is a pure extract-and-move refactor; existing `test_potential_to_issue.py` suite (once itself decomposed) must continue passing unchanged.
- [x] Integration scenario to retest: full pytest suite for `scripts/dev_tools`, plus the config-parity test that checks TS/Python behavioral equivalence.
- [ ] Manual verification notes:

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
