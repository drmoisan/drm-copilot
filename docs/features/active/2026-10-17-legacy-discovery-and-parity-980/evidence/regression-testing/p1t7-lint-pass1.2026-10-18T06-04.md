# p1t7-lint-pass1

Timestamp: 2026-10-18T06-04
Command: poetry run ruff check tests/schemas/discovery/v2_control_test_support.py tests/schemas/discovery/test_v2_control_schemas.py tests/schemas/discovery/test_v2_authority_schemas.py
EXIT_CODE: 1
Output Summary: [1m[94m20 |[0m STAMP = "2026-01-01T00:00:00Z";    [1m[94m|[0m; ; Found 1 error.

Working directory: .
Started: 2026-10-18T06:04:31.972585+00:00
Duration seconds: 0.766
Phase: P1-T7 service/control/authority schemas; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mPossible hardcoded password assigned to: "TOKEN"[0m
  [1m[94m-->[0m tests\schemas\discovery\v2_control_test_support.py:18:9
   [1m[94m|[0m
[1m[94m16 |[0m     "tool-authorization",
[1m[94m17 |[0m )
[1m[94m18 |[0m TOKEN = "protected-alpha-00000001"
   [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m19 |[0m PROFILE = "docs/migration/discovery/domain-profile.yaml"
[1m[94m20 |[0m STAMP = "2026-01-01T00:00:00Z"
   [1m[94m|[0m

Found 1 error.
```
