# P6-T3 installed entry tests

Timestamp: 2026-10-21T16-37

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=drm_copilot_discovery.cli -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_legacy_adapters.py tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-False] tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[True-True] tests/discovery_runtime/test_cli_dry_run.py::test_installed_entry_binds_fixed_local_user_and_one_reader[False-False] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[init] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[configure] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[profile] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[inventory] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[dotnet] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[vsto] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-contract] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[new-scenario] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[update-artifact] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[link-evidence] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-profile] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-feature-contract] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-coverage-ledger] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-runtime-scenario] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-parity-matrix] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-unspecified-behavior] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-product-decision] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-evidence-reference] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-decisions] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate-all] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[validate] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[coverage-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[parity-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[completion-report] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[generate-acceptance-scenarios] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-export] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[snapshot-import] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[import-inventory] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[migrate] tests/discovery_runtime/test_cli_dry_run.py::test_every_console_wrapper_uses_its_fixed_command[doctor] tests/discovery_runtime/test_cli_dry_run.py::test_process_argument_copy_is_bounded`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.210 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 40 items

tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[False] FAILED [  2%]

================================== FAILURES ===================================
_ test_installed_entry_preserves_explicit_arguments_and_process_state[False] __
tests\discovery_runtime\test_legacy_adapters.py:101: in test_installed_entry_preserves_explicit_arguments_and_process_state
    assert cli.run_installed_cli("doctor", arguments) == 1
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\cli.py:289: in run_installed_cli
    return run_cli(
tests\discovery_runtime\test_legacy_adapters.py:94: in record
    assert stdout is output and stderr is errors
E   AssertionError: assert (<EncodedFile name='<tempfile._TemporaryFileWrapper object at 0x00000237EF1DFA10>' mode='r+' encoding='utf-8'> is <_io.StringIO object at 0x00000237EF963880>)
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[False]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
============================== 1 failed in 0.45s ==============================

```
