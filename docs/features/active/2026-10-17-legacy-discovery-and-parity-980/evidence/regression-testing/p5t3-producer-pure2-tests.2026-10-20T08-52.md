# P5-T3 producer tests

Timestamp: 2026-10-20T08-51

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.completion_report -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_completion_report.py`

EXIT_CODE: 0

Output Summary: PASS; 29.391 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 35 items

tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-structural-Structural validation] PASSED [  2%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-discovery-complete-Discovery completion] PASSED [  5%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-parity-complete-Parity completion] PASSED [  8%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-planning-Planning prerequisite] PASSED [ 11%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-structural-Structural validation] PASSED [ 14%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-discovery-complete-Discovery completion] PASSED [ 17%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-parity-complete-Parity completion] PASSED [ 20%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-planning-Planning prerequisite] PASSED [ 22%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[none] PASSED [ 25%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[discovery-complete] PASSED [ 28%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[parity-complete] PASSED [ 31%]
tests/discovery_runtime/test_completion_report.py::test_exact_actions_preserve_every_original_diagnostic_index PASSED [ 34%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order0] PASSED [ 37%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order1] PASSED [ 40%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order2] PASSED [ 42%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[agent-output] PASSED [ 45%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[] PASSED [ 48%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[custom] PASSED [ 51%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[None] PASSED [ 54%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[True] PASSED [ 57%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[mode5] PASSED [ 60%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[list] PASSED [ 62%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[member] PASSED [ 65%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[validity] PASSED [ 68%]
tests/discovery_runtime/test_completion_report.py::test_public_preflight_requires_a_captured_snapshot PASSED [ 71%]
tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[ascii] PASSED [ 74%]
tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[unicode] PASSED [ 77%]
tests/discovery_runtime/test_completion_report.py::test_grouping_reserves_work_before_visiting_supplied_findings PASSED [ 80%]
tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[False] PASSED [ 82%]
tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[True] PASSED [ 85%]
tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[coverage] PASSED [ 88%]
tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[parity] PASSED [ 91%]
tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[schema_version-2.0.0] PASSED [ 94%]
tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[artifact_kind-completion-report] PASSED [ 97%]
tests/discovery_runtime/test_completion_report.py::test_empty_legacy_counts_remain_compatibility_only PASSED [100%]

============================= 35 passed in 27.58s =============================

```
