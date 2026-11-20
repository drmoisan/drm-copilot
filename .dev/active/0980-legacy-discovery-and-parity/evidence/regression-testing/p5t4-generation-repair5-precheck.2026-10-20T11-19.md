# P5-T4 generation precheck

Timestamp: 2026-10-20T11-18

Command: `poetry run pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching tests/discovery_runtime/test_acceptance_generation_limits.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-modes] tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[approved] tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration tests/discovery_runtime/test_acceptance_generation_limits.py::test_two_complete_rule_passes_are_independent_of_candidate_count tests/discovery_runtime/test_acceptance_decisions.py::test_imported_source_retains_original_provenance_and_distinct_target_owner`

EXIT_CODE: 0

Output Summary: PASS; 32.889 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 11 items

tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[32-16] PASSED [  9%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[4096-16] PASSED [ 18%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_coordinate_comparisons_reserve_text_work_before_matching[4096-32] PASSED [ 27%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-modes] PASSED [ 36%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[approved] PASSED [ 45%]
tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations PASSED [ 54%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[applicable] PASSED [ 63%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[unspecified] PASSED [ 72%]
tests/discovery_runtime/test_acceptance_decisions.py::test_mobile_and_custom_modes_follow_actual_configuration[not-applicable] PASSED [ 81%]
tests/discovery_runtime/test_acceptance_generation_limits.py::test_two_complete_rule_passes_are_independent_of_candidate_count PASSED [ 90%]
tests/discovery_runtime/test_acceptance_decisions.py::test_imported_source_retains_original_provenance_and_distinct_target_owner PASSED [100%]

============================= 11 passed in 31.34s =============================

```
