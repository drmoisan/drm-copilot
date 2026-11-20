# Final Python Targeted Coverage Evidence

- Timestamp: 2025-05-01T00:00:00Z
- Command: `poetry run pytest tests/scripts/dev_tools/codex_native_converter/ --cov=scripts/dev_tools/codex_native_converter --cov-report=term-missing -q`
- EXIT_CODE: 0
- Output Summary:

| Module | Cover | Missing |
|---|---|---|
| `__init__.py` | 100% | — |
| `__main__.py` | 100% | — |
| `_pipeline_traces.py` | 96% | 110 |
| `_reporting_topology.py` | 100% | — |
| `classifier.py` | 92% | 84-85, 162, 229, 338, 407 |
| `cli.py` | 100% | — |
| `engine.py` | 97% | 187, 195, 239 |
| `intermediate_state.py` | 100% | — |
| `inventory.py` | 96% | 156, 215 |
| `mapping.py` | 96% | 164-165 |
| `models.py` | 99% | 424 |
| `models_intermediate.py` | 100% | — |
| `parser.py` | 90% | 89, 94, 141-142, 174-175, 257-259 |
| `pipeline.py` | 96% | 140, 149, 257, 271 |
| `reporting.py` | 95% | 117, 139-140 |
| `rewrites.py` | 91% | 75, 81-83 |
| `section_intent.py` | 100% | — |
| `validation.py` | 98% | 247 |
| **TOTAL** | **96%** | — |

All modules ≥90%. Targeted package coverage ≥95%.
