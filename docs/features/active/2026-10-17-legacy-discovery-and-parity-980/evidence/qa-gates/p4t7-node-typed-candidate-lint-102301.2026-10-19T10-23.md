# P4-T7 Node typed-candidate lint

Timestamp: 2026-10-19T10-23
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_node.py tests/discovery_runtime/analyzer/test_dependency_node.py tests/discovery_runtime/analyzer/test_dependency_node_limits.py`
EXIT_CODE: 1
Output Summary: Isolated development check; exact shared and owned bytes and raw diagnostics are bound in JSON.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_node.py:132:89
    |
130 |     )
131 |     assert first == second
132 |     # Keep overlapping groups as separate facts instead of choosing effective precedence.
    |                                                                                         ^
133 |     assert [(item.name, item.version.value) for item in first.candidates] == [
134 |         ("a", "1"),
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_node.py:239:89
    |
237 |     """Observe inert link and location-independent name declarations; returns None.
238 |
239 |     Missing versions stay missing; link targets, scripts and arbitrary fields stay opaque.
    |                                                                                         ^^
240 |     """
241 |     result = parse(
    |

Found 2 errors.

```
