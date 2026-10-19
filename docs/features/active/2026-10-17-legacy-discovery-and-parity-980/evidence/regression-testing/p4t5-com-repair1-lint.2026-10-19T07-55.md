# p4t5-com-repair1-lint

Timestamp: 2026-10-19T07-55
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_interop.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_syntax.py tests/discovery_runtime/analyzer/test_com_interop.py tests/discovery_runtime/analyzer/test_com_candidates.py
EXIT_CODE: 1
Output Summary: FAIL scoped COM stage 2; duration 1.203 seconds. Exact bytes and original command output are in the paired JSON.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:352:89
    |
350 |         "unresolved",
351 |     ]
352 |     # Keep false and ambiguous metadata separate instead of enabling interop by presence.
    |                                                                                         ^
353 |     assert [dict(value.extra)["embed_interop_types"] for value in values] == [
354 |         "false",
    |

Found 1 error.
```
