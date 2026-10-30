# P5-T5 final contracts

Timestamp: 2026-10-20T13-57
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider --no-cov tests/scripts/dev_tools/test_quality_tiers_contract_classification.py::test_committed_quality_tiers_yml_matches_live_tree tests/scripts/dev_tools/test_quality_tiers_contract_classification.py::test_committed_quality_tiers_yml_assigns_spec_tiers tests/discovery_runtime/test_package_contract.py::test_runtime_metadata_has_bounded_dependencies_and_minimum_python tests/discovery_runtime/test_package_contract.py::test_root_tooling_includes_the_local_runtime_for_types_and_coverage`
EXIT_CODE: 0
Output Summary: Stage 7; 1.017 seconds; 4 completed nodes; timeout=False; changed bindings=0.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 4 items

tests/scripts/dev_tools/test_quality_tiers_contract_classification.py::test_committed_quality_tiers_yml_matches_live_tree PASSED [ 25%]
tests/scripts/dev_tools/test_quality_tiers_contract_classification.py::test_committed_quality_tiers_yml_assigns_spec_tiers PASSED [ 50%]
tests/discovery_runtime/test_package_contract.py::test_runtime_metadata_has_bounded_dependencies_and_minimum_python PASSED [ 75%]
tests/discovery_runtime/test_package_contract.py::test_root_tooling_includes_the_local_runtime_for_types_and_coverage PASSED [100%]

============================== 4 passed in 0.12s ==============================

```
