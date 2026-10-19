# p4t9-core-repair2 ruff

Timestamp: 2026-10-19T13-42

Command: .\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py tests/discovery_runtime/test_extension_validation_limits.py

EXIT_CODE: 1

Output Summary: Scoped ruff; elapsed 0.112 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:209:89
    |
208 |     snapshot (DiscoverySnapshot) must be configured and load-valid. manifest_paths
209 |     (tuple[str, ...] or None) selects a configured subset or all paths. Returns immutable
    |                                                                                         ^
210 |     descriptive carriers. Raises ExtensionResultError for invalid data; draft profile
211 |     rejection remains fail closed. Performs no filesystem/process/network operation.
    |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:420:89
    |
418 |         self, document: JsonObject, diagnostics: tuple[JsonObject, ...]
419 |     ) -> None:
420 |         """Check document (JsonObject), diagnostics (tuple[JsonObject, ...]); return None.
    |                                                                                         ^^
421 |
422 |         Raises EXTENSION_ACCOUNTING for omitted/changed inputs or broken diagnostic
    |

F401 [*] `tests.discovery_runtime.test_extension_results.MANIFEST` imported but unused
  --> tests\discovery_runtime\test_extension_inventory_merge.py:38:5
   |
36 |     ADAPTER,
37 |     AUTHOR,
38 |     MANIFEST,
   |     ^^^^^^^^
39 |     MEMBER,
40 |     STAMP,
   |
help: Remove unused import: `tests.discovery_runtime.test_extension_results.MANIFEST`

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:266:89
    |
265 |     def forged(*args: object, **kwargs: object) -> tuple[ValidatedExtension, ...]:
266 |         """Return retained tuple[ValidatedExtension, ...] for ignored object args/kwargs.
    |                                                                                         ^
267 |
268 |         Supplies deliberately untrusted proof; no input mutation, failure or I/O.
    |

Found 4 errors.
[*] 1 fixable with the `--fix` option.
```
