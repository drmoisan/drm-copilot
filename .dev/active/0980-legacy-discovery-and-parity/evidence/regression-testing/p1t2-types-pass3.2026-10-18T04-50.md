# p1t2-types-pass3

Timestamp: 2026-10-18T04-50
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:         Type parameter "D@Specification" is invariant, but "Schema" is not the same as "object" (reportArgumentType); 1 error, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T04:49:53.218293+00:00
Duration seconds: 7.221
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "Specification[Schema]" cannot be assigned to parameter "default_specification" of type "type[Specification[object]] | Specification[object]" in function "from_contents"
    Type "Specification[Schema]" is not assignable to type "type[Specification[object]] | Specification[object]"
      Type "Specification[Schema]" is not assignable to type "type[Specification[object]]"
      "Specification[Schema]" is not assignable to "Specification[object]"
        Type parameter "D@Specification" is invariant, but "Schema" is not the same as "object" (reportArgumentType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
