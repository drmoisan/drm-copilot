# p1t3-types-pass2

Timestamp: 2026-10-18T05-06
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:       "object" is not assignable to "Sequence[_JsonParameter]" (reportArgumentType); 2 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T05:06:15.301764+00:00
Duration seconds: 6.998
Phase: P1-T3 shared profile/scope schemas; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "iter_errors" is partially unknown
    Type of "iter_errors" is "Overload[(instance: str | int | float | bool | Mapping[str, _JsonParameter] | Sequence[_JsonParameter] | None) -> Generator[Any, None, None], (instance: Unknown, _schema: bool | Mapping[str, Any] | None) -> Generator[Any, None, None]]" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Argument of type "object" cannot be assigned to parameter "instance" of type "_JsonParameter" in function "iter_errors"
    Type "object" is not assignable to type "_JsonParameter"
      "object" is not assignable to "str"
      "object" is not assignable to "int"
      "object" is not assignable to "float"
      "object" is not assignable to "bool"
      "object" is not assignable to "None"
      "object" is not assignable to "Mapping[str, _JsonParameter]"
      "object" is not assignable to "Sequence[_JsonParameter]" (reportArgumentType)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
