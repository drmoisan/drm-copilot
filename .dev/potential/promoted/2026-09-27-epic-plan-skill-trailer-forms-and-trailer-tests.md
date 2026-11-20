# epic-plan-skill-trailer-forms-and-trailer-tests (Issue #745)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-plan-skill-trailer-forms-and-trailer-tests/ (Issue #745)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #745
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/745
- Last Updated: 2026-09-27
## Summary

#713 (PR #719) taught the preimplementation gate to accept commit trailers (single-quoted `$`, backtick, and `--trailer`), but some documentation and tests are still missing.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: planner and integration commits that carry `Co-Authored-By` and `Claude-Session` trailers
- Data source or fixture: #713 `evidence/other/follow-ups.md`

## Steps to Reproduce

1. `.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror do not document the Integration Commit Form or the trailer commit forms that #713 enabled.
2. No test covers `--trailer` taking a following `--` as its value (CR-4).
3. The CR-1 fix covers U+201A, U+201B and U+201E, but no denied-test row exercises them.
4. Helpers line 131 is 140 characters long.
5. Optional (decision D5): support commit messages fed by heredoc.

## Expected Behavior

Every skill that commits documents the accepted trailer forms, and every accepted and denied form has a test.

## Actual Behavior

As above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #713 follow-ups 1-6.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

#713 updated two skills; the epic-plan skill was out of its radius.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add the trailer forms to the epic-plan skill and its mirror; add the `--trailer --` test and the U+201A/B/E denied rows; wrap line 131 (keeping the four copies byte-identical and within the cap); decide D5.
- [ ] Integration scenario to retest: an epic-planner integration commit carries both trailers.
- [ ] Manual verification notes: none.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
