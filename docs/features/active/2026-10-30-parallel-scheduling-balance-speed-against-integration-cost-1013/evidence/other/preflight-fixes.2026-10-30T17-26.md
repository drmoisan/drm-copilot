# Preflight Fixes

Timestamp: 2026-10-30T17-26
Plan: docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md
Plan version reviewed: 0.6 (82 tasks)
Prior record: evidence/other/preflight-fixes.2026-10-30T17-14.md

Every fix below edits task text only. No task was added, removed, reordered, or checked. After the fix, the plan passes the installed MCP validator (`validate_orchestration_artifacts`, artifact type `plan`).

## Prior Defect Verified

- spec AC-08 and AC-26 previously stated that `test_absent_key_reads_as_strict` passes unchanged. The current text of both, of D-6 and D-7 `Configuration`, of `## Test Strategy`, and of user-story US-02 states that the test passes with only its `weights` literal gaining `"contract": 1`, and that `'reads an absent key as strict'` passes unchanged. The tree confirms both premises: the Python test compares against a `ConflictTolerance` literal whose `weights` names four weights, and the Pester row indexes the four existing names only. P2-T5 makes the one literal edit, P3-T1 and P5-T1 leave both tests unchanged, and P2-T6 leaves the Pester row unchanged. Resolved.

## Fix 1

- Task: [P1-T9]
- Defect class: ambiguous acceptance wording (validator-blind; the correction keeps the assertion's meaning)
- Before: "every test that exercises a new symbol, the `contract` weight, or a committed `combination_threshold_percent` or `contract` value fails", with no statement for rejection cases the pre-change reader already satisfies.
- After: the same sentence, followed by a statement that the P1-T7 negative, float, string, boolean, and unknown-sibling rejections and the P1-T8 unknown-extra-weight-name rejection are regression guards that may pass and are recorded by node ID as passing at the branch base.
- Reason: `config_conflict_tolerance` calls `_require_names` on the member before reading any value, so a config carrying `combination_threshold_percent` with any value raises `ValueError` whose message lists that name as unknown, which satisfies the P1-T7 rejection assertions (`TypeError` or `ValueError` whose message contains `combination_threshold_percent`). A weights map carrying `contract` plus an extra name raises `ValueError` naming `config["conflict_tolerance"]["weights"]`, which satisfies the P1-T8 unknown-name assertion. Because P1-T7 and P1-T8 configs now carry `contract`, these cases could be read as exercising the `contract` weight and the acceptance as unsatisfiable. The clarification names them; every test of new behavior still has to fail.

## Observations (spec text, outside the plan; no plan change)

- spec `## Test Strategy` "New fixtures" still counts three combination fixtures and one overlay corpus file; with D-7 there are four (`combination-contract-only.json`) and two (`conflict-tolerance-contract-weight.json`). The "New test files" list does not name `test_blast_radius_contract_weight.py` or `BlastRadiusScheduling.ContractWeight.Tests.ps1`. Both are listed in the Complete File List (entries 55 to 58) and in the AC text, and each has a plan task, so no acceptance criterion is affected.

## Checks Without Findings

- The `possible_overlap` search over the seven `Weight-map set` roots returns exactly the 26 files the plan names.
- All 75 Complete File List entries are named by full repository-relative path in the plan.
- Every existing test, Pester row, Context, helper, and production symbol the plan cites is present in the tree; the remaining citations are files the plan creates or #1006 symbols, which P0-T1 and P0-T4 gate.
- No scheduling, write-intent, or drift fixture radius carries a non-empty `contracts` list; the historical fixture `followups-2026-09-27.json` pins cost 52 for edge 708-710 and carries `CodeCoverage.Path` in two radii, consistent with P0-T4 (c).
- No task writes under `docs/features/parallel/`.
- Pre-Mortem carries all seven labels; `## Size Justification` and `## Test Plan` are present.
