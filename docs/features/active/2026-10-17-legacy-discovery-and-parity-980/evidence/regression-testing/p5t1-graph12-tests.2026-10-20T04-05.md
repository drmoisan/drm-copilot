# P5-T1 graph12-tests

Timestamp: 2026-10-20T04-05
Command: poetry run pytest tests/discovery_runtime/test_coverage_report.py tests/discovery_runtime/test_coverage_report_contract.py -vv --cov=drm_copilot_discovery.coverage_report --cov=drm_copilot_discovery.coverage_population --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/graph12-coverage.json
EXIT_CODE: 0

Duration seconds: 36.832

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 49 items

tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-supporting-0-1] PASSED [  2%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-unassigned-0-0] PASSED [  4%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-blocked-1-0] PASSED [  6%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-supporting-1-1] PASSED [  8%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[uninspected-unassigned-0-0] PASSED [ 10%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows0] PASSED [ 12%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows1] PASSED [ 14%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[True] PASSED [ 16%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[False] PASSED [ 18%]
tests/discovery_runtime/test_coverage_report.py::test_unselected_inventory_and_multiple_feature_links_have_named_units PASSED [ 20%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[observed-1] PASSED [ 22%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[passed-1] PASSED [ 24%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[failed-0] PASSED [ 26%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[not-run-0] PASSED [ 28%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[blocked-0] PASSED [ 30%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[absent-0] PASSED [ 32%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[missing] PASSED [ 34%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[checksum] PASSED [ 36%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[stale] PASSED [ 38%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[uri-only] PASSED [ 40%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[environment] PASSED [ 42%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[claim] PASSED [ 44%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[truncation] PASSED [ 46%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[passed-without-proof] PASSED [ 48%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[target-owned] PASSED [ 51%]
tests/discovery_runtime/test_coverage_report.py::test_required_feature_count_is_distinct_from_client_obligations PASSED [ 53%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[inferred-high-0] PASSED [ 55%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[verified-low-1] PASSED [ 57%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[unknown-high-0] PASSED [ 59%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[open-1] PASSED [ 61%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[under-review-1] PASSED [ 63%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[resolved-0] PASSED [ 65%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_renders_exact_fields_and_null_empty_percentages PASSED [ 67%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[draft] PASSED [ 69%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[uninventoried] PASSED [ 71%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[invalid] PASSED [ 73%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_outputs_do_not_change_input_digest_or_semantic_counts PASSED [ 75%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[None] PASSED [ 77%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value1] PASSED [ 79%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value2] PASSED [ 81%]
tests/discovery_runtime/test_coverage_report_contract.py::test_aggregate_preflight_limits_nonascii_input_before_validation PASSED [ 83%]
tests/discovery_runtime/test_coverage_report_contract.py::test_preflight_excludes_large_report_output_but_not_authored_artifacts PASSED [ 85%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[empty-ledger] PASSED [ 87%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[absent] PASSED [ 89%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[missing-scope] PASSED [ 91%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[ambiguous] PASSED [ 93%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[16-False] PASSED [ 95%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[128-False] PASSED [ 97%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[1024-True] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py     115      2     50      4    96%   93->92, 238, 278, 320->319
packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py         111      0     26      0   100%
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           226      2     76      4    98%
Coverage JSON written to file SCRATCH/graph12-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
============================= 49 passed in 35.00s =============================

```
