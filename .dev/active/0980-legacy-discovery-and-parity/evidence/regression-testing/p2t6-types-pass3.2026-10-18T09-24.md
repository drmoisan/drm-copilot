# p2t6-types-pass3

Timestamp: 2026-10-18T09-24
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:         "list[dict[str, object]]" is not assignable to "None" (reportArgumentType); 3 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T09:24:37.037038+00:00
Duration seconds: 8.415
Phase: P2-T6 scope and coverage accounting; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "tests_found" in function "component"
    Argument type is "list[dict[str, str | list[Unknown]] | None]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument of type "list[dict[str, object]]" cannot be assigned to parameter "detected" of type "list[object] | None" in function "coverage_snapshot"
    Type "list[dict[str, object]]" is not assignable to type "list[object] | None"
      "list[dict[str, object]]" is not assignable to "list[object]"
        Type parameter "_T@list" is invariant, but "dict[str, object]" is not the same as "object"
        Consider switching from "list" to "Sequence" which is covariant
      "list[dict[str, object]]" is not assignable to "None" (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "list[dict[str, object]] | None" cannot be assigned to parameter "detected" of type "list[object] | None" in function "coverage_snapshot"
    Type "list[dict[str, object]] | None" is not assignable to type "list[object] | None"
      Type "list[dict[str, object]]" is not assignable to type "list[object] | None"
        "list[dict[str, object]]" is not assignable to "list[object]"
          Type parameter "_T@list" is invariant, but "dict[str, object]" is not the same as "object"
          Consider switching from "list" to "Sequence" which is covariant
        "list[dict[str, object]]" is not assignable to "None" (reportArgumentType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
