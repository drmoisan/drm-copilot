# P5-T5 renderer precheck

Timestamp: 2026-10-20T12-50

Command: `poetry run coverage run --branch --data-file=<SCRATCH>\p5t5-renderer-repair1-precheck.coverage --source=drm_copilot_discovery.gherkin,drm_copilot_discovery.acceptance_render_text -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization tests/discovery_runtime/test_acceptance_tags.py::test_approved_target_trace_retains_original_decision_and_owner tests/discovery_runtime/test_acceptance_render_limits.py`

EXIT_CODE: 0

Output Summary: PASS; 12.037 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 18 items

tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[bytes] PASSED [  5%]
tests/discovery_runtime/test_gherkin.py::test_escape_and_text_work_are_reserved_before_serialization[work] PASSED [ 11%]
tests/discovery_runtime/test_acceptance_tags.py::test_approved_target_trace_retains_original_decision_and_owner PASSED [ 16%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[ascii] PASSED [ 22%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[two-byte] PASSED [ 27%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_file_capacity_counts_raw_utf8_without_phantom_newline[wide] PASSED [ 33%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[ascii] PASSED [ 38%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[two-byte] PASSED [ 44%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_bundle_capacity_sums_raw_utf8_paths_and_content[wide] PASSED [ 50%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_path_measurement_rejects_invalid_scalars_and_capacity_types PASSED [ 55%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[depth] PASSED [ 61%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[nodes] PASSED [ 66%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[records] PASSED [ 72%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_container_limits_reject_before_encoder[sequence] PASSED [ 77%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_json_unicode_scalar_guard_precedes_encoding PASSED [ 83%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_escaped_output_work_is_reserved_before_detachment_and_encoding[False] PASSED [ 88%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_escaped_output_work_is_reserved_before_detachment_and_encoding[True] PASSED [ 94%]
tests/discovery_runtime/test_acceptance_render_limits.py::test_tag_prefix_and_existing_tag_are_reserved_before_joining PASSED [100%]

============================= 18 passed in 9.55s ==============================

```
