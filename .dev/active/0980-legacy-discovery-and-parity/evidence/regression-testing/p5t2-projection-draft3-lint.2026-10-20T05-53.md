# p5t2-projection-draft3-lint

Timestamp: 2026-10-20T05-53
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/validation.py tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_validation_modes.py
EXIT_CODE: 1
Output Summary: lint, 1.173s; exact raw streams separately bound.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_parity_report_projection.py:198:89
    |
196 |         name: str, target: Callable[..., object], *args: object, **kwargs: object
197 |     ) -> object:
198 |         """Forward args/kwargs to target; count complete name calls and return object."""
    |                                                                                         ^
199 |         if name == "parity_summary":
200 |             carriers.append(kwargs["parity"])
    |

Found 1 error.
```
