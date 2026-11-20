# P5-T2 graph pyright

Timestamp: 2026-10-20T06-23

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.353 seconds.

```text
c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:202:42 - error: "authored_state" is not a known attribute of "None" (reportOptionalMemberAccess)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:202:80 - error: "complete" is not a known attribute of "None" (reportOptionalMemberAccess)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:227:47 - error: "verification_valid" is not a known attribute of "None" (reportOptionalMemberAccess)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:249:27 - error: Argument of type "dict[str, str | int]" cannot be assigned to parameter "object" of type "dict[str, object]" in function "append"
    "dict[str, str | int]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "str | int" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:326:32 - error: Argument of type "dict[str, str | dict[str, dict[str, int | JsonObject]] | None]" cannot be assigned to parameter "object" of type "dict[str, object]" in function "append"
    "dict[str, str | dict[str, dict[str, int | JsonObject]] | None]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "str | dict[str, dict[str, int | JsonObject]] | None" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:327:9 - error: Type of "approved" is partially unknown
    Type of "approved" is "set[Unknown]" (reportUnknownVariableType)
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:333:13 - error: Type of "add" is partially unknown
    Type of "add" is "(element: Unknown, /) -> None" (reportUnknownMemberType)
c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\tests\discovery_runtime\test_parity_metrics.py
  c:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-17T22-30\tests\discovery_runtime\test_parity_metrics.py:276:12 - error: Return type, "list[Unknown]", is partially unknown (reportUnknownVariableType)
8 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
