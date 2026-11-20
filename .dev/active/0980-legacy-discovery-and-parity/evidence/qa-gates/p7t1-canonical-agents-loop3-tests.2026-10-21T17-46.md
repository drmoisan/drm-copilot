# P7-T1 canonical agents tests

Timestamp: 2026-10-21T17-46

Command: `WORKSPACE\.venv\Scripts\python.exe -m pytest -v --durations=10 --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/scripts/dev_tools/test_discovery_agent_contracts.py`

EXIT_CODE: 0

Output Summary: PASS; 0.407 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 43 items

tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_metadata_is_canonical_domain_neutral_and_model_independent[legacy-parity-analyst] PASSED [  2%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_metadata_is_canonical_domain_neutral_and_model_independent[runtime-characterization-analyst] PASSED [  4%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_metadata_is_canonical_domain_neutral_and_model_independent[requirements-reconciler] PASSED [  6%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_metadata_is_canonical_domain_neutral_and_model_independent[migration-coverage-reviewer] PASSED [  9%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_tool_allowlist_is_exact_and_has_no_root_or_general_capability[legacy-parity-analyst] PASSED [ 11%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_tool_allowlist_is_exact_and_has_no_root_or_general_capability[runtime-characterization-analyst] PASSED [ 13%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_tool_allowlist_is_exact_and_has_no_root_or_general_capability[requirements-reconciler] PASSED [ 16%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_tool_allowlist_is_exact_and_has_no_root_or_general_capability[migration-coverage-reviewer] PASSED [ 18%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_output_kinds_and_profile_keys_form_a_closed_boundary[legacy-parity-analyst] PASSED [ 20%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_output_kinds_and_profile_keys_form_a_closed_boundary[runtime-characterization-analyst] PASSED [ 23%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_output_kinds_and_profile_keys_form_a_closed_boundary[requirements-reconciler] PASSED [ 25%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_role_output_kinds_and_profile_keys_form_a_closed_boundary[migration-coverage-reviewer] PASSED [ 27%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_selected_reads_remain_bounded_and_cannot_claim_truncated_completeness[legacy-parity-analyst] PASSED [ 30%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_selected_reads_remain_bounded_and_cannot_claim_truncated_completeness[runtime-characterization-analyst] PASSED [ 32%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_selected_reads_remain_bounded_and_cannot_claim_truncated_completeness[requirements-reconciler] PASSED [ 34%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_selected_reads_remain_bounded_and_cannot_claim_truncated_completeness[migration-coverage-reviewer] PASSED [ 37%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_prepare_and_launch_require_exact_external_routing_and_provenance[legacy-parity-analyst] PASSED [ 39%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_prepare_and_launch_require_exact_external_routing_and_provenance[runtime-characterization-analyst] PASSED [ 41%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_prepare_and_launch_require_exact_external_routing_and_provenance[requirements-reconciler] PASSED [ 44%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_prepare_and_launch_require_exact_external_routing_and_provenance[migration-coverage-reviewer] PASSED [ 46%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_exact_grants_preserve_baseline_pins_members_and_prospective_validation[legacy-parity-analyst] PASSED [ 48%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_exact_grants_preserve_baseline_pins_members_and_prospective_validation[runtime-characterization-analyst] PASSED [ 51%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_exact_grants_preserve_baseline_pins_members_and_prospective_validation[requirements-reconciler] PASSED [ 53%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_exact_grants_preserve_baseline_pins_members_and_prospective_validation[migration-coverage-reviewer] PASSED [ 55%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_managed_memory_and_read_results_cannot_expand_denied_authority[legacy-parity-analyst] PASSED [ 58%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_managed_memory_and_read_results_cannot_expand_denied_authority[runtime-characterization-analyst] PASSED [ 60%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_managed_memory_and_read_results_cannot_expand_denied_authority[requirements-reconciler] PASSED [ 62%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_managed_memory_and_read_results_cannot_expand_denied_authority[migration-coverage-reviewer] PASSED [ 65%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_finalization_preserves_ordered_root_launch_and_native_stop_obligations[legacy-parity-analyst] PASSED [ 67%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_finalization_preserves_ordered_root_launch_and_native_stop_obligations[runtime-characterization-analyst] PASSED [ 69%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_finalization_preserves_ordered_root_launch_and_native_stop_obligations[requirements-reconciler] PASSED [ 72%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_finalization_preserves_ordered_root_launch_and_native_stop_obligations[migration-coverage-reviewer] PASSED [ 74%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_unavailable_native_authority_blocks_without_local_user_fallback[legacy-parity-analyst] PASSED [ 76%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_unavailable_native_authority_blocks_without_local_user_fallback[runtime-characterization-analyst] PASSED [ 79%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_unavailable_native_authority_blocks_without_local_user_fallback[requirements-reconciler] PASSED [ 81%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_unavailable_native_authority_blocks_without_local_user_fallback[migration-coverage-reviewer] PASSED [ 83%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_nonreviewer_reports_location_grants_only_the_exact_manifest[legacy-parity-analyst] PASSED [ 86%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_nonreviewer_reports_location_grants_only_the_exact_manifest[runtime-characterization-analyst] PASSED [ 88%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_nonreviewer_reports_location_grants_only_the_exact_manifest[requirements-reconciler] PASSED [ 90%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_legacy_analyst_preserves_facts_and_accounts_for_selected_components PASSED [ 93%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_runtime_analyst_requires_supplied_evidence_and_honest_manual_states PASSED [ 95%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_reconciler_cannot_approve_history_or_write_derived_feature_contracts PASSED [ 97%]
tests/scripts/dev_tools/test_discovery_agent_contracts.py::test_reviewer_can_finalize_valid_failure_without_completion_authority PASSED [100%]

============================ slowest 10 durations =============================

(10 durations < 0.005s hidden.  Use -vv to show these durations.)
============================= 43 passed in 0.12s ==============================

```
