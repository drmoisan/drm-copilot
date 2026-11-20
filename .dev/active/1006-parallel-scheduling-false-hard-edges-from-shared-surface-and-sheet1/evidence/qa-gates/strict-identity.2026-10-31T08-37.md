# Strict-Identity Re-Runs (issue #1006, AC-22)

Timestamp: 2026-10-31T08-37
Task: P8-T13

Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_tolerance_zero_equals_conflict tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_strict_identity_over_existing_conflict_fixtures tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_tolerance_zero_output_equals_conflict_only_output -q -p no:cacheprovider -rs
EXIT_CODE: 0
Output Summary: 8 passed (parametrized nodes of the four passing tests), 1 skipped. The skip is `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case`, reported by its unconditional `@pytest.mark.skip(reason=TOLERANCE_SKIP_REASON)` marker (`Issue #722 tolerance layer absent at execution start ...`). Zero failures.

Command: sh SCRATCH/issue-1006-ps.sh issue-1006-strict.ps1 (one Pester process over tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 and tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1)
EXIT_CODE: 0
Output Summary: Context `'Strict identity'`: 15 rows, 15 passed, 0 failed. Describe `'Blast-radius historical runs'`: 9 rows, 9 passed, 0 failed. Both files: 60 total, 60 passed.

Command: git diff --quiet <MERGE_BASE> -- <the seven test files named in P8-T13>
EXIT_CODE: 0
Output Summary: none of the seven strict-identity test files differs from MERGE_BASE (merge base of origin/main and HEAD, derived at run time).
