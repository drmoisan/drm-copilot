# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T12-07
Review-Verdict: HALT_NON_REMEDIABLE
Remediation-Path: full
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T12-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T12-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T12-07.md`
Head reviewed: `b71c1d0649373d6083ff70f501383ff79b8f343f` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`)

This file supersedes `remediation-inputs.2026-11-07T10-50.md`, the stage D review, because the orchestrator reads the highest timestamp.

No finding below is `autonomous`, so no remediation handoff is triggered and no remediation plan target is created. The path line above records that a light cycle would not apply.

## Findings requiring remediation

### F1 — The `[E]` policy-read removal is incomplete on the held review prompt

Severity: Blocking
Remediability: human_decision_required
Remediability-Evidence: The remaining bullet contains the words `canonical baseline location`, and the coordinator baseline hold forbids changing baseline text until the owner decides; the edit can be made only after that decision is relayed.
Finding-Scope: contained

- Files: `.github/prompts/review-feature.prompt.md` line 52 and `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md` line 52.
- Problem: the bullet `` `phase0-instructions-read.md` exists in the canonical baseline location with the required metadata fields. `` remains, so the criterion "[E] The policy-read task, its artifact requirement, and the hook's policy-read check are removed in one commit with its entry; ..." evaluates PARTIAL. Every other part of the criterion holds, and entry `0005` already discloses the held surface.
- Required change, once the owner decides: remove the bullet from both copies in a commit whose subject carries `reduction: 0005`; in the same commit add a revert block for `.github/prompts/review-feature.prompt.md` and a `## Files Changed` line for both copies to entry `0005`, and remove the "Not changed, and held" sentence; add a `PCW-SURFACE` row for the prompt. If the owner decides the bullet stays, the criterion text needs an owner amendment instead.
- Verification required: `cmp` of the prompt and its bundle; `Test-ProcessReductionLedger` valid; the new block replays to the parent text; one `Invoke-PoshQCParallelTest` run with 0 failures; re-review.

## Non-remediation items (record only)

From `code-review.2026-11-07T12-07.md`. None stops the merge and none needs a cycle.

- N1, Minor: the invariant 8 path read at `OrchestratorStateRemediationAccounting.psm1` line 316, and the reads at lines 330, 334, 339, and 363, are not pinned by a corpus row. Recommended: a row with a mis-cased path key and a `design` finding expecting only the invariant 2 error, in the same commit as F1 or in stage F. Class if pursued: `autonomous`.
- N2, Nit: the `reduction: 0005` commit also added the stage F draft plan, removed by `664b0dba8`. No action.

## CI

CI run 42370409304, dispatched on head `b71c1d064`, was `in_progress` when this review was written. The orchestrator reads its result; S9 owns `ci_gate.conclusion` at the final head.

## Constraints for the next step

- These review artifacts are uncommitted in the item worktree and lie inside the feature folder.
- Entries `0004` and `0005` read `Merge commit: pending (PR #1097)`. The orchestrator replaces the number after the pull request opens. That file lies outside the feature folder, so CI and `ci_gate.head_sha` must then be read at the new head.
- Tests run in parallel only, per `spec.md` `## Testing Rule`.
- Do not change baseline, coverage-comparison, or `N/A - no pre-change run` text until the owner decides.
