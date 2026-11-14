# parallel-close-records-pr-blocked-by-routing-receipt (Issue #1182)

- Date captured: 2026-11-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-close-records-pr-blocked-by-routing-receipt/ (Issue #1182)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1182
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1182
- Last Updated: 2026-11-14
## Summary

At Run Closing, the parallel-orchestrator cannot open the run-records pull request. Its `Agent(pr-author)` delegation is denied by `enforce-model-routing-receipt.ps1` with `MODEL_ROUTING_RECEIPT_BLOCKED`. The receipt check reads the orchestrator checkpoint of the resolved worktree. The coordinator root of a parallel run deliberately holds only `parallel-orchestrator-state.json` and no `orchestrator-state.json`, so the receipt can never be found. The `parallel-orchestrator` agent definition authorizes `Agent(pr-author)` for exactly this Run Closing records PR, so the documented path cannot be completed.

## Environment

- OS/version: Windows 11 (local), Claude Code runtime
- Python version: not applicable
- Command/flags used: parallel-orchestrator Run Closing: `Agent(pr-author)` with the branch label `parallel/<slug>-plan`
- Data source or fixture: run harness-learnings-2026-11-09, coordinator branch `parallel/harness-learnings-2026-11-09-plan` (head c295f89d1), closing state recorded as deferral LV3

## Steps to Reproduce

1. Run a parallel run to completion, so that every item is merged.
2. At Run Closing, delegate `Agent(pr-author)` from the parallel-orchestrator for the records PR of the `parallel/<slug>-plan` branch.
3. Observe the denial: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint`.

## Expected Behavior

The Run Closing records PR is delegable. The model-routing receipt gate looks up the receipt in the parallel checkpoint, in the same way that epic scope (issue #663) looks it up in the epic checkpoint. Alternatively, a narrowly scoped leg, matching the cleanup-consolidation leg (#1026) and the docs-estate leg (#1169), admits the records PR when the branch label equals the parallel run's plan branch and the diff is limited to `docs/features/parallel/<slug>/`.

## Actual Behavior

The delegation is denied, and the run ends with its records unmerged on the coordinator branch. The post-merge worktree cleanup report is also deferred, because it runs only after the records PR merges.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The receipt gate in `.claude/hooks/enforce-model-routing-receipt.ps1` has an epic-scope branch (`Resolve-EpicScopeCheckpoint`), a cleanup leg (`Test-ModelRoutingCleanupDelegation`) and a docs-estate leg (`Get-ModelRoutingDocsEstateDecision`), but no parallel-scope branch. The `pr-author` preflight hook (`enforce-pr-author-skill.ps1`) and the merge gate may have the same gap for the records PR; check them together. Mirrors: the Codex hooks and the push-down bundles.

## Proposed Fix / Validation Ideas

- [ ] Add a parallel-scope resolution: a prompt whose branch label equals the `parallel/<slug>-plan` branch of the session-root `parallel-orchestrator-state.json` reads `model_routing_receipts` from that checkpoint; the parallel-orchestrator records a pr-author receipt there at Run Closing
- [ ] Verify that the pr-author preflight and the records-PR merge path work end to end for the same scope
- [ ] Pester coverage for allow and deny, including a non-plan branch label, a missing receipt, and an epic label unaffected
- [ ] After merge, open the pending records PR for harness-learnings-2026-11-09 through the fixed path

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
