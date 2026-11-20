# preimplementation-gate-bare-hash-record-resolution (Issue #606)

- Date captured: 2026-08-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-bare-hash-record-resolution/ (Issue #606)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #606
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/606
- Last Updated: 2026-08-30
- Work Mode: full-bug

## Summary

The preimplementation gate does not resolve the human-readable prompt token `Issue number: 644`, and its record resolver can select an earlier issue-only checkpoint record before examining a later exact feature-folder record. This can apply a terminal `merge_status` from the wrong record and block an otherwise ready epic or parallel operation.

## Environment

- OS/version: Windows PowerShell repository environment.
- Python version: Not applicable to the affected PowerShell hook; Python is required only for the Claude resource parity test.
- Command/flags used: PreToolUse processing through `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its mode helper.
- Data source or fixture: Orchestration checkpoint `features` and `parallel.items` JSON records, represented by literal JSON fixtures in the focused Pester suite.

## Steps to Reproduce

1. Supply a gate prompt containing `Issue number: 644` and invoke `Find-OrchestrationDelegationIssueNumber` through the mode helper.
2. Supply two checkpoint records in collection order: an earlier record whose `issue_num` matches the prompt and whose `merge_status` is terminal, followed by a record whose normalized `feature_folder` exactly matches the target and whose status is non-terminal.
3. Evaluate epic `features` or parallel `items` readiness through the preimplementation gate.

## Expected Behavior

The keyed prompt form resolves to issue number `644`. The resolver searches every record for an exact normalized feature-folder match before using issue-number fallback, so the later exact-folder non-terminal record is selected and readiness is allowed. If no folder matches, the first matching issue record remains the fallback.

## Actual Behavior

`Issue number: 644` is not accepted by the keyed parser because its pattern does not allow whitespace between `issue` and `number`. In record collections, the one-pass resolver returns an earlier issue-only match before a later exact folder match; if that earlier record has terminal `merge_status`, the gate denies with the established `PREIMPLEMENTATION_GATE_BLOCKED` diagnostic and `merge_status` predicate.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot (not required; deterministic literal JSON Pester fixtures reproduce the behavior).
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED` remains the required diagnostic prefix when the selected checkpoint record fails readiness.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The shared helper `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` owns both defects. `Find-OrchestrationDelegationIssueNumber` accepts underscore and hyphen variants but not the spaced `Issue number` form. `Find-OrchestrationModeRecord` combines folder and issue matching in one iteration, allowing issue fallback to preempt a later exact folder match. The bundled hook under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` must remain raw-byte identical to the root hook.

## Proposed Fix / Validation Ideas

- [ ] Update the keyed issue pattern to accept whitespace while preserving case-insensitivity, optional `#`, colon/equal separators, existing underscore/hyphen forms, and the digits-only capture.
- [ ] Change the shared resolver to complete a normalized feature-folder search before iterating issue-number fallback candidates, preserving the first matching issue record only when no folder matches.
- [ ] Add focused Pester coverage for `Issue number: 644`, mixed prose with bare `#638`, and earlier issue-only terminal siblings preceding later exact-folder records in both epic and parallel paths.
- [ ] Apply identical mode-helper bytes to the root and bundled Claude hook copies; run focused Pester and the root-to-bundle Claude resource parity test after the checkpoint permits implementation commands.
- [ ] Preserve the current `PREIMPLEMENTATION_GATE_BLOCKED` diagnostic prefix and predicate-based reason contract without appending resolution details.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
