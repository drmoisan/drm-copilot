# p2t4-types-pass1

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-44
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t4-gates.2026-10-18T08-44.md
Source block ordinal: 3
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:         "__len__" is not present (reportArgumentType); 10 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T08:44:43.487879+00:00
Duration seconds: 7.826
Phase: P2-T4 observation and runtime claims; focused task verification.

## Captured output

```text
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "changes" in function "execution"
    Argument type is "dict[str, object] | dict[str, str | list[Unknown]]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object] | dict[str, str | list[Unknown]]" cannot be assigned to parameter "status" of type "str" in function "execution"
    Type "dict[str, object] | dict[str, str | list[Unknown]]" is not assignable to type "str"
      "dict[str, str | list[Unknown]]" is not assignable to "str" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object] | dict[str, str | list[Unknown]]" cannot be assigned to parameter "expected" of type "str | None" in function "execution"
    Type "dict[str, object] | dict[str, str | list[Unknown]]" is not assignable to type "str | None"
      Type "dict[str, str | list[Unknown]]" is not assignable to type "str | None"
        "dict[str, str | list[Unknown]]" is not assignable to "str"
        "dict[str, str | list[Unknown]]" is not assignable to "None" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "JsonValue" cannot be assigned to parameter "obj" of type "Sized" in function "len"
    Type "JsonValue" is not assignable to type "Sized"
      "float" is incompatible with protocol "Sized"
        "__len__" is not present (reportArgumentType)
10 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
