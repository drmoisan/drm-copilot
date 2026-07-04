# Final Line Counts Evidence

- Timestamp: 2025-05-01T00:00:00Z
- Command: `Get-ChildItem scripts/dev_tools/codex_native_converter/*.py | ForEach-Object { line count + name } | Sort Descending`
- EXIT_CODE: 0
- Output Summary:

| Lines | File |
|---|---|
| 499 | engine.py |
| 460 | models.py |
| 449 | pipeline.py |
| 444 | classifier.py |
| 433 | reporting.py |
| 418 | validation.py |
| 408 | rewrites.py |
| 292 | parser.py |
| 291 | cli.py |
| 271 | intermediate_state.py |
| 249 | section_intent.py |
| 234 | mapping.py |
| 226 | models_intermediate.py |
| 217 | inventory.py |
| 175 | _reporting_topology.py |
| 139 | _pipeline_traces.py |
| 24 | __init__.py |
| 23 | __main__.py |

All files ≤500 lines. Constraint satisfied.
