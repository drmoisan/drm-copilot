# parallel-add-children-not-told-to-record-issue-adoption (Issue #885)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-add-children-not-told-to-record-issue-adoption/ (Issue #885)
- Origin: issue #849 (PR #880), follow-up recorded in its feature folder; overlapped #843 (PR #869) at the time; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #885
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/885
- Last Updated: 2026-10-11
## Summary

`/parallel-add` preparation children admitted for an existing GitHub issue are not instructed to record a top-level `issue_adoption` object. Issue #849 added that instruction to `/parallel-plan` and `/parallel-orchestrate` but left `.claude/skills/parallel-add/SKILL.md` unchanged, so an item admitted through `/parallel-add` can still fail completion on the missing `potential_to_issue` and promotion-entry receipts that #849 fixed for planned items.

## Environment

- OS/version: any (skill contract text)
- Python version: n/a
- Command/flags used: `/parallel-add` with an issue-number item against a running parallel run
- Data source or fixture: main at 2ef8d361; `.claude/skills/parallel-add/SKILL.md` (188 lines) and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`

## Steps to Reproduce

1. Open a parallel run in open mode and run `/parallel-add` with an existing GitHub issue number.
2. Observe the preparation-mode child `Agent(orchestrator)` prompt built from `.claude/skills/parallel-add/SKILL.md` step 2 (lines 53-61).
3. Let the child reach its completion gate.

## Expected Behavior

The preparation child receives the same issue-adoption line that `/parallel-plan` sends (`.claude/skills/parallel-plan/SKILL.md:116`, "Issue adoption: this item's GitHub issue already exists..."), records a top-level `issue_adoption` object, and passes the completion gate without promotion receipts.

## Actual Behavior

`.claude/skills/parallel-add/SKILL.md` contains no match for `issue_adoption`, "issue-adoption" or "issue adoption". Step 2 reads "Run preparation through a preparation-mode child `Agent(orchestrator)` run, reusing the existing `route_id: preparation` contract UNCHANGED: promotion, research, ..." with no adoption instruction. The bundled copy is identical. By the #849 analysis, such a child "does not record a top-level `issue_adoption` object and can still fail completion on the missing `potential_to_issue` and promotion-entry receipts."

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/follow-up-parallel-add.2026-10-09T01-33.md`: "`/parallel-add` preparation children for issue-number items do not receive the issue-adoption instruction ... `.claude/skills/parallel-add/SKILL.md` was not edited." It was excluded as "out of scope for issue #849 because it overlaps with the work tracked in issue #843."
- Comparison: the instruction is present at `.claude/skills/parallel-plan/SKILL.md:47`, `:116`, `:153` and `.claude/skills/parallel-orchestrate/SKILL.md:262`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. Items admitted mid-run for existing issues can fail completion and require manual checkpoint repair. Planned items are not affected.

## Suspected Cause / Notes

- #849 deliberately left `/parallel-add` unchanged because #843 was editing the same step. #843 is now closed by PR #869, which added only a one-clause complexity-band clarification to step 2, so the overlap no longer applies.
- The execution child is already covered by kickoff element 4 in `parallel-orchestrate`; only the preparation child is affected.

## Proposed Fix / Validation Ideas

- [ ] Add the `/parallel-plan` `## Preparation Fan-Out` issue-adoption line to `/parallel-add` step 2 for issue-number items, and mirror it into the bundled copy.
- [ ] Unit coverage areas: extend `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` to assert the line in both `parallel-add` copies.
- [ ] Integration scenario to retest: admit an existing issue via `/parallel-add` and confirm the preparation child's checkpoint carries `issue_adoption` and passes its completion gate.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch