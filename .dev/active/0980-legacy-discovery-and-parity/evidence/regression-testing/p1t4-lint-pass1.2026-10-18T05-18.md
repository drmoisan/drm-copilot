# p1t4-lint-pass1

Timestamp: 2026-10-18T05-18
Command: poetry run ruff check tests/schemas/discovery/test_v2_observation_schemas.py tests/schemas/discovery/test_v2_runtime_schemas.py tests/schemas/discovery/v2_schema_test_support.py
EXIT_CODE: 1
Output Summary: [1m[94m22 |[0m ).split();    [1m[94m|[0m; ; Found 4 errors.

Working directory: .
Started: 2026-10-18T05:18:25.993515+00:00
Duration seconds: 0.814
Phase: P1-T4 observation/evidence schemas; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_observation_schemas.py:30:89
   [1m[94m|[0m
[1m[94m28 |[0m     "feature_id name capability_group summary lifecycle observation_state trigger "
[1m[94m29 |[0m     "preconditions inputs state_transitions observable_outputs side_effects ordering "
[1m[94m30 |[0m     "timing cancellation failure offline mobile alternate_clients environment_constraints "
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m31 |[0m     "security_permissions source_evidence_refs runtime_evidence_refs confidence "
[1m[94m32 |[0m     "unresolved_behavior_refs product_decision_status product_decision_refs "
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (157 > 88)[0m
   [1m[94m-->[0m tests\schemas\discovery\test_v2_observation_schemas.py:253:89
    [1m[94m|[0m
[1m[94m251 |[0m [1m[94m…[0m
[1m[94m252 |[0m [1m[94m…[0m
[1m[94m253 |[0m [1m[94m…[0muntime_artifact timestamp environment checksum author_or_agent confidence notes extensions".split(),
    [1m[94m|[0m                                 [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m254 |[0m [1m[94m…[0m
[1m[94m255 |[0m [1m[94m…[0md: str) -> None:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_runtime_schemas.py:18:89
   [1m[94m|[0m
[1m[94m16 |[0m KIND = "runtime-characterization-scenario"
[1m[94m17 |[0m REQUIRED_FIELDS = (
[1m[94m18 |[0m     "scenario_id feature_refs environment fixture preconditions action observation_plan "
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m19 |[0m     "pre_state_capture post_state_capture expected_result expected_result_basis "
[1m[94m20 |[0m     "result_status deviations evidence_refs repeatability confidence unresolved_findings "
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\schemas\discovery\test_v2_runtime_schemas.py:20:89
   [1m[94m|[0m
[1m[94m18 |[0m     "scenario_id feature_refs environment fixture preconditions action observation_plan "
[1m[94m19 |[0m     "pre_state_capture post_state_capture expected_result expected_result_basis "
[1m[94m20 |[0m     "result_status deviations evidence_refs repeatability confidence unresolved_findings "
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m21 |[0m     "runs extensions"
[1m[94m22 |[0m ).split()
   [1m[94m|[0m

Found 4 errors.
```
