# P6-T2 CLI composition tests

Timestamp: 2026-10-21T15-30

Command: `C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.cli --cov-branch -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t2-composition-152323-tests-coverage.json tests/discovery_runtime/test_cli_dry_run.py tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject`

EXIT_CODE: 0

Output Summary: PASS; 441.517 seconds; 58 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.3, pluggy-1.6.0 -- C:\Users\DanMoisan\AppData\Local\Programs\Python\Python313\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.1.0
collecting ... collected 58 items

tests/discovery_runtime/test_cli_dry_run.py::test_canonical_identity_and_same_reader_reach_service[False] PASSED [  1%]
tests/discovery_runtime/test_cli_dry_run.py::test_canonical_identity_and_same_reader_reach_service[True] PASSED [  3%]
tests/discovery_runtime/test_cli_dry_run.py::test_typed_service_exit_and_exact_json_survive[0] PASSED [  5%]
tests/discovery_runtime/test_cli_dry_run.py::test_typed_service_exit_and_exact_json_survive[1] PASSED [  6%]
tests/discovery_runtime/test_cli_dry_run.py::test_typed_service_exit_and_exact_json_survive[2] PASSED [  8%]
tests/discovery_runtime/test_cli_dry_run.py::test_typed_service_exit_and_exact_json_survive[3] PASSED [ 10%]
tests/discovery_runtime/test_cli_dry_run.py::test_help_and_unsupported_authority_never_call_providers[argv0-0] PASSED [ 12%]
tests/discovery_runtime/test_cli_dry_run.py::test_help_and_unsupported_authority_never_call_providers[argv1-2] PASSED [ 13%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[root] PASSED [ 15%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[canonical] PASSED [ 17%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[reader] PASSED [ 18%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[io] PASSED [ 20%]
tests/discovery_runtime/test_cli_dry_run.py::test_preexecution_failures_are_redacted_and_do_not_execute[runtime] PASSED [ 22%]
tests/discovery_runtime/test_cli_dry_run.py::test_unexpected_execution_failure_cannot_invent_empty_effects PASSED [ 24%]
tests/discovery_runtime/test_cli_dry_run.py::test_output_failure_never_retries_json[short] PASSED [ 25%]
tests/discovery_runtime/test_cli_dry_run.py::test_output_failure_never_retries_json[write] PASSED [ 27%]
tests/discovery_runtime/test_cli_dry_run.py::test_output_failure_never_retries_json[flush] PASSED [ 29%]
tests/discovery_runtime/test_cli_dry_run.py::test_output_failure_never_retries_json[serialize] PASSED [ 31%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-False] PASSED [ 32%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-True] PASSED [ 34%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[False-False] PASSED [ 36%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[init] PASSED [ 37%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[configure] PASSED [ 39%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[profile] PASSED [ 41%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[inventory] PASSED [ 43%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[dotnet] PASSED [ 44%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[vsto] PASSED [ 46%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-contract] PASSED [ 48%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-scenario] PASSED [ 50%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[update-artifact] PASSED [ 51%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[link-evidence] PASSED [ 53%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-profile] PASSED [ 55%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-feature-contract] PASSED [ 56%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-coverage-ledger] PASSED [ 58%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-runtime-scenario] PASSED [ 60%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-parity-matrix] PASSED [ 62%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-unspecified-behavior] PASSED [ 63%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-product-decision] PASSED [ 65%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-evidence-reference] PASSED [ 67%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-decisions] PASSED [ 68%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-all] PASSED [ 70%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate] PASSED [ 72%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[coverage-report] PASSED [ 74%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[parity-report] PASSED [ 75%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[completion-report] PASSED [ 77%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance] PASSED [ 79%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance-scenarios] PASSED [ 81%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-export] PASSED [ 82%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-import] PASSED [ 84%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[import-inventory] PASSED [ 86%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[migrate] PASSED [ 87%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[doctor] PASSED [ 89%]
tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded PASSED [ 91%]
tests/discovery_runtime/test_cli_dry_run.py::test_validate_all_default_pair_uses_real_planner[True] PASSED [ 93%]
tests/discovery_runtime/test_cli_dry_run.py::test_validate_all_default_pair_uses_real_planner[False] PASSED [ 94%]
tests/discovery_runtime/test_cli_dry_run.py::test_failed_report_publication_keeps_selected_gate_failure PASSED [ 96%]
tests/discovery_runtime/test_cli_dry_run.py::test_partial_service_failure_retains_reported_effects PASSED [ 98%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                          Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\cli.py     143      0     10      0   100%
---------------------------------------------------------------------------------------------------------
TOTAL                                                           143      0     10      0   100%
Coverage JSON written to file SCRATCH\p6t2-composition-152323-tests-coverage.json
======================= 58 passed in 440.66s (0:07:20) ========================

```
