# P5-T3 final producer

Timestamp: 2026-10-20T09-54
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/discovery_runtime/test_completion_planning.py::test_malformed_core_diagnostic_cannot_pass_prospective_mutation_validation tests/discovery_runtime/test_completion_planning.py::test_paired_views_support_dry_run_replacement_and_exact_unchanged_skip tests/discovery_runtime/test_completion_planning.py::test_planning_reserves_captured_file_comparisons_before_projection tests/discovery_runtime/test_completion_planning.py::test_planning_requires_an_actual_captured_workspace tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[True] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[custom] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[agent-output] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[list] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[member] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[md] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[json] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[identifier] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[kind] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[duplicate] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[extra] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[one] tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[none] tests/discovery_runtime/test_completion_planning.py::test_public_builder_delegates_one_exact_mode_and_identifier tests/discovery_runtime/test_completion_report.py::test_empty_legacy_counts_remain_compatibility_only tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[artifact_kind-completion-report] tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[schema_version-2.0.0] tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[parity] tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[coverage] tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[True] tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[False] tests/discovery_runtime/test_completion_report.py::test_grouping_reserves_work_before_visiting_supplied_findings tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[unicode] tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[ascii] tests/discovery_runtime/test_completion_report.py::test_public_preflight_requires_a_captured_snapshot tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[validity] tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[member] tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[list] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[mode5] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[True] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[None] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[custom] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[] tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[agent-output] tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order2] tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order1] tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order0] tests/discovery_runtime/test_completion_report.py::test_exact_actions_preserve_every_original_diagnostic_index tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[parity-complete] tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[discovery-complete] tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[none] "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-planning-Planning prerequisite]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-parity-complete-Parity completion]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-discovery-complete-Discovery completion]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-structural-Structural validation]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-planning-Planning prerequisite]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-parity-complete-Parity completion]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-discovery-complete-Discovery completion]" "tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-structural-Structural validation]" --cov=drm_copilot_discovery.completion_report --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov=drm_copilot_discovery.report_models --cov=drm_copilot_discovery.report_rendering --cov=scripts.dev_tools.discovery.completion_report --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p5t3-final-094649-producer-coverage.json`
EXIT_CODE: 0
Output Summary: Stage 6; 159.347 seconds; 54 completed nodes; timeout=False; changed bindings=0.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 54 items

tests/discovery_runtime/test_completion_planning.py::test_malformed_core_diagnostic_cannot_pass_prospective_mutation_validation PASSED [  1%]
tests/discovery_runtime/test_completion_planning.py::test_paired_views_support_dry_run_replacement_and_exact_unchanged_skip PASSED [  3%]
tests/discovery_runtime/test_completion_planning.py::test_planning_reserves_captured_file_comparisons_before_projection PASSED [  5%]
tests/discovery_runtime/test_completion_planning.py::test_planning_requires_an_actual_captured_workspace PASSED [  7%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[True] PASSED [  9%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[] PASSED [ 11%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[custom] PASSED [ 12%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[agent-output] PASSED [ 14%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[list] PASSED [ 16%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[member] PASSED [ 18%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[md] PASSED [ 20%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[json] PASSED [ 22%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[identifier] PASSED [ 24%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[kind] PASSED [ 25%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[duplicate] PASSED [ 27%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[extra] PASSED [ 29%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[one] PASSED [ 31%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[none] PASSED [ 33%]
tests/discovery_runtime/test_completion_planning.py::test_public_builder_delegates_one_exact_mode_and_identifier PASSED [ 35%]
tests/discovery_runtime/test_completion_report.py::test_empty_legacy_counts_remain_compatibility_only PASSED [ 37%]
tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[artifact_kind-completion-report] PASSED [ 38%]
tests/discovery_runtime/test_completion_report.py::test_legacy_render_rejects_versioned_authority_envelopes[schema_version-2.0.0] PASSED [ 40%]
tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[parity] PASSED [ 42%]
tests/discovery_runtime/test_completion_report.py::test_explicit_v2_cannot_pass_through_legacy_helpers[coverage] PASSED [ 44%]
tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[True] PASSED [ 46%]
tests/discovery_runtime/test_completion_report.py::test_legacy_summary_counts_actual_rows_without_readiness[False] PASSED [ 48%]
tests/discovery_runtime/test_completion_report.py::test_grouping_reserves_work_before_visiting_supplied_findings PASSED [ 50%]
tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[unicode] PASSED [ 51%]
tests/discovery_runtime/test_completion_report.py::test_action_encoding_is_bounded_before_a_summary_can_escape[ascii] PASSED [ 53%]
tests/discovery_runtime/test_completion_report.py::test_public_preflight_requires_a_captured_snapshot PASSED [ 55%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[validity] PASSED [ 57%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[member] PASSED [ 59%]
tests/discovery_runtime/test_completion_report.py::test_malformed_summary_arguments_fail_explicitly[list] PASSED [ 61%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[mode5] PASSED [ 62%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[True] PASSED [ 64%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[None] PASSED [ 66%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[custom] PASSED [ 68%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[] PASSED [ 70%]
tests/discovery_runtime/test_completion_report.py::test_unsupported_modes_fail_before_any_preflight[agent-output] PASSED [ 72%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order2] PASSED [ 74%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order1] PASSED [ 75%]
tests/discovery_runtime/test_completion_report.py::test_action_index_permutation_property[order0] PASSED [ 77%]
tests/discovery_runtime/test_completion_report.py::test_exact_actions_preserve_every_original_diagnostic_index PASSED [ 79%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[parity-complete] PASSED [ 81%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[discovery-complete] PASSED [ 83%]
tests/discovery_runtime/test_completion_report.py::test_planning_exposes_only_configured_prerequisite[none] PASSED [ 85%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-planning-Planning prerequisite] PASSED [ 87%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-parity-complete-Parity completion] PASSED [ 88%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-discovery-complete-Discovery completion] PASSED [ 90%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[True-structural-Structural validation] PASSED [ 92%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-planning-Planning prerequisite] PASSED [ 94%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-parity-complete-Parity completion] PASSED [ 96%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-discovery-complete-Discovery completion] PASSED [ 98%]
tests/discovery_runtime/test_completion_report.py::test_mode_and_availability_do_not_invent_readiness[False-structural-Structural validation] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\completion_report.py         95      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py            138     29     64     14    76%   51, 95, 97, 99, 101, 119, 125, 142, 148, 162, 165-168, 172, 203, 214-223, 297-302, 320, 336-339
packages\discovery-runtime\src\drm_copilot_discovery\report_rendering.py          17      3      4      1    71%   28-31
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                89     24     44     17    66%   95, 97, 115, 122, 130-137, 142, 154, 156-160, 162-169, 171, 205, 208, 210, 211->213, 218-221, 242, 245
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      98     11     22      8    82%   145, 147, 151, 163->208, 220->231, 243->246, 263-293, 296->305
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            437     67    158     40    80%
Coverage JSON written to file SCRATCH\p5t3-final-094649-producer-coverage.json
======================= 54 passed in 158.31s (0:02:38) ========================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module scripts.dev_tools.discovery.completion_report was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")

```
