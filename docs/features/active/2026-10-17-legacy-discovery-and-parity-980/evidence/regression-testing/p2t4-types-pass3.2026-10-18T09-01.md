# p2t4-types-pass3

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-49
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t4-gates.2026-10-18T08-44.md
Source block ordinal: 8
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:       "dict[str, object]" is not assignable to "None" (reportArgumentType); 5 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T08:49:28.915542+00:00
Duration seconds: 7.892
Phase: P2-T4 observation and runtime claims; focused task verification.

## Captured output

```text
    "dict[str, object]" is not assignable to "str" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object]" cannot be assigned to parameter "expected" of type "str | None" in function "scenario"
    Type "dict[str, object]" is not assignable to type "str | None"
      "dict[str, object]" is not assignable to "str"
      "dict[str, object]" is not assignable to "None" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object]" cannot be assigned to parameter "runs" of type "list[dict[str, object]] | None" in function "scenario"
    Type "dict[str, object]" is not assignable to type "list[dict[str, object]] | None"
      "dict[str, object]" is not assignable to "list[dict[str, object]]"
      "dict[str, object]" is not assignable to "None" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object]" cannot be assigned to parameter "status" of type "str" in function "execution"
    "dict[str, object]" is not assignable to "str" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "dict[str, object]" cannot be assigned to parameter "expected" of type "str | None" in function "execution"
    Type "dict[str, object]" is not assignable to type "str | None"
      "dict[str, object]" is not assignable to "str"
      "dict[str, object]" is not assignable to "None" (reportArgumentType)
5 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
