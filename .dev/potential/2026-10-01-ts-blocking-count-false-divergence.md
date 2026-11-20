# ts-blocking-count-false-divergence (Potential Bug)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 3 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Rollout & Follow-up`; research section 5.1)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The three orchestrator-state validators disagree on a remediation cycle whose `blocking_count` is the boolean `false` and whose `exit_condition_met` is `true`. Python and PowerShell treat `false` as zero, so they accept the cycle. TypeScript compares with `!== 0`, so it reports the exit-with-blocking-findings violation.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: orchestrator-state validation through the Python CLI, the PowerShell module, and the TypeScript MCP validator
- Data source or fixture: a checkpoint whose `remediation_loop.cycles[]` entry has `"blocking_count": false` and `"exit_condition_met": true`

## Steps to Reproduce

1. Build a checkpoint with one remediation cycle carrying `"blocking_count": false` and `"exit_condition_met": true`.
2. Validate it with the Python validator and the PowerShell `OrchestratorStateReceipts.psm1` remediation-loop check.
3. Validate it with the TypeScript validator (`extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`).

## Expected Behavior

All three runtimes return the same error list for the same checkpoint.

## Actual Behavior

Python (`cycle.get("blocking_count") != 0`) and PowerShell (`Test-PythonZeroEquivalent` in `OrchestratorStateCheckpointValue.psm1`) accept the cycle. TypeScript (`cycle["blocking_count"] !== 0`) reports a violation.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none captured; the divergence was identified by source reading during #484 research and kept out of the #484 parity corpus so that existing TypeScript output stayed byte-identical.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

TypeScript uses strict equality where Python relies on `False == 0`. Decide which behavior is intended (reject a boolean `blocking_count` everywhere, or treat it as zero everywhere) and align the runtimes.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add a boolean `blocking_count` case to the shared remediation-loop parity corpus once the intended behavior is chosen
- [ ] Integration scenario to retest: the three parity test readers (pytest, Jest, Pester)
- [ ] Manual verification notes: confirm the back-compat corpus output stays unchanged for non-boolean values

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
