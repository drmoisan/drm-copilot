# p2t2-types-pass2

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-12
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t2-gates.2026-10-18T08-12.md
Source block ordinal: 3
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:       Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType); 8 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T08:12:11.796685+00:00
Duration seconds: 8.134
Phase: P2-T2 typed artifact identities and references; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Function "_linkage" is not accessed (reportUnusedFunction)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "_finding" is private and used outside of the module in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: "_linkage" is private and used outside of the module in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: "_text" is private and used outside of the module in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: "_walk" is private and used outside of the module in which it is declared (reportPrivateUsage)
  EXTERNAL_PATH - error: Index 0 is out of range for type tuple[()] (reportGeneralTypeIssues)
  EXTERNAL_PATH - error: "_identities" is protected and used outside of the class in which it is declared (reportPrivateUsage)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "dict[str, str]" cannot be assigned to parameter "document" of type "dict[str, object]" in function "immutable"
    "dict[str, str]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "str" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType)
8 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
