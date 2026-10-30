# P5-T2 graph pyright

Timestamp: 2026-10-20T07-02

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py tests/discovery_runtime/test_parity_axes.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.420 seconds.

```text
<WORKSPACE>\tests\discovery_runtime\test_parity_axes.py
  <WORKSPACE>\tests\discovery_runtime\test_parity_axes.py:175:13 - error: Type of "value" is unknown (reportUnknownVariableType)
  <WORKSPACE>\tests\discovery_runtime\test_parity_axes.py:175:22 - error: Type of "__iter__" is partially unknown
    Type of "__iter__" is "(self: tuple[Unknown, ...]) -> Iterator[Unknown]" (reportUnknownMemberType)
  <WORKSPACE>\tests\discovery_runtime\test_parity_axes.py:186:13 - error: Type of "candidate" is unknown (reportUnknownVariableType)
  <WORKSPACE>\tests\discovery_runtime\test_parity_axes.py:186:26 - error: Type of "__iter__" is partially unknown
    Type of "__iter__" is "(self: tuple[Unknown, ...]) -> Iterator[Unknown]" (reportUnknownMemberType)
4 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
