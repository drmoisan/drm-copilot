# P6-T3 compatibility subset types

Timestamp: 2026-10-21T16-49

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pyright scripts/dev_tools/discovery/coverage_report.py scripts/dev_tools/discovery/parity_report.py scripts/dev_tools/discovery/completion_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_parity_report.py tests/scripts/dev_tools/discovery/test_completion_report.py`

EXIT_CODE: 1

Output Summary: FAIL; 1.011 seconds; 0 passed nodes.

```text
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

WORKSPACE\tests\scripts\dev_tools\discovery\test_completion_report.py
  WORKSPACE\tests\scripts\dev_tools\discovery\test_completion_report.py:435:32 - error: Argument of type "((*values: object) -> NoReturn) | None" cannot be assigned to parameter "coverage_validator" of type "ArtifactValidator | None" in function "main"
    Type "((*values: object) -> NoReturn) | None" is not assignable to type "ArtifactValidator | None"
      Type "(*values: object) -> NoReturn" is not assignable to type "ArtifactValidator | None"
        Type "(*values: object) -> NoReturn" is not assignable to type "(text: str) -> list[str]"
          Missing keyword parameter "text"
        "FunctionType" is not assignable to "None" (reportArgumentType)
  WORKSPACE\tests\scripts\dev_tools\discovery\test_completion_report.py:436:30 - error: Argument of type "((*values: object) -> NoReturn) | None" cannot be assigned to parameter "parity_validator" of type "ArtifactValidator | None" in function "main"
    Type "((*values: object) -> NoReturn) | None" is not assignable to type "ArtifactValidator | None"
      Type "(*values: object) -> NoReturn" is not assignable to type "ArtifactValidator | None"
        Type "(*values: object) -> NoReturn" is not assignable to type "(text: str) -> list[str]"
          Missing keyword parameter "text"
        "FunctionType" is not assignable to "None" (reportArgumentType)
WORKSPACE\tests\scripts\dev_tools\discovery\test_coverage_report.py
  WORKSPACE\tests\scripts\dev_tools\discovery\test_coverage_report.py:480:34 - error: Argument of type "((*values: object) -> NoReturn) | None" cannot be assigned to parameter "validator" of type "ArtifactValidator | None" in function "main"
    Type "((*values: object) -> NoReturn) | None" is not assignable to type "ArtifactValidator | None"
      Type "(*values: object) -> NoReturn" is not assignable to type "ArtifactValidator | None"
        Type "(*values: object) -> NoReturn" is not assignable to type "(text: str) -> list[str]"
          Missing keyword parameter "text"
        "FunctionType" is not assignable to "None" (reportArgumentType)
WORKSPACE\tests\scripts\dev_tools\discovery\test_parity_report.py
  WORKSPACE\tests\scripts\dev_tools\discovery\test_parity_report.py:393:34 - error: Argument of type "((*values: object) -> NoReturn) | None" cannot be assigned to parameter "validator" of type "ArtifactValidator | None" in function "main"
    Type "((*values: object) -> NoReturn) | None" is not assignable to type "ArtifactValidator | None"
      Type "(*values: object) -> NoReturn" is not assignable to type "ArtifactValidator | None"
        Type "(*values: object) -> NoReturn" is not assignable to type "(text: str) -> list[str]"
          Missing keyword parameter "text"
        "FunctionType" is not assignable to "None" (reportArgumentType)
4 errors, 0 warnings, 0 informations

```
