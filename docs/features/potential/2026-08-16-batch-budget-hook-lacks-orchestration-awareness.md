# batch-budget-hook-lacks-orchestration-awareness (Potential Bug)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

`enforce-powershell-batch-budget.ps1` enforces a direct-mode routing cap against every session, including sessions that are already running the orchestrated large path. The cap exists to route over-budget work to an orchestrator; once that routing has happened, continuing to enforce the cap denies the very path the policy prescribes.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: any `Write`/`Edit` of a `.ps1`/`.psm1`/`.psd1` file inside an orchestrated run
- Data source or fixture: `.claude/state/powershell-batch-budget.<session_id>.json`

## Steps to Reproduce

1. Start a full orchestration (`/orchestrate`) for work that legitimately requires more than three production PowerShell files.
2. Let the orchestrator complete promotion, research, feature documents, atomic planning, and preflight, then begin execution.
3. Observe the hook deny the 4th distinct production PowerShell path, regardless of how the plan phases the work.

## Expected Behavior

The cap is a routing gate, not a chunking rule. `.claude/skills/powershell-change-budget-router/SKILL.md` states that `>2` production files means the **large path** and that "a direct implementation agent must reject over-budget requests and route to orchestrator." Once work is executing on the large path under an orchestrator, the routing requirement is already satisfied and the cap has no remaining purpose. An orchestrated run should not be denied.

## Actual Behavior

The hook has no notion of orchestration. A repository-wide grep for `orchestrat`, `direct-mode`, or `route` in `.claude/hooks/enforce-powershell-batch-budget.ps1` returns nothing. It keys its state solely on `$env:CLAUDE_SESSION_ID` (line 193), and subagents inherit the parent session id, so the count accumulates across an entire orchestration and never resets at a phase or delegation boundary.

Observed in the issue-475 run, which required roughly 25 production and 20 test PowerShell files to port 79 validator checks at complete parity. The hook denied the 4th distinct production path partway through Phase 3 of 17. The run had already been routed to the orchestrated large path before the first file was written — it was the escalation target the cap exists to produce.

The run's workaround was to delete the state file at each phase boundary, which is one of the three remedies the hook's own deny message names (line 137). That kept every phase within 3 production and 3 test files and never raised the cap, but it treats the symptom.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: deny message at line 137 — "Split the work into a new batch, raise the cap via CLAUDE_POWERSHELL_BUDGET_<KIND> environment variable with approved scope, or reset the batch by deleting <StateFile>."

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Any orchestrated PowerShell change exceeding three production files hits this. That is precisely the class of change the large path exists to handle, so the hook is most obstructive exactly where it should be inert. The workaround is available and documented, but it requires an agent to delete enforcement state — an action that reads as a bypass to any reviewer who encounters it without context, and which invites genuine bypasses to be rationalized the same way.

## Suspected Cause / Notes

The hook implements the numeric half of the change-budget contract without the routing half. `powershell-change-budget-router` frames the cap as a decision procedure with two outcomes — proceed in direct mode, or escalate to the orchestrator. The hook only implements "deny past N," which is correct for a direct-mode agent and wrong for an orchestrated one.

A related consequence surfaced downstream: the run recorded the state resets under the checkpoint's `local_execution_overrides`, and a separate completion check requires that array to be empty before a PR may be created. Classifying the resets as overrides was inaccurate — no cap was raised and no policy was overridden — but the inaccuracy was a reasonable reading given the hook offers no orchestrated-run vocabulary.

The same question likely applies to `enforce-python-batch-budget.ps1`, which follows the same session-keyed pattern; it was not examined.

## Proposed Fix / Validation Ideas

- [ ] Make the hook orchestration-aware: when the session is executing an orchestrated plan, the routing requirement is already met and the cap should not deny. A checkpoint at `artifacts/orchestration/orchestrator-state.json` with a large-path `route_id` is one available signal.
- [ ] Alternatively, scope the batch to the plan phase rather than the session, so phase boundaries reset the counter without any state deletion.
- [ ] If neither is adopted, amend the deny message so an orchestrated run is told what the correct action is, rather than being offered three remedies of which only one applies.
- [ ] Unit coverage areas: a direct-mode session is still denied at the 4th production file; an orchestrated session is not.
- [ ] Review `enforce-python-batch-budget.ps1` for the same defect.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
