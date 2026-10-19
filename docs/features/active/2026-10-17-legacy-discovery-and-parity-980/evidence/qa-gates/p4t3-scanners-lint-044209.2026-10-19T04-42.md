# P4-T3 scanners lint

Timestamp: 2026-10-19T04-42
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:409:89
    |
408 | def test_member_work_is_bounded_for_adversarial_prefixes() -> None:
409 |     """Repeated unfinished signatures fail before repeated prefix work grows unbounded."""
    |                                                                                         ^^
410 |     with pytest.raises(SourceScanError) as error:
411 |         declaration_candidates("a.cs", "class A { int M " + "( " * 80)
    |

Found 1 error.

```
