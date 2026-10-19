# p4t7-integration-focused4-lint

Timestamp: 2026-10-19T10-47
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependencies.py tests/discovery_runtime/analyzer/test_dependencies.py tests/discovery_runtime/analyzer/test_dependency_projection_limits.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.138 seconds. Separate exact stdout/stderr hashes and SCRATCH-relative locations qualify sanitized presentation.

```text
E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependencies.py:452:89
    |
450 |         try:
451 |             state = _Run(capture)
452 |             # Capture selection/exclusion controls inputs; payloads cannot select parsers.
    |                                                                                         ^^
453 |             for item in capture.inputs:
454 |                 state.work -= len(item.path) + 1
    |

Found 1 error.
```
