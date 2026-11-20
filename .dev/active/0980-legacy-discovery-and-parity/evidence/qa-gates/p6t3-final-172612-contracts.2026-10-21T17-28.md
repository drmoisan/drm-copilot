# P6-T3 final contracts

Timestamp: 2026-10-21T17-28

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_package_contract.py::test_runtime_metadata_has_bounded_dependencies_and_minimum_python tests/schemas/discovery/test_v2_control_schemas.py::test_control_schemas_are_closed_valid_and_packaged[service-request] tests/schemas/discovery/test_v2_control_schemas.py::test_control_schemas_are_closed_valid_and_packaged[service-result] tests/schemas/discovery/test_v2_control_schemas.py::test_control_definitions_have_complete_offline_reference_closure`

EXIT_CODE: 0

Output Summary: PASS; 0.609 seconds; 4 passed nodes; timeout=False.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 4 items

tests/discovery_runtime/test_package_contract.py::test_runtime_metadata_has_bounded_dependencies_and_minimum_python PASSED [ 25%]
tests/schemas/discovery/test_v2_control_schemas.py::test_control_schemas_are_closed_valid_and_packaged[service-request] PASSED [ 50%]
tests/schemas/discovery/test_v2_control_schemas.py::test_control_schemas_are_closed_valid_and_packaged[service-result] PASSED [ 75%]
tests/schemas/discovery/test_v2_control_schemas.py::test_control_definitions_have_complete_offline_reference_closure PASSED [100%]

============================== 4 passed in 0.17s ==============================

```
