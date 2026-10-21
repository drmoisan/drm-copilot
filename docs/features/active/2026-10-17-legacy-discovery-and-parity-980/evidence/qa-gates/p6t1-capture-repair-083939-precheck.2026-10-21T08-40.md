# P6-T1 publication repair precheck

Timestamp: 2026-10-21T08-40

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-083939-precheck-coverage.json tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short]`

EXIT_CODE: 1

Output Summary: FAIL; 37.109 seconds; 1 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 9 items

tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports PASSED [ 11%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] FAILED [ 22%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] FAILED [ 33%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] FAILED [ 44%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] FAILED [ 55%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] FAILED [ 66%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] FAILED [ 77%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] FAILED [ 88%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] FAILED [100%]

================================== FAILURES ===================================
______ test_capture_checks_exact_capacity_and_original_bytes[coalesced] _______
tests\discovery_runtime\test_migration_capture.py:358: in test_capture_checks_exact_capacity_and_original_bytes
    snapshot=replace(snapshot, profile=replace(snapshot.profile, limits=limits)),
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
___ test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] ____
tests\discovery_runtime\test_migration_capture.py:358: in test_capture_checks_exact_capacity_and_original_bytes
    snapshot=replace(snapshot, profile=replace(snapshot.profile, limits=limits)),
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
____ test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] ____
tests\discovery_runtime\test_migration_capture.py:358: in test_capture_checks_exact_capacity_and_original_bytes
    snapshot=replace(snapshot, profile=replace(snapshot.profile, limits=limits)),
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
____ test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] _____
tests\discovery_runtime\test_migration_capture.py:358: in test_capture_checks_exact_capacity_and_original_bytes
    snapshot=replace(snapshot, profile=replace(snapshot.profile, limits=limits)),
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
_ test_projection_reserves_exact_merged_capacity_before_retention[count-exact] _
tests\discovery_runtime\test_migration_capture.py:420: in test_projection_reserves_exact_merged_capacity_before_retention
    projected = replace(projected, profile=replace(projected.profile, limits=limits))
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
_ test_projection_reserves_exact_merged_capacity_before_retention[count-short] _
tests\discovery_runtime\test_migration_capture.py:420: in test_projection_reserves_exact_merged_capacity_before_retention
    projected = replace(projected, profile=replace(projected.profile, limits=limits))
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
_ test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] _
tests\discovery_runtime\test_migration_capture.py:420: in test_projection_reserves_exact_merged_capacity_before_retention
    projected = replace(projected, profile=replace(projected.profile, limits=limits))
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
_ test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] _
tests\discovery_runtime\test_migration_capture.py:420: in test_projection_reserves_exact_merged_capacity_before_retention
    projected = replace(projected, profile=replace(projected.profile, limits=limits))
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py     120     13     44     12    84%   34, 39, 45, 76, 83, 119, 141-145, 160, 165, 235, 267, 285
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py         214     44     96     27    73%   49-50, 75, 80, 107, 112, 118, 129, 132, 134, 151, 153, 156-158, 205-210, 266, 330, 337, 362, 365-384, 410, 420, 423-425, 429, 440, 444, 469, 471, 478, 487
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         334     57    140     39    76%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-083939-precheck-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced]
FAILED tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted]
FAILED tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted]
FAILED tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict]
FAILED tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact]
FAILED tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short]
FAILED tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact]
FAILED tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short]
======================== 8 failed, 1 passed in 36.38s =========================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.service_bootstrap was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
```
