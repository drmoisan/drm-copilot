# parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-items-fail-completion-on-promotion-receipts/ (Issue #849)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #849
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/849
- Last Updated: 2026-10-08
## Summary

In parallel run bug-burndown-2026-09-29, the child orchestrator completion validator reported missing `new_potential_bug_entry` and `potential_to_issue` MCP receipts for items whose GitHub issue existed before the run (#647, #734, #532, and #338 per the run coordinator; the run notes also name #623 and #739 as the same class). The `issue_adoption` waiver added by #509 (PR #809) exists, but the parallel planning and execution surfaces do not direct children to record it, and the waiver for the promotion-entry tool requires a potential record that an adopted issue may not have.

## Environment

- OS/version: Windows 11 Pro 10.0.26300, Claude Code parallel run bug-burndown-2026-09-29 (2026-09-29 to 2026-10-08)
- Python version: repository Poetry environment
- Command/flags used: `validate_orchestration_artifacts orchestrator-state` completion check (routing-contract check) on each item's child checkpoint
- Data source or fixture: run notes `artifacts/orchestration/parallel-run-notes.bug-burndown-2026-09-29.json` in the run worktree, `item_notes` entries 647, 734, 532

## Steps to Reproduce

1. Plan a parallel run whose items are existing issue numbers (parallel-plan item intake over issue numbers).
2. Let a preparation-mode or execution child orchestrator complete without calling `new_potential_bug_entry` or `potential_to_issue`, because the issue already exists.
3. Run the completion validation on the child checkpoint.

## Expected Behavior

An item whose issue existed before the run completes without a promotion receipt residual. Either the parallel skills direct each child to record a valid `issue_adoption` object, or the parallel planner records it at intake, and the waiver is satisfiable for an issue that has no potential record.

## Actual Behavior

The run notes record the residual as non-blocking for each affected item:

- 647: "Child completion validator residual: missing new_potential_bug_entry/potential_to_issue MCP receipts (issue pre-existed); same class as 623/739."
- 734: "Completion-gate residual: missing promotion MCP receipts (issue pre-existed)."
- 532: "Completion-gate residual: promotion receipts (issue pre-existed)."

The validator message for each tool is `Checkpoint missing successful MCP receipt: <tool>.` (`.claude/rules/orchestrator-state.md:262`). #338 (run 2026-10-08, after #509 merged) was reported by the coordinator with the same residual; the child checkpoints are gitignored and were not re-read for this entry.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: run notes `item_notes` quoted above. #509 / PR #809 merged 2026-10-01T17:24Z; the residual was still recorded for items completed after that time (#734, #532 on 2026-10-02; #338 on 2026-10-08).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every parallel-run item is an existing issue, so the completion gate reports a residual on each one unless the child knows to record `issue_adoption`. Coordinators must classify the residual by hand, which hides real receipt gaps in the same output.

## Suspected Cause / Notes

- The waiver exists: `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (`resolve_issue_adoption`, line 260; waivable set lines 64-66), with ports in `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts` and `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`. It is documented in `.claude/skills/orchestrate/SKILL.md:442-444`, `.claude/skills/feature-promotion-lifecycle/SKILL.md:48-51`, and `.claude/rules/orchestrator-state.md:229-262`.
- `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/parallel-orchestrate/SKILL.md` contain no reference to `issue_adoption` (verified with `git grep` on fb413fce), so the parallel planner and orchestrator do not pass this requirement to child orchestrators.
- Rule 9 (`_orchestrator_state_issue_adoption.py:235-257`; `orchestrator-state.md:258`) requires `potential_record` under `docs/features/potential/` to waive `new_potential_bug_entry`. An issue filed by hand or consolidated from other issues (for example #734, which consolidates #336 and #511) may have no single potential record, so the promotion-entry receipt cannot be waived.
- Related closed issues: #405 (TS validator promotion-type parity), #509 (adoption waiver). No open issue covers this residual.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: if rule 9 is relaxed for `origin` `filed_before_orchestration` or `transferred`, add corpus cases under `tests/fixtures/orchestrator_state_issue_adoption/` for all three runtimes.
- [ ] Integration scenario to retest: a parallel item for a pre-existing issue completes with zero `Checkpoint missing successful MCP receipt` errors.
- [ ] Manual verification notes: add an `issue_adoption` instruction to `parallel-plan` (preparation-mode delegation prompt) and `parallel-orchestrate` (execution delegation), or have the planner write the record at intake after a `gh issue view`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
