# P5-T4 generation ruff

Timestamp: 2026-10-20T10-49

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.410 seconds.

```text
E501 Line too long (93 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:202:89
    |
200 |                     message=message,
201 |                     artifact_path=record.artifact.path if record else None,
202 |                     next_action="Correct captured inputs or selection, then generate again.",
    |                                                                                         ^^^^^
203 |                 ),
204 |             )
    |

Found 1 error.

```
