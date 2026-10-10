# parallel-model-routing-admitted-item-source-and-absent-band-test (Issue #843)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-model-routing-admitted-item-source-and-absent-band-test/ (Issue #843)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #843
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/843
- Last Updated: 2026-10-08
## Summary

Two gaps remain after #532 (merged in the bug-burndown-2026-09-29 parallel run). First, an item admitted mid-run through `/parallel-add` has no defined source for its model routing: `parallel-add` records `complexity_band` on the orchestrator checkpoint, but `parallel-orchestrate` names only the planner checkpoint and the kickoff `## Item Summary` `complexity` column as band sources, and an admitted item appears in neither and carries no `model_routing_receipt`. Second, no test in either runtime covers an item whose `complexity_band` is absent while `complexity_assessment` and `model_routing_receipt` are present.

## Environment

- OS/version: Windows 11 Pro; any
- Python version: repository Poetry environment (Python validator); TypeScript validator under `extensions/drm-copilot`
- Command/flags used: `/parallel-add` during a running parallel run; `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`; `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts`
- Data source or fixture: origin/main at fb413fce; #532 code review `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/code-review.2026-10-02T05-30.md` lines 42-43

## Steps to Reproduce

1. Read `.claude/skills/parallel-add/SKILL.md` lines 59-62: step 2 records the admitted item's `complexity_band` on the orchestrator-checkpoint item "so step 3's edge derivation and the parent's model routing read the same band".
2. Read `.claude/skills/parallel-orchestrate/SKILL.md` lines 265-271 and 312-319: the parent reads `complexity_band` and `model_routing_receipt` from `artifacts/orchestration/parallel-planner-state.json`, with the kickoff `## Item Summary` `complexity` column as the only fallback. Neither section names the orchestrator checkpoint.
3. Search `.claude/skills/parallel-add/SKILL.md` for `model_routing_receipt`, `parallel-planner-state`, and `kickoff`: no match.
4. Read the absent-band tests: `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py:135-152` and `:358-375`, and `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts:91-106`. Each deletes all three routing fields together.

## Expected Behavior

- `parallel-orchestrate` names a band source for an item admitted through `/parallel-add` (for example the orchestrator-checkpoint `items[].complexity_band`, with spawn-time `Resolve-DelegationModel` re-resolution), or `/parallel-add` records a `model_routing_receipt` at admission.
- Both runtimes have a shared-literal case for an item whose `complexity_band` is absent while `complexity_assessment` and `model_routing_receipt` are present, pinning check 1 (`found: None.`) and the `complexity_band None.` rendering of checks 5 and 9.

## Actual Behavior

- No band or receipt source is named for an admitted item. The parent may fall back to the `opus` frontmatter default for such items, which is the defect class #532 addressed for planned items. This was established by reading both skills; it was not reproduced in a live run.
- The absent-band case is only tested with all three fields deleted. The TypeScript code review recorded the two uncovered branch arms of `sameValue` (`extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts:59-61` on main; line 60 in the review) as corresponding to this input shape (`evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md` in the #532 folder). Branch coverage is 92.59%, so this is a parity-pinning gap, not a threshold gap.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `parallel-add/SKILL.md:61-62`: "record the resulting `complexity_band` on the admitted orchestrator-checkpoint item so step 3's edge derivation and the parent's model routing read the same band." `parallel-orchestrate/SKILL.md:265-266`: "The parent reads each item's `complexity_band` and `model_routing_receipt` from the planner checkpoint `artifacts/orchestration/parallel-planner-state.json`." Verified by reading main at fb413fce.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

An item admitted mid-run can be routed on the default model rather than its assessed band. The test gap does not affect current behavior; it leaves the `None` rendering of checks 5 and 9 unpinned across runtimes.

## Suspected Cause / Notes

- Originating item: #532 (bug-burndown-2026-09-29 parallel run). Both findings are the two Minor (Non-blocking) rows of `code-review.2026-10-02T05-30.md` (lines 42-43), which states they "are suitable for follow-up and do not block this issue's acceptance criteria" (line 137). The run notes record the same two follow-ups for item 532.
- `issue.md` line 149 in the #532 folder left "Consider whether `/parallel-add` needs the same treatment" unchecked.
- Related but separate: spec Follow-ups 1-5 in the #532 `spec.md` (spawn-receipt recording, TypeScript port of floor/model resolution, re-assessment after plan amendment, `pwsh` grant, epic surface). Those are not part of this entry.
- No open issue covers either gap (checked `gh issue list --state open` on 2026-10-08).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add one shared-literal case per runtime (Python `test_validate_parallel_planner_state_routing.py`, TypeScript `parallel-planner-state-routing.test.ts`) for absent band with assessment and receipt present.
- [ ] Integration scenario to retest: admit an item through `/parallel-add` in a running parallel run and confirm the model passed on its `Agent(orchestrator)` spawn matches its assessed band.
- [ ] Manual verification notes: amend `parallel-orchestrate/SKILL.md` (both sections) and its mirrors under `extensions/drm-copilot/resources/claude-customizations/`, and the `parallel-add` contract tests, to name the admitted-item source.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
