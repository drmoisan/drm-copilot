# p5t3-semantics-pass2-lint

Timestamp: 2026-10-20T09-11
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/validation.py packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py tests/discovery_runtime/test_completion_projection.py tests/discovery_runtime/test_validation_modes.py
EXIT_CODE: 1
Output Summary: lint, 1.189s; exact raw streams separately bound.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\validation.py:239:89
    |
237 |                 ],
238 |             }
239 |         # Diagnostic completion never constructs a semantic operation or grants validity.
    |                                                                                         ^
240 |         if mode not in _MODES:
241 |             raise ValueError("Unsupported report or validation mode")
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py:238:89
    |
236 |         Coverage/parity add independently evaluated complete results and populations;
237 |         their requested-mode findings remain unchanged. Completion retains trusted
238 |         input warnings and evaluates only its selected mode. Raises ValueError on invalid
    |                                                                                         ^
239 |         modes or resource limits. No I/O, publication or caller mutation occurs.
240 |         """
    |

Found 2 errors.
```
