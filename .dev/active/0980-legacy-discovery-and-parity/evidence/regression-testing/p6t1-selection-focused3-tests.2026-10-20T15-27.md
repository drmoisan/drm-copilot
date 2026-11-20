# P6-T1 renderer tests

Timestamp: 2026-10-20T15-26

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.service_selection -m pytest -v --tb=short --maxfail=6 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service_selection.py`

EXIT_CODE: 0

Output Summary: PASS; 37.281 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 29 items

tests/discovery_runtime/test_service_selection.py::test_default_selection_preserves_generator_all_source_semantics PASSED [  3%]
tests/discovery_runtime/test_service_selection.py::test_imported_source_resolves_without_local_owner_preference[False] PASSED [  6%]
tests/discovery_runtime/test_service_selection.py::test_imported_source_resolves_without_local_owner_preference[True] PASSED [ 10%]
tests/discovery_runtime/test_service_selection.py::test_ambiguous_source_names_require_explicit_repository PASSED [ 13%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[missing] PASSED [ 17%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[duplicate] PASSED [ 20%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[target] PASSED [ 24%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[revision] PASSED [ 27%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[empty] PASSED [ 31%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_membership_never_selects_a_fallback[untyped] PASSED [ 34%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_selector_types_are_rejected[selectors0] PASSED [ 37%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_selector_types_are_rejected[selectors1] PASSED [ 41%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_selector_types_are_rejected[selectors2] PASSED [ 44%]
tests/discovery_runtime/test_service_selection.py::test_invalid_feature_selector_types_are_rejected[selectors3] PASSED [ 48%]
tests/discovery_runtime/test_service_selection.py::test_malformed_public_values_are_rejected PASSED [ 51%]
tests/discovery_runtime/test_service_selection.py::test_selector_work_is_reserved_before_index_construction PASSED [ 55%]
tests/discovery_runtime/test_service_selection.py::test_platform_projection_reuses_candidates_and_exact_ready_membership PASSED [ 58%]
tests/discovery_runtime/test_service_selection.py::test_unknown_platform_preserves_existing_failure_semantics[False] PASSED [ 62%]
tests/discovery_runtime/test_service_selection.py::test_unknown_platform_preserves_existing_failure_semantics[True] PASSED [ 65%]
tests/discovery_runtime/test_service_selection.py::test_null_platform_is_never_synthesized_as_requested_coordinate PASSED [ 68%]
tests/discovery_runtime/test_service_selection.py::test_platform_selectors_reject_invalid_types_and_duplicates[selectors0] PASSED [ 72%]
tests/discovery_runtime/test_service_selection.py::test_platform_selectors_reject_invalid_types_and_duplicates[selectors1] PASSED [ 75%]
tests/discovery_runtime/test_service_selection.py::test_platform_selectors_reject_invalid_types_and_duplicates[selectors2] PASSED [ 79%]
tests/discovery_runtime/test_service_selection.py::test_platform_selectors_reject_invalid_types_and_duplicates[selectors3] PASSED [ 82%]
tests/discovery_runtime/test_service_selection.py::test_platform_selector_limits_precede_model_reconstruction[count] PASSED [ 86%]
tests/discovery_runtime/test_service_selection.py::test_platform_selector_limits_precede_model_reconstruction[bytes] PASSED [ 89%]
tests/discovery_runtime/test_service_selection.py::test_platform_selector_limits_precede_model_reconstruction[unicode] PASSED [ 93%]
tests/discovery_runtime/test_service_selection.py::test_platform_selector_limits_precede_model_reconstruction[work] PASSED [ 96%]
tests/discovery_runtime/test_service_selection.py::test_public_generation_composes_with_source_and_platform_selection PASSED [100%]

============================= 29 passed in 34.79s =============================

```
