# P5-T4 generation pyright

Timestamp: 2026-10-20T11-28

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py tests/discovery_runtime/test_acceptance_generation_limits.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.615 seconds.

```text
<WORKSPACE>\tests\discovery_runtime\test_acceptance_decisions.py
  <WORKSPACE>\tests\discovery_runtime\test_acceptance_decisions.py:41:14 - error: Function with declared return type "tuple[ArtifactRecord | None, ...]" must return value on all code paths
    "None" is not assignable to "tuple[ArtifactRecord | None, ...]" (reportReturnType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
