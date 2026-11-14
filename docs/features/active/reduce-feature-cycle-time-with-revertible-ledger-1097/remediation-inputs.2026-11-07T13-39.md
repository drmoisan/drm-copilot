# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T13-39
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T12-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T12-07.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T12-07.md`
Head reviewed: `b71c1d0649373d6083ff70f501383ff79b8f343f` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`)
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T13-39.md`

This file supersedes `remediation-inputs.2026-11-07T12-07.md`. It is written by the orchestrator, not by a review: the stage E review halted on F1 as `human_decision_required`, and the owner decided on 2026-11-07, relayed by the coordinator, that the place 18 bullet is outside the baseline hold. F1 is therefore now `autonomous`. The finding text below is the review's, unchanged except for its class.

## Findings requiring remediation

### F1 — The `[E]` policy-read removal is incomplete on the review prompt

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The owner ruled on 2026-11-07 that the bullet is outside the baseline hold, so the edit needs no further decision.
Finding-Scope: contained

- Files: `.github/prompts/review-feature.prompt.md` and `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md`.
- Problem: the bullet naming `phase0-instructions-read.md` in the canonical baseline location remains, so the `[E]` policy-read removal criterion is PARTIAL.
- Required change: remove the bullet from both copies in a commit whose subject carries `reduction: 0005`. In the same commit, add a revert block for `.github/prompts/review-feature.prompt.md` and a `## Files Changed` line for both copies to entry `0005`, and remove the "Not changed, and held" sentence. Add a `PCW-SURFACE` row for the prompt.
- Verification required: byte comparison of the prompt and its bundle; `Test-ProcessReductionLedger` valid; the new block replays to the parent text; one `Invoke-PoshQCParallelTest` run with 0 failures; re-review.

## Non-remediation items (recommended for the same cycle)

- N1, Minor, from `code-review.2026-11-07T12-07.md`: the invariant 8 path reads in `OrchestratorStateRemediationAccounting.psm1` (`Get-RemediationLightCycleError` and its neighbors) are not pinned by a corpus row. Add a row with a mis-cased path key and a `design` finding that expects only the invariant 2 error, in all three runtimes, updating the corpus count pins and entry `0003` in the same commit with `reduction: 0003`.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run; one `pytest -n auto` run, because a corpus row changes Python parity results; one full Jest coverage run, because the TypeScript parity suite reads the corpus.
- No other baseline, coverage-comparison, or `N/A - no pre-change run` text is changed in this cycle. Restoring the test baseline is the next stage, not this cycle.
- No Epic #1019 folder is edited.
