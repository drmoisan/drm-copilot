# p2t4-types-pass4

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-50
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t4-gates.2026-10-18T08-44.md
Source block ordinal: 11
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:       "object" is not assignable to "None" (reportArgumentType); 1 error, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T08:50:03.770584+00:00
Duration seconds: 8.082
Phase: P2-T4 observation and runtime claims; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "object" cannot be assigned to parameter "overrides" of type "dict[str, object] | None" in function "scenario"
    Type "object" is not assignable to type "dict[str, object] | None"
      "object" is not assignable to "dict[str, object]"
      "object" is not assignable to "None" (reportArgumentType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
