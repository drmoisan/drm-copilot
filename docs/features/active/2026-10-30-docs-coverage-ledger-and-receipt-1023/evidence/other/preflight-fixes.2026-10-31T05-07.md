# Preflight Fixes - Issue #1023 (PowerShell plan, version 0.3, preflight round 2)

Timestamp: 2026-10-31T05-07
Plan: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md
Directive: PREFLIGHT VALIDATION ONLY (single pass over the whole plan after the one permitted planner revision; no task executed, no checkbox changed)

## Fixes

1. `## Existing Tests Affected` row `TESTS/Invoke-DocsCommand.Tests.ps1` | Stale literal | The disposition read "updated in [P4-T2], test file only, to expect the five rows". The count assumes that only 1020 is on `epic/documentation-estate-tooling-integration` when the orchestrator merges it into the 1023 branch; a sibling wave-1 child (1021 `check`, 1022 `inventory`) can land first and change the row count. The text now reads "to expect the three 1023 rows in addition to the rows present at `MERGE_BASE`". The asserted behavior (the test expects the row set present after the three 1023 rows are inserted) is unchanged; the fix removes the count that depends on merge order.

## Round-2 contract checks (all confirmed; no change needed)

- 1034 receipt fields: [P4-T6] asserts `id`, `mode`, `repository`, `revision`, and `validation_result` on the persisted receipt text; spec `### Receipt` carries them; epic `### Enforcement notes from the two preparations of 1034` lists the same five.
- `DOCS_PAGE_*` prefix: no token `DOCS_PAGE_STALE` or `DOCS_PAGE_MISSING` remains in the 1023 folder (plan, spec, user story, both research files). 1023 names no 1021 page function (`Get-DocsPageCheckFinding`, `Test-DocsPageFrontMatter`), so the `Get-DocsPageComposedSchemaSet` pass-through condition does not arise.
- Renamed codes `DOCS_STALE_PAGE` and `DOCS_BOUND_PAGE_MISSING` occur only in 1023 files under `docs/features/`; no file of 1020, 1021, 1022, 1024, 1031, 1033, 1034, or 1036 defines either name. Plan `## Design Notes`, [P2-T2], [P3-T4], `## Pure Function Property Map`, spec `### validate`, `### Finding codes`, OQ-3, S13, and `## Contracts Later Children Must Honor` agree on both names and their owner functions.
- `analysis_method` per ledger entry: [P1-T2] `New-DocsLedgerEntry`, [P1-T4] `Merge-DocsLedgerSnapshotRef`, [P4-T4] `It 'records analysis_method from the current element'`; spec S3.
- Scanner precision limit as a `deferred` entry with an owner: [P1-T2] `New-DocsPrecisionLimitEntry`, [P4-T4] `set-disposition -Limit`; spec `### Scanner precision limits (D3)` and S4.
- `DOCS_SNAPSHOT_UNPINNED` fails closed: [P3-T4] and [P4-T6] unpinned cases; spec `### validate` and S12.
- Every repository anchor the plan cites exists on this tree: `New-EpicScopeResult` with the `PSUseShouldProcessForStateChangingFunctions` suppression, `$script:ConventionToken` in `ClaudeLibModuleConvention.Tests.ps1`, the two `It` names in `enforcement-hooks-no-python-invocation.Tests.ps1`, the Python test node IDs of the push-down contract suites, the Jest `it` title, `Invoke-PoshQCFormat`, `Invoke-PoshQCTest`, `generate_codex_agent_variants.py`, the three policy-audit templates, the purity hook patterns, and the policy files of [P0-T2].
- Every consumed 1020 symbol, the 1023 anchor comment, `Docs.TestSupport.psm1`, and the three 1020 suites named in [P0-T1] appear in the 1020 feature folder on this tree.
- Restricted tokens: a case-insensitive search for `r[g]f` and `fore[c]ast` over the 1023 folder returns no line.

## Validator

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md`
Result before the fix: `plan validation passed`, EXIT_CODE 0.
Result after the fix: `plan validation passed`, EXIT_CODE 0.
