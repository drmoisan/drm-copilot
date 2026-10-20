# P5-T2 graph ruff

Timestamp: 2026-10-20T06-26

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.222 seconds.

```text
E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_parity_metrics.py:101:89
    |
 99 |         for item in target_graph.artifacts
100 |     )
101 |     # Retain source payloads and rebuild artifact bytes after the fixture path correction.
    |                                                                                         ^^
102 |     files = {
103 |         item.path: item
    |

Found 1 error.
```
