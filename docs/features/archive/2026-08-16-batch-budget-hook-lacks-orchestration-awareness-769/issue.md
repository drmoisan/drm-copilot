# batch-budget-hook-lacks-orchestration-awareness (Issue #769)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/batch-budget-hook-lacks-orchestration-awareness/ (Issue #769)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #769
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/769
- Last Updated: 2026-09-29
- Work Mode: full-bug

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

## Acceptance Criteria

Work mode is `full-bug`; the authoritative acceptance-criteria source is `spec.md` (`## Acceptance Criteria`). The list below mirrors it for reference and is kept identical in text.

- [x] AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude hook allows the first three distinct production PowerShell paths and denies the 4th; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `/orchestrate`.
- [x] AC-2: In direct mode, the Codex hook denies the 4th distinct production PowerShell path; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
- [x] AC-3: Neither hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, `deleting`, or the state-file path; asserted by unit tests for both hooks.
- [x] AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither hook denies any PowerShell path for file count at any number of distinct production files, and neither hook writes state for those paths.
- [x] AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both hooks.
- [x] AC-6: A missing checkpoint, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both hooks, and no checkpoint condition causes a non-zero hook exit.
- [x] AC-7: Test PowerShell paths are never denied for count and are not recorded in state, in either mode, in both hooks.
- [x] AC-8: `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both hooks.
- [x] AC-9: Existing behaviors hold in both hooks: fail-closed deny on an unreadable envelope, out-of-root discard without a state write, repeated-path allow without a state write, deny-only entry-point output, and the `Get-PowerShellBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
- [x] AC-10: The Codex hook contains no `$env:CLAUDE_` read (`legacy-codex-hook-contracts.Tests.ps1` passes).
- [x] AC-11: The checkpoint is supplied to both hooks through an injectable seam, and no new or modified test creates a temporary file.
- [x] AC-12: New tests exist at `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` and pass, and the updated `enforce-powershell-batch-budget.Tests.ps1` and `codex-batch-budget-hooks.Tests.ps1` pass.
- [x] AC-13: A case-insensitive search for `per-batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, and `per-batch cap in all modes` returns no match in files whose path contains `powershell` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, and `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/Powershell DI Unit Test Engineer.agent.md` and its mirror.
- [x] AC-14: Every PowerShell routing statement in the Claude and Copilot surfaces listed in In scope item 5 states `1-3` production files for the small/direct path and more than 3 for the large path, and none of those files states `1-2` or `>2` as the PowerShell threshold.
- [x] AC-15: Routing instructions in `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, and `.claude/skills/invoke-powershell-engineer/SKILL.md` name `/orchestrate` and do not name `powershell-orchestrator`.
- [x] AC-16: `.claude/skills/invoke-powershell-engineer/SKILL.md` no longer offers the `budget: prod=<N>, test=<M>` override input.
- [x] AC-17: Every generated variant of `.codex/agents/powershell-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
- [x] AC-18: Bundle parity holds: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and pack-manifest checks in `legacy-codex-hook-contracts.Tests.ps1` pass, and every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
- [x] AC-19: `.github/copilot-instructions.md` and `.github/instructions/*` are unchanged on the branch relative to `main`.
- [x] AC-20: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` pass.
- [x] AC-21: PoshQC format -> analyze -> test passes with zero analyzer errors, line coverage >= 85% for both hooks, and no coverage regression on changed lines.
- [x] AC-22: The hook docstrings describe the routing model and document the stale-checkpoint limitation and the #673 hygiene mitigation, and contain no per-batch or state-file-deletion reset guidance.
- [x] AC-23: Follow-up 1 (Python and C# budget hooks and text) and Follow-up 2 (Codex routing resolver PowerShell budget) are recorded as potential entries under `docs/features/potential/`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
