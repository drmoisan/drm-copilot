# P6-T3 compatibility subset tests

Timestamp: 2026-10-21T16-44

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=scripts.dev_tools.validate_discovery_artifacts --cov-branch -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t3-validator-164354-tests-coverage.json tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`

EXIT_CODE: 0

Output Summary: PASS; 7.067 seconds; 38 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 38 items

tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_validate_from_args_returns_unsupported_artifact_type PASSED [  2%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_profile_returns_zero_for_conforming_fixture PASSED [  5%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_profile_returns_one_for_missing_authoritative_profile_contract PASSED [  7%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_feature_contract_returns_zero_for_conforming_fixture PASSED [ 10%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_feature_contract_returns_one_for_non_conforming_fixture PASSED [ 13%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_all_refuses_file_probing_before_reading PASSED [ 15%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_direct_all_dispatch_is_an_actionable_refusal PASSED [ 18%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_profile-profile] PASSED [ 21%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_feature_contract-feature-contract] PASSED [ 23%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_coverage_ledger-coverage-ledger] PASSED [ 26%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_runtime_scenario-runtime-scenario] PASSED [ 28%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_parity_matrix-parity-matrix] PASSED [ 31%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_unspecified_behavior-unspecified-behavior] PASSED [ 34%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_product_decision-product-decision] PASSED [ 36%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_main_artifact_wrappers_dispatch_with_correct_argv_prefix[main_evidence_reference-evidence-reference] PASSED [ 39%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_canonical_kind_route_forwards_exact_flags[arguments0] PASSED [ 42%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_canonical_kind_route_forwards_exact_flags[arguments1] PASSED [ 44%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_canonical_kind_route_forwards_exact_flags[arguments2] PASSED [ 47%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_legacy_argument_errors_do_not_read[arguments0] PASSED [ 50%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_legacy_argument_errors_do_not_read[arguments1] PASSED [ 52%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_legacy_argument_errors_do_not_read[arguments2] PASSED [ 55%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_malformed_arguments_are_redacted[secret] PASSED [ 57%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_malformed_arguments_are_redacted[42] PASSED [ 60%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_malformed_arguments_are_redacted[arguments2] PASSED [ 63%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_malformed_arguments_are_redacted[arguments3] PASSED [ 65%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_argument_count_refusal_precedes_text_measurement[False] PASSED [ 68%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_argument_count_refusal_precedes_text_measurement[True] PASSED [ 71%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_argument_text_work_is_reserved_before_scan[3] PASSED [ 73%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_argument_text_work_is_reserved_before_scan[4] PASSED [ 76%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_process_arguments_are_captured_without_mutation PASSED [ 78%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments0-False] PASSED [ 81%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments1-False] PASSED [ 84%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments2-False] PASSED [ 86%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments3-True] PASSED [ 89%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments4-True] PASSED [ 92%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_route_uses_only_explicit_options[arguments5-True] PASSED [ 94%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_report_mixed_routes_refuse_before_callbacks PASSED [ 97%]
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py::test_selected_file_reader_preserves_utf8_and_errors PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------
scripts\dev_tools\validate_discovery_artifacts.py     102      0     32      0   100%
-----------------------------------------------------------------------------------------------
TOTAL                                                 102      0     32      0   100%
Coverage JSON written to file SCRATCH\p6t3-validator-164354-tests-coverage.json
============================= 38 passed in 6.22s ==============================

```
