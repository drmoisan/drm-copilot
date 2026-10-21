# P6-T3 installed entry tests

Timestamp: 2026-10-21T16-38

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=drm_copilot_discovery.cli -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_legacy_adapters.py tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-False] tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-True] tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[False-False] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[init] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[configure] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[profile] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[inventory] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[dotnet] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[vsto] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-contract] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-scenario] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[update-artifact] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[link-evidence] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-profile] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-feature-contract] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-coverage-ledger] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-runtime-scenario] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-parity-matrix] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-unspecified-behavior] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-product-decision] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-evidence-reference] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-decisions] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-all] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[coverage-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[parity-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[completion-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance-scenarios] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-export] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-import] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[import-inventory] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[migrate] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[doctor] tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded`

EXIT_CODE: 0

Output Summary: PASS; 26.262 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 40 items

tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[False] PASSED [  2%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[True] PASSED [  5%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_default_arguments_preserve_process_vector PASSED [  7%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_rejects_explicit_count_before_argument_access PASSED [ 10%]
tests/discovery_runtime/test_legacy_adapters.py::test_unknown_installed_command_refuses_before_provider_access PASSED [ 12%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-False] PASSED [ 15%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-True] PASSED [ 17%]
tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[False-False] PASSED [ 20%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[init] PASSED [ 22%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[configure] PASSED [ 25%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[profile] PASSED [ 27%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[inventory] PASSED [ 30%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[dotnet] PASSED [ 32%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[vsto] PASSED [ 35%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-contract] PASSED [ 37%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-scenario] PASSED [ 40%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[update-artifact] PASSED [ 42%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[link-evidence] PASSED [ 45%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-profile] PASSED [ 47%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-feature-contract] PASSED [ 50%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-coverage-ledger] PASSED [ 52%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-runtime-scenario] PASSED [ 55%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-parity-matrix] PASSED [ 57%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-unspecified-behavior] PASSED [ 60%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-product-decision] PASSED [ 62%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-evidence-reference] PASSED [ 65%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-decisions] PASSED [ 67%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-all] PASSED [ 70%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate] PASSED [ 72%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[coverage-report] PASSED [ 75%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[parity-report] PASSED [ 77%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[completion-report] PASSED [ 80%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance] PASSED [ 82%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance-scenarios] PASSED [ 85%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-export] PASSED [ 87%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-import] PASSED [ 90%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[import-inventory] PASSED [ 92%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[migrate] PASSED [ 95%]
tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[doctor] PASSED [ 97%]
tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded PASSED [100%]

============================= 40 passed in 25.53s =============================

```
