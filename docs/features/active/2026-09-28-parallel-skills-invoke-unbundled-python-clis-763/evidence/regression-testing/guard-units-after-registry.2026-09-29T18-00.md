# Guard Unit Tests After Registry Removal (P1-T6)

Timestamp: 2026-09-29T18-00
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py
EXIT_CODE: 0
Output Summary:
- `38 passed in 0.25s`; no FAILED line.
- B4 and B3 named tests on PASSED lines:
  - `test_skill_bundle_contract_evaluation.py::test_known_unbundled_references_registry_is_empty PASSED`
  - `test_skill_bundle_contract_cli.py::test_main_returns_zero_when_clean PASSED`
  - `test_skill_bundle_contract_cli.py::test_main_returns_one_and_prints_violation_lines PASSED`
  - `test_skill_bundle_contract_cli.py::test_main_returns_one_for_stale_exception PASSED`
  - `test_skill_bundle_contract_cli.py::test_main_prints_nothing_to_stderr_when_clean PASSED`
  - `test_skill_bundle_contract_cli.py::test_main_suppresses_a_registered_exception PASSED`
