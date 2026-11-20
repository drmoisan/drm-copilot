# p4t9-core-focused8 ruff

Timestamp: 2026-10-19T13-22

Command: .\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py

EXIT_CODE: 1

Output Summary: Scoped ruff; elapsed 0.107 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:444:89
    |
442 |     bundle: DiscoverySnapshot,
443 | ) -> None:
444 |     """Require failed-input accounting to carry its own blocker; mutate only local state."""
    |                                                                                         ^^^^
445 |     context = ExtensionValidation(bundle)
446 |     unavailable = InventoryInput(
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:468:89
    |
466 |     bundle: DiscoverySnapshot, field: str, monkeypatch: pytest.MonkeyPatch
467 | ) -> None:
468 |     """Reserve metadata's UTF-8 cost before any core analysis; patch only local seams."""
    |                                                                                         ^
469 |     import drm_copilot_discovery.extension_results as module
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_results.py:460:89
    |
458 |     bundle: DiscoverySnapshot,
459 | ) -> None:
460 |     """Reject an unexplained omission without reflecting its untrusted path in errors."""
    |                                                                                         ^
461 |     with pytest.raises(ExtensionResultError, match="EXTENSION_INPUT") as failure:
462 |         validate_extension_results(replace(bundle, excluded_paths=("unexplained",)))
    |

Found 3 errors.
```
