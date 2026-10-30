# P6-T1 renderer precheck

Timestamp: 2026-10-20T15-24

Command: `poetry run pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service_result_limits.py tests/discovery_runtime/test_service_request_rules.py::test_valid_conditional_controls_and_role_context`

EXIT_CODE: 0

Output Summary: PASS; 5.017 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 23 items

tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[principal-False] PASSED [  4%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[principal-True] PASSED [  8%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[code-False] PASSED [ 13%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[code-True] PASSED [ 17%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[request-operation-False] PASSED [ 21%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[request-operation-True] PASSED [ 26%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[request-mode-False] PASSED [ 30%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[request-mode-True] PASSED [ 34%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[operation-False] PASSED [ 39%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[operation-True] PASSED [ 43%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[mode-False] PASSED [ 47%]
tests/discovery_runtime/test_service_result_limits.py::test_enum_boundaries_reject_or_redact_before_equality[mode-True] PASSED [ 52%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[path] PASSED [ 56%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[missing] PASSED [ 60%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[source-pin] PASSED [ 65%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[target-pin] PASSED [ 69%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[summary] PASSED [ 73%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[finding] PASSED [ 78%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[artifact] PASSED [ 82%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[content] PASSED [ 86%]
tests/discovery_runtime/test_service_result_limits.py::test_aggregate_work_rejects_before_projection_hash_or_encoding[aggregate-content] PASSED [ 91%]
tests/discovery_runtime/test_service_result_limits.py::test_small_manifest_preserves_digest_and_both_roles_with_sufficient_work PASSED [ 95%]
tests/discovery_runtime/test_service_request_rules.py::test_valid_conditional_controls_and_role_context PASSED [100%]

============================= 23 passed in 3.33s ==============================

```
