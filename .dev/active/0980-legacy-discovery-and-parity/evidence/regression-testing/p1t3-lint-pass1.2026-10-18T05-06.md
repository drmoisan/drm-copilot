# p1t3-lint-pass1

Timestamp: 2026-10-18T05-06
Command: poetry run ruff check tests/schemas/discovery/test_v2_profile_schemas.py tests/schemas/discovery/test_v2_common_schemas.py tests/schemas/discovery/v2_schema_test_support.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mMove into type-checking block[0m; ; Found 1 error.; No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

Working directory: .
Started: 2026-10-18T05:05:59.885823+00:00
Duration seconds: 0.772
Phase: P1-T3 shared profile/scope schemas; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove third-party import `jsonschema.exceptions.ValidationError` into a type-checking block[0m
  [1m[94m-->[0m tests\schemas\discovery\v2_schema_test_support.py:11:35
   [1m[94m|[0m
[1m[94m 9 |[0m import yaml
[1m[94m10 |[0m from jsonschema import Draft202012Validator, FormatChecker
[1m[94m11 |[0m from jsonschema.exceptions import ValidationError
   [1m[94m|[0m                                   [1m[91m^^^^^^^^^^^^^^^[0m
[1m[94m12 |[0m from referencing import Registry, Resource
[1m[94m13 |[0m from referencing.jsonschema import DRAFT202012, Schema
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

Found 1 error.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
