# P6-T1 renderer ruff

Timestamp: 2026-10-20T15-15

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/service_selection.py tests/discovery_runtime/test_service_selection.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.409 seconds.

```text
E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_selection.py:185:89
    |
184 | def test_malformed_public_values_are_rejected(snapshot_catalog: SchemaCatalog) -> None:
185 |     """Use catalog fixture to reject wrong snapshot/repository/generation; return None."""
    |                                                                                         ^^
186 |     with pytest.raises(ServiceRequestError):
187 |         resolve_feature_ids(cast("DiscoverySnapshot", object()))
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_selection.py:312:89
    |
311 |     def counted(self: AcceptanceGeneration) -> None:
312 |         """Record model reconstruction of self and delegate; return None or ValueError."""
    |                                                                                         ^^
313 |         calls.append("model")
314 |         prior(self)
    |

Found 2 errors.

```
