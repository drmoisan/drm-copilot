# p2t7-types-pass3

Timestamp: 2026-10-18T09-42
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Argument type is "str | dict[str, object] | object | list[Unknown]" (reportUnknownArgumentType); 3 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T09:42:35.805073+00:00
Duration seconds: 8.506
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "scope" is partially unknown
    Type of "scope" is "dict[str, str | None] | dict[str, str | list[Unknown]]" (reportUnknownVariableType)
  EXTERNAL_PATH - error: Argument of type "dict[str, str | None] | dict[str, str | list[Unknown]]" cannot be assigned to parameter "scope_changes" of type "dict[str, object] | None" in function "coverage_snapshot"
    Type "dict[str, str | None] | dict[str, str | list[Unknown]]" is not assignable to type "dict[str, object] | None"
      Type "dict[str, str | None]" is not assignable to type "dict[str, object] | None"
        "dict[str, str | None]" is not assignable to "dict[str, object]"
          Type parameter "_VT@dict" is invariant, but "str | None" is not the same as "object"
          Consider switching from "dict" to "Mapping" which is covariant in the value type
        "dict[str, str | None]" is not assignable to "None" (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "fields" in function "contract"
    Argument type is "str | dict[str, object] | object | list[Unknown]" (reportUnknownArgumentType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
