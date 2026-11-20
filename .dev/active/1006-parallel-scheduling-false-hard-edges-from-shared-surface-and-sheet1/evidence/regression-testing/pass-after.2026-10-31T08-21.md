# Pass-After Evidence (issue #1006, Phase 4 regression set)

Timestamp: 2026-10-31T08-21
Task: P4-T6
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_generic_contracts.py tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_blast_radius_mandate_reads.py -q -p no:cacheprovider; sh SCRATCH/issue-1006-ps.sh issue-1006-pester-files.ps1 -File BlastRadiusGenericContract.Tests.ps1,BlastRadius.Regression452.Tests.ps1,BlastRadius.TruthTable.Tests.ps1,BlastRadius.KeyPartition.Tests.ps1,BlastRadius.Parity.Tests.ps1 (all under tests/scripts/claude-lib/blast-radius/, one Pester process)
EXIT_CODE: 0
Code state: Phases 2, 3, and 4 applied (generic-contract predicate in both runtimes, both truth tables edited).

Output Summary:
- pytest: 61 passed, 1 skipped, 0 failed. Skipped: `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` (unconditional tolerance skip marker).
  - Passed: `test_issue_1006_scenario_has_no_hard_edge[self-hosted]`, `test_issue_1006_scenario_has_no_hard_edge[bundled]`, `test_issue_1006_scenario_tolerance_zero_equals_detection[self-hosted]`, `test_issue_1006_scenario_tolerance_zero_equals_detection[bundled]`.
- Pester: TOTAL 160, PASSED 159, FAILED 0, SKIPPED 1; process exit 0.
  - Passed: `'reports no hard edge for the issue 1006 scenario under the self-hosted table'`, `'reports no hard edge for the issue 1006 scenario under the bundled table'`, `'keeps every detected conflict as an edge at tolerance zero under the self-hosted table'`, `'keeps every detected conflict as an edge at tolerance zero under the bundled table'` (Context `'Issue 1006 scenario'`).
