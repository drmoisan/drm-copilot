Timestamp: 2026-10-21T05-10
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[one-component-existing]`
EXIT_CODE: 1
Output Summary: ncf2-reproducer2-test; 1 retained test IDs; elapsed 0.919 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[one-component-existing] FAILED [100%]

================================== FAILURES ===================================
_ test_intermediate_state_components_preserve_partition[one-component-existing] _
tests\discovery_runtime\test_gateway_factory.py:372: in test_intermediate_state_components_preserve_partition
    local = case.compose()
            ^^^^^^^^^^^^^^
tests\discovery_runtime\test_gateway_factory.py:97: in compose
    return gateway_local.installed_local_io(
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:413: in installed_local_io
    location=_canonical_state_location(location),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:374: in _canonical_state_location
    raise ValueError("Host state must retain its fixed workspace partition")
E   ValueError: Host state must retain its fixed workspace partition
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_gateway_factory.py::test_intermediate_state_components_preserve_partition[one-component-existing] - ValueError: Host state must retain its fixed workspace partition
============================== 1 failed in 0.54s ==============================

```
