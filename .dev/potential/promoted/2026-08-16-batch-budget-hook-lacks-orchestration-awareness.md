# batch-budget-hook-lacks-orchestration-awareness (Issue #769)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/batch-budget-hook-lacks-orchestration-awareness/ (Issue #769)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #769
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/769
- Last Updated: 2026-09-29
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

Direction confirmed by the repository owner on 2026-09-29: the hook exists to signal that a change touching more than 3 production PowerShell files belongs on the large-path orchestrator. The large path has no cap on the number of files it may touch. Any instruction to split work into batches contradicts that purpose and must be removed.

- [ ] Make the hook orchestration-aware: when the session is executing on the orchestrated large path, the hook does not deny on file count. A checkpoint at `artifacts/orchestration/orchestrator-state.json` with a large-path route (`path_selected`/`route_id`) is one available signal; research must confirm the signal is readable from the hook's execution context, including isolated subagent worktrees.
- [ ] Replace the deny message: outside the large path, the 4th distinct production file is denied with a routing instruction (route the change to the orchestrator via `/orchestrate`), not a batching instruction. Remove "Split the work into a new batch" and the state-file-deletion remedy from the message.
- [ ] Remove the "per-batch cap in all modes" / "split the work into smaller batches" guidance from PowerShell policy surfaces (`.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.claude/skills/invoke-powershell-engineer/SKILL.md`, `powershell-change-budget-router`) and replace it with the routing rule.
- [ ] Apply the same change to the Codex mirror (`.codex/hooks/enforce-powershell-batch-budget.ps1`) and the bundled extension resource copies so parity tests hold.
- [ ] Unit coverage: a direct-mode session is still denied at the 4th production file with the routing message; a large-path orchestrated session is not denied at any file count.
- [ ] Out of scope for this item: `enforce-python-batch-budget.ps1` and the C# budget text, which follow the same pattern; record a follow-up.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
