# P5-T1 final graph-reverse

Timestamp: 2026-10-20T05-08
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/discovery_runtime/test_coverage_report_contract.py tests/discovery_runtime/test_coverage_report.py --cov=drm_copilot_discovery.coverage_report --cov=drm_copilot_discovery.coverage_population --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.coverage_scope_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p5t1-repaired-final-050607-graph-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 6; elapsed 106.245 seconds; completed nodes 58; timeout=False.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 58 items

tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_renders_exact_fields_and_null_empty_percentages PASSED [  1%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[draft] PASSED [  3%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[uninventoried] PASSED [  5%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[invalid] PASSED [  6%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_outputs_do_not_change_input_digest_or_semantic_counts PASSED [  8%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[None] PASSED [ 10%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value1] PASSED [ 12%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value2] PASSED [ 13%]
tests/discovery_runtime/test_coverage_report_contract.py::test_aggregate_preflight_limits_nonascii_input_before_validation PASSED [ 15%]
tests/discovery_runtime/test_coverage_report_contract.py::test_preflight_excludes_large_report_output_but_not_authored_artifacts PASSED [ 17%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[empty-ledger] PASSED [ 18%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[absent] PASSED [ 20%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[missing-scope] PASSED [ 22%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[ambiguous] PASSED [ 24%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[16-False] PASSED [ 25%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[128-False] PASSED [ 27%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[1024-True] PASSED [ 29%]
tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[reports-] PASSED [ 31%]
tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[generated/views-nested/] PASSED [ 32%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-documentation-False] PASSED [ 34%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/nested/coverage-report.md-documentation-False] PASSED [ 36%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports-other/coverage-report.md-documentation-True] PASSED [ 37%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/Reports/coverage-report.md-documentation-True] PASSED [ 39%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/coverage-report.md-documentation-True] PASSED [ 41%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-source-True] PASSED [ 43%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-test-True] PASSED [ 44%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-supporting-0-1] PASSED [ 46%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-unassigned-0-0] PASSED [ 48%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-blocked-1-0] PASSED [ 50%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-supporting-1-1] PASSED [ 51%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[uninspected-unassigned-0-0] PASSED [ 53%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows0] PASSED [ 55%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows1] PASSED [ 56%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[True] PASSED [ 58%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[False] PASSED [ 60%]
tests/discovery_runtime/test_coverage_report.py::test_unselected_inventory_and_multiple_feature_links_have_named_units PASSED [ 62%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[observed-1] PASSED [ 63%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[passed-1] PASSED [ 65%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[failed-0] PASSED [ 67%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[not-run-0] PASSED [ 68%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[blocked-0] PASSED [ 70%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[absent-0] PASSED [ 72%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[missing] PASSED [ 74%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[checksum] PASSED [ 75%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[stale] PASSED [ 77%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[uri-only] PASSED [ 79%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[environment] PASSED [ 81%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[claim] PASSED [ 82%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[truncation] PASSED [ 84%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[passed-without-proof] PASSED [ 86%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[target-owned] PASSED [ 87%]
tests/discovery_runtime/test_coverage_report.py::test_required_feature_count_is_distinct_from_client_obligations PASSED [ 89%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[inferred-high-0] PASSED [ 91%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[verified-low-1] PASSED [ 93%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[unknown-high-0] PASSED [ 94%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[open-1] PASSED [ 96%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[under-review-1] PASSED [ 98%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[resolved-0] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py      115      2     50      4    96%   93->92, 238, 278, 320->319
packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py          111      0     26      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py     142     24     78     22    77%   112, 174, 184, 194, 196, 203->216, 210, 221, 229-236, 242->exit, 260-269, 311-317, 325, 331->333, 339, 350, 366-372, 376, 383, 390, 416, 418
packages\discovery-runtime\src\drm_copilot_discovery\validation.py               150     46     52     10    59%   90, 185, 187, 191, 199->244, 256, 295->312, 326-413, 436, 438->440, 446, 460
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            518     72    206     36    81%
Coverage JSON written to file SCRATCH\issue-980-p5t1-repaired-final-050607-graph-coverage.raw.json
======================= 58 passed in 105.09s (0:01:45) ========================

```
