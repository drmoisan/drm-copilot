# Fail-Before Evidence (issue #1006, AC-09)

Timestamp: 2026-10-31T08-11
Task: P1-T5
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_generic_contracts.py -q -p no:cacheprovider; sh SCRATCH/issue-1006-ps.sh issue-1006-pester-files.ps1 -File tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 (one Pester process, Invoke-Pester, no coverage)
EXIT_CODE: 1
ExpectedExitCode: 1
Code state: pre-change production code (no production file edited; both new test files untracked).

Output Summary:
- pytest: 19 failed, 2 passed in 0.14s.
  - Failed: `test_generic_contract_token_is_recognized[Sheet1]`, `[sheet12]`, `[CHART3]` (attribute `is_generic_contract_token` absent); `test_non_generic_token_is_rejected` for all ten rows (`Sheet`, `Sheet1a`, `MySheet1`, `Sheet1.Range`, empty, `Sheet` plus U+FF11, `Sheet1` plus U+212A, U+017F plus `heet1`, `Book1`, `Table1`); `test_generic_contract_stems_are_sheet_and_chart`; `test_extract_contract_identifiers_drops_a_generic_token`; `test_extract_write_intent_contracts_drops_a_generic_token`; `test_normalize_declared_radius_drops_a_recorded_generic_contract`; `test_issue_1006_scenario_has_no_hard_edge[self-hosted]`; `test_issue_1006_scenario_has_no_hard_edge[bundled]`.
  - Hard reason kinds reported by `test_issue_1006_scenario_has_no_hard_edge` (both configurations): `Hard edges with reason kinds: {(41, 42): ['path_overlap', 'shared_surface_overlap', 'contract_dependency']}`.
  - Passed: `test_issue_1006_scenario_tolerance_zero_equals_detection[self-hosted]` and `[bundled]`.
- Pester (`BlastRadiusGenericContract.Tests.ps1`): TOTAL 23, PASSED 2, FAILED 21; Pester process exit 1.
  - Failed: the 3 recognition rows and 10 rejection rows (`Test-GenericContractToken` not recognized); `'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source'`; `'exports Test-GenericContractToken from BlastRadiusTokenShape'` and `from BlastRadiusExtraction`; the three contract-filtering site rows (each returned `@('ParseLedger', 'Sheet1')`); `'reports no hard edge for the issue 1006 scenario under the self-hosted table'` and `under the bundled table`.
  - Hard reason kinds reported by the Pester no-hard-edge rows (both tables): `41~42: path_overlap,shared_surface_overlap,contract_dependency` (the edge record's `reason` holds only `path_overlap`).
  - Passed: `'keeps every detected conflict as an edge at tolerance zero under the self-hosted table'` and `under the bundled table`.
