Timestamp: 2026-10-20T18-05
Command: `.venv/Scripts/python.exe -m pytest -o addopts= -vv tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_accepts_equivalent_spelling tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots tests/discovery_runtime/test_gateway_boundaries.py::test_workspace_identity_rejects_an_invalid_trusted_root --cov=drm_copilot_discovery.path_policy --cov=drm_copilot_discovery.gateway_local --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p6t1-gateway-nio1-new-coverage.json`
EXIT_CODE: 0
Output Summary: nio1-loop2-new; 57 retained test IDs; elapsed 111.790 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 57 items

tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_accepts_equivalent_spelling[windows-drive] PASSED [  1%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_accepts_equivalent_spelling[windows-unc] PASSED [  3%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_accepts_equivalent_spelling[posix-exact] PASSED [  5%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-root-request] PASSED [  7%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-root-baseline] PASSED [  8%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-root-writer] PASSED [ 10%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-drive-request] PASSED [ 12%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-drive-baseline] PASSED [ 14%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-drive-writer] PASSED [ 15%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[sibling-prefix-request] PASSED [ 17%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[sibling-prefix-baseline] PASSED [ 19%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[sibling-prefix-writer] PASSED [ 21%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-share-request] PASSED [ 22%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-share-baseline] PASSED [ 24%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-share-writer] PASSED [ 26%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-server-request] PASSED [ 28%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-server-baseline] PASSED [ 29%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[different-server-writer] PASSED [ 31%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-case-request] PASSED [ 33%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-case-baseline] PASSED [ 35%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-case-writer] PASSED [ 36%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-backslash-request] PASSED [ 38%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-backslash-baseline] PASSED [ 40%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[posix-backslash-writer] PASSED [ 42%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[relative-request] PASSED [ 43%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[relative-baseline] PASSED [ 45%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[relative-writer] PASSED [ 47%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[current-directory-request] PASSED [ 49%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[current-directory-baseline] PASSED [ 50%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[current-directory-writer] PASSED [ 52%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[drive-relative-request] PASSED [ 54%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[drive-relative-baseline] PASSED [ 56%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[drive-relative-writer] PASSED [ 57%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[root-relative-request] PASSED [ 59%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[root-relative-baseline] PASSED [ 61%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[root-relative-writer] PASSED [ 63%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-extended-request] PASSED [ 64%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-extended-baseline] PASSED [ 66%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-extended-writer] PASSED [ 68%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-dot-request] PASSED [ 70%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-dot-baseline] PASSED [ 71%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[device-dot-writer] PASSED [ 73%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[dot-component-request] PASSED [ 75%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[dot-component-baseline] PASSED [ 77%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[dot-component-writer] PASSED [ 78%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[parent-component-request] PASSED [ 80%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[parent-component-baseline] PASSED [ 82%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[parent-component-writer] PASSED [ 84%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[reserved-component-request] PASSED [ 85%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[reserved-component-baseline] PASSED [ 87%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[reserved-component-writer] PASSED [ 89%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[trailing-dot-request] PASSED [ 91%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[trailing-dot-baseline] PASSED [ 92%]
tests/discovery_runtime/test_gateway_boundaries.py::test_local_root_identity_rejects_nonmatching_roots[trailing-dot-writer] PASSED [ 94%]
tests/discovery_runtime/test_gateway_boundaries.py::test_workspace_identity_rejects_an_invalid_trusted_root[relative] PASSED [ 96%]
tests/discovery_runtime/test_gateway_boundaries.py::test_workspace_identity_rejects_an_invalid_trusted_root[/Work\\Repo] PASSED [ 98%]
tests/discovery_runtime/test_gateway_boundaries.py::test_workspace_identity_rejects_an_invalid_trusted_root[C:/Work/CON] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py     131     78     38      2    35%   65, 88, 97, 143-160, 199-223, 238-254, 269-341, 375-398
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py       161     43     86     19    69%   178, 229, 235, 247, 257-258, 264, 268, 274, 281, 288, 302, 321, 336, 343, 350, 366, 392, 400, 409, 430, 439-477, 486-497
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     292    121    124     21    55%
Coverage JSON written to file SCRATCH/issue-980-p6t1-gateway-nio1-new-coverage.json
======================= 57 passed in 111.17s (0:01:51) ========================

```
