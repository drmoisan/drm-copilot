Timestamp: 2026-10-21T12-08
Command: `.venv/Scripts/python.exe -m pyright tests/discovery_runtime/test_service_report_guards.py`
EXIT_CODE: 1
Output Summary: report-guards-loop3-pyright; 0 retained test IDs; elapsed 1.028 seconds.

```text
WORKSPACE\tests\discovery_runtime\test_service_report_guards.py
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:145:5 - error: Type of "expected" is partially unknown
    Type of "expected" is "dict[Unknown, bytes]" (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:146:22 - error: Argument missing for parameter "limits" (reportCallIssue)
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:151:5 - error: Type of "update" is partially unknown
    Type of "update" is "Overload[(m: SupportsKeysAndGetItem[Unknown, bytes], /) -> None, (m: SupportsKeysAndGetItem[str, bytes], /, **kwargs: bytes) -> None, (m: Iterable[tuple[Unknown, bytes]], /) -> None, (m: Iterable[tuple[str, bytes]], /, **kwargs: bytes) -> None, (**kwargs: bytes) -> None]" (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:168:5 - error: Type of "pending_view" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:168:33 - error: Argument missing for parameter "limits" (reportCallIssue)
  WORKSPACE\tests\discovery_runtime\test_service_report_guards.py:170:12 - error: Return type, "tuple[AcceptanceGeneration, dict[Unknown, bytes]]", is partially unknown (reportUnknownVariableType)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
