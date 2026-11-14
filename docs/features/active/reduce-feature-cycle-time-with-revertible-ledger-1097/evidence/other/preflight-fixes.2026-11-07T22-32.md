# Preflight Fixes: Stage F Plan

Timestamp: 2026-11-07T22-32
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T06-17.md
Signal: PREFLIGHT: REVISIONS REQUIRED (two substantive defects returned to the planner; listed below the fixes)

## Fixes Made in Place

1. [P1-T2] | typo (count) | "update the three Python tests of `## Test Dispositions` other than `_RULE_TOKENS`" became "the two Python tests". The table marks three Python items Updated: `_RULE_TOKENS`, the `_ROWS` row `g13` of `test_plan_gate_document_parity.py`, and `test_plan_branch_builds_context_and_calls_two_channel_entry_point`. Two remain once `_RULE_TOKENS` is excluded. The set of tests is unchanged.
2. [P2-T2] | citation completion | The sentence on swept tokens now also names `PCW-SURFACE-<Id>`. The `COPILOT-PLANNING` row of `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` sweeps `.github/agents/atomic_planning.agent.md`, which this task edits. The constraint is the same: the new text carries no forbidden token.

## Substantive Defects Returned

1. `## Design` `**Result check.**` with [P0-T5] and [P2-T4] | scope of the result check | The #1019 scope covers only the plan paths that the kickoff lists. It does not cover the in-flight remediation plans in those child folders. Fetched remote refs hold eleven `remediation-plan.<stamp>.md` files. One, `2026-10-30-docs-authoring-workflow-1037/remediation-plan.2026-11-07T17-30.md`, carries a UTC review stamp that can sort at or after a commit-minute cutoff in America/New_York. Measured now, it holds 18 tasks and 80 lines, so its outcome is unchanged. A later cycle of comparable size, such as the 27 to 33 tasks of the `1034` remediation plans, would change its outcome, and [P2-T4] would not detect it.
2. [P2-T5] with [P2-T6] | design (commit-minute race) | The last clock read in [P2-T5] precedes the staging and `git commit` of the entry, row, patch, and artifacts. A minute boundary in that gap makes [P2-T6] stop with no remedy, because history is not amended.

## Verification Performed (no test suite run)

- Branch-current validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` passed. The MCP plan validator passed.
- G13 inventory of `docs/features/active/`: 88 plan files, scanned with the module's `plan_size` and `has_size_justification` and a cutoff of `2026-11-07T17-20`. No file changes its outcome. The only unrecognized name is `remediation-plan-ledger.2026-11-07T06-50.md`, which holds 4 tasks and 104 lines.
- #1019 kickoff (`docs/features/epics/documentation-estate-tooling/epic-kickoff.md` at `origin/epic/documentation-estate-tooling-integration`): 11 listed plans, all stamped 2026-10-30, so the legacy pair applies under any cutoff.
- Ledger prototype in a `git archive` copy under SCRATCH. Before the change, the ledger check and the full chain over `0001` to `0007` were valid, with `-StopBefore` `0006` and `0001` valid. With a representative `0008` added (stored patch from `git diff --cached --binary --no-renames HEAD`, 15 sections, including two create hunks and edits of the `**Size guideline.**` bullet and the planner clause), `Test-ProcessReductionLedger`, the full chain, and `-StopBefore` `0008`, `0006`, and `0001` all returned `IsValid` true with 0 errors.
